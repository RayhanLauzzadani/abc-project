// functions/src/wallet_escrow.ts
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { Transaction } from "firebase-admin/firestore";
// v2 (https callable)
import {
  onCall,
  HttpsError,
  FunctionsErrorCode,
  CallableRequest,
} from "firebase-functions/v2/https";

if (!admin.apps.length) admin.initializeApp();

const db = admin.firestore();
const NOW = admin.firestore.FieldValue.serverTimestamp();
const REGION = "asia-southeast2";
const ONE_DAY_MS = 24 * 60 * 60 * 1000;

// ---------- helpers ----------
const asInt = (v: unknown, def = 0) =>
  typeof v === "number" && Number.isFinite(v) ? Math.trunc(v) : def;

const httpsError = (code: FunctionsErrorCode, message: string) =>
  new HttpsError(code, message);

type CancelBy = "SELLER" | "BUYER" | "SYSTEM";

// ---------- (NEW) invoice helpers ----------
// INV-YYYYMMDD-XXXXXX (X = A..Z / 2..9 tanpa karakter yang mirip)
function generateInvoiceId(): string {
  const now = new Date();
  const yyyy = now.getFullYear().toString();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let rand = "";
  for (let i = 0; i < 6; i++) {
    rand += alphabet.charAt(Math.floor(Math.random() * alphabet.length));
  }
  return `INV-${yyyy}${mm}${dd}-${rand}`;
}

// pastikan unik di koleksi orders (3x percobaan, lalu fallback timestamp)
async function generateUniqueInvoiceId(): Promise<string> {
  for (let i = 0; i < 3; i++) {
    const candidate = generateInvoiceId();
    const snap = await db
      .collection("orders")
      .where("invoiceId", "==", candidate)
      .limit(1)
      .get();
    if (snap.empty) return candidate;
  }
  return `INV-${Date.now()}`;
}

/** Reusable core to cancel + refund an order safely (idempotent). */
async function cancelOrderCore(
  orderId: string,
  opts: { reason: string; by: CancelBy }
) {
  const orderRef = db.collection("orders").doc(orderId);

  await db.runTransaction(async (t) => {
    const orderSnap = await t.get(orderRef);
    if (!orderSnap.exists) return; // idempotent

    const order = orderSnap.data()!;
    const status = String(order.status || "PLACED").toUpperCase();
    const payStatus = String(order.payment?.status || "");

    // Only cancel when still PLACED and funds are ESCROWED
    if (status !== "PLACED" || payStatus !== "ESCROWED") return;

    const total = asInt(order.amounts?.total);
    if (total <= 0) return;

    const buyerId: string = String(order.buyerId || "");
    const buyerRef = db.collection("users").doc(buyerId);
    const buyerSnap = await t.get(buyerRef);
    const bWallet = buyerSnap.get("wallet") ?? { available: 0, onHold: 0 };

    // 1) release hold -> back to buyer.available
    t.update(buyerRef, {
      "wallet.onHold": Math.max(0, asInt(bWallet.onHold) - total),
      "wallet.available": asInt(bWallet.available) + total,
      "wallet.updatedAt": NOW,
    });

    // 2) return stock if it was deducted on ACCEPTED
    if (order.stockDeducted) {
      const items: any[] = order.items || [];
      for (const it of items) {
        const ref = db.collection("products").doc(String(it.productId));
        const qty = asInt(it.qty);
        t.update(ref, { stock: admin.firestore.FieldValue.increment(qty) });
      }
    }

    // 3) update order
    t.update(orderRef, {
      status: "CANCELED",
      "payment.status": "REFUNDED",
      "shippingAddress.status": "CANCELED",
      cancel: {
        at: NOW,
        reason: opts.reason || null,
        by: opts.by,
      },
      updatedAt: NOW,
      ...(order.stockDeducted ? { stockDeducted: false } : {}),
    });

    // 4) buyer refund transaction
    const buyerTxRef = buyerRef.collection("transactions").doc();
    t.set(buyerTxRef, {
      type: "REFUND",
      direction: "IN",
      amount: total,
      status: "SUCCESS",
      orderId,
      title: "Pengembalian",
      createdAt: NOW,
    });
  });
}

// ---------- 1) init wallet saat user baru (v1 auth trigger) ----------
export const initWalletOnSignup = functions
  .region(REGION)
  .auth.user()
  .onCreate(async (user) => {
    const ref = db.collection("users").doc(user.uid);
    await ref.set(
      {
        wallet: {
          available: 0,
          onHold: 0,
          currency: "IDR",
          updatedAt: NOW,
        },
      },
      { merge: true }
    );
  });

// ---------- 2) placeOrder: hold saldo buyer + buat order ----------
/**
 * Callable: placeOrder
 * data:
 *  - sellerId: string
 *  - storeId: string
 *  - storeName: string
 *  - items: Array<{ productId,name,imageUrl,price,qty,variant? }>
 *  - amounts: { subtotal, shipping, tax, total }
 *  - shippingAddress: { label, address }
 *  - idempotencyKey?: string
 */
export const placeOrder = onCall(
  { region: REGION },
  async (req: CallableRequest<any>) => {
    const buyerId = req.auth?.uid;
    if (!buyerId) throw httpsError("unauthenticated", "Login diperlukan.");

    const {
      sellerId,
      storeId,
      storeName,
      items,
      amounts,
      shippingAddress,
      idempotencyKey,
    } = (req.data ?? {}) as Record<string, unknown>;

    const total = asInt((amounts as any)?.total);
    if (!sellerId || !storeId || !storeName || !Array.isArray(items) || total <= 0) {
      throw httpsError("invalid-argument", "Payload tidak lengkap/valid.");
    }

    // Idempotency
    if (idempotencyKey) {
      const dup = await db
        .collection("orders")
        .where("buyerId", "==", buyerId)
        .where("idempotencyKey", "==", idempotencyKey)
        .limit(1)
        .get();
      if (!dup.empty) {
        const d = dup.docs[0].data();
        return {
          ok: true,
          orderId: dup.docs[0].id,
          idempotent: true,
          invoiceId: d.invoiceId ?? null, // kembalikan invoiceId jika sudah ada
        };
      }
    }

    const buyerRef = db.collection("users").doc(buyerId);
    const orderRef = db.collection("orders").doc();
    const buyerTxRef = buyerRef.collection("transactions").doc();

    // hitung auto-cancel deadline (server time)
    const autoCancelAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + ONE_DAY_MS
    );

    // generate invoice unik (di luar transaksi)
    const invoiceId = await generateUniqueInvoiceId();

    await db.runTransaction(async (t: Transaction) => {
      const buyerSnap = await t.get(buyerRef);
      const wallet = buyerSnap.get("wallet") ?? { available: 0, onHold: 0 };

      const available = asInt(wallet.available);
      if (available < total) {
        throw httpsError("failed-precondition", "Saldo tidak cukup.");
      }

      // 1) hold saldo buyer
      t.update(buyerRef, {
        "wallet.available": available - total,
        "wallet.onHold": asInt(wallet.onHold) + total,
        "wallet.updatedAt": NOW,
      });

      // 2) buat dokumen order
      t.set(orderRef, {
        buyerId,
        sellerId,
        storeId,
        storeName,
        items,
        amounts: {
          subtotal: asInt((amounts as any)?.subtotal),
          shipping: asInt((amounts as any)?.shipping),
          tax: asInt((amounts as any)?.tax),
          total,
        },
        payment: {
          method: "abc_payment",
          status: "ESCROWED",
        },
        status: "PLACED",
        shippingAddress: {
          label: (shippingAddress as any)?.label ?? "-",
          address: (shippingAddress as any)?.address ?? "-",
          status: "PLACED",
        },
        createdAt: NOW,
        updatedAt: NOW,
        autoCancelAt, // <—— deadline auto-cancel 24 jam
        idempotencyKey: (idempotencyKey as string) ?? null,
        invoiceId, // simpan invoice
      });

      // 3) catat transaksi buyer (ESCROWED)
      t.set(buyerTxRef, {
        type: "PAYMENT",
        direction: "OUT",
        amount: total,
        status: "ESCROWED",
        orderId: orderRef.id,
        counterpartyUid: sellerId,
        title: "Pembayaran (ditahan)",
        createdAt: NOW,
        idempotencyKey: (idempotencyKey as string) ?? null,
      });
    });

    return { ok: true, orderId: orderRef.id, invoiceId };
  }
);

// ---------- 3) completeOrder: lepas hold & kredit seller ----------
/**
 * Callable: completeOrder
 * data: { orderId: string }
 * Hanya buyer pemilik order yang boleh menyelesaikan.
 */
export const completeOrder = onCall(
  { region: REGION },
  async (req: CallableRequest<any>) => {
    const buyerId = req.auth?.uid;
    if (!buyerId) throw httpsError("unauthenticated", "Login diperlukan.");
    const orderId: string | undefined = req.data?.orderId;
    if (!orderId) throw httpsError("invalid-argument", "orderId wajib.");

    const orderRef = db.collection("orders").doc(orderId);

    await db.runTransaction(async (t: Transaction) => {
      const orderSnap = await t.get(orderRef);
      if (!orderSnap.exists) throw httpsError("not-found", "Order tidak ditemukan.");

      const order = orderSnap.data()!;
      if (order.buyerId !== buyerId) throw httpsError("permission-denied", "Bukan pemilik pesanan.");
      if ((order.payment?.status ?? "") !== "ESCROWED")
        throw httpsError("failed-precondition", "Pembayaran tidak berstatus ESCROWED.");

      const total = asInt(order.amounts?.total);
      const sellerId = String(order.sellerId ?? "");
      if (!sellerId || total <= 0) throw httpsError("internal", "Data order tidak valid.");

      const buyerRef = db.collection("users").doc(buyerId);
      const sellerRef = db.collection("users").doc(sellerId);
      const buyerTxRef = buyerRef.collection("transactions").doc();
      const sellerTxRef = sellerRef.collection("transactions").doc();

      const buyerSnap = await t.get(buyerRef);
      const sellerSnap = await t.get(sellerRef);

      const bWallet = buyerSnap.get("wallet") ?? { available: 0, onHold: 0 };
      const sWallet = sellerSnap.get("wallet") ?? { available: 0, onHold: 0 };

      // 1) lepas hold buyer
      t.update(buyerRef, {
        "wallet.onHold": Math.max(0, asInt(bWallet.onHold) - total),
        "wallet.updatedAt": NOW,
      });

      // 2) kredit seller
      t.update(sellerRef, {
        "wallet.available": asInt(sWallet.available) + total,
        "wallet.updatedAt": NOW,
      });

      // 2b) metrik produk & toko
      const items: any[] = order.items || [];
      for (const it of items) {
        const ref = db.collection("products").doc(String(it.productId));
        const qty = asInt(it.qty);
        t.update(ref, { sold: admin.firestore.FieldValue.increment(qty) });
      }

      const storeIdStr = String(order.storeId || "");
      if (storeIdStr) {
        const totalQty = items.reduce((sum, it) => sum + asInt(it.qty), 0);
        const storeRef = db.collection("stores").doc(storeIdStr);
        t.update(storeRef, {
          totalSales: admin.firestore.FieldValue.increment(totalQty),
          lastSaleAt: NOW,
        });
      }

      // 3) update order
      t.update(orderRef, {
        status: "COMPLETED",
        "payment.status": "SETTLED",
        "shippingAddress.status": "COMPLETED",
        updatedAt: NOW,
      });

      // 4) transaksi ringkas
      t.set(buyerTxRef, {
        type: "PAYMENT",
        direction: "OUT",
        amount: total,
        status: "SUCCESS",
        orderId,
        counterpartyUid: sellerId,
        title: "Pembayaran (Selesai)",
        createdAt: NOW,
      });

      t.set(sellerTxRef, {
        type: "SETTLEMENT",
        direction: "IN",
        amount: total,
        status: "SUCCESS",
        orderId,
        counterpartyUid: buyerId,
        title: "Pencairan",
        createdAt: NOW,
      });
    });

    return { ok: true };
  }
);

// ---------- 4) cancelOrder: refund hold ke buyer ----------
/**
 * Callable: cancelOrder
 * data: { orderId: string, reason?: string }
 * Buyer atau Seller (atau Admin) boleh membatalkan selama status pembayaran ESCROWED.
 */
export const cancelOrder = onCall(
  { region: REGION },
  async (req: CallableRequest<any>) => {
    const uid = req.auth?.uid;
    if (!uid) throw httpsError("unauthenticated", "Login diperlukan.");
    const orderId: string | undefined = req.data?.orderId;
    const reason: string = req.data?.reason ?? "";
    if (!orderId) throw httpsError("invalid-argument", "orderId wajib.");

    const snap = await db.collection("orders").doc(orderId).get();
    if (!snap.exists) throw httpsError("not-found", "Order tidak ditemukan.");

    const buyerId: string = snap.get("buyerId") ?? "";
    const sellerId: string = snap.get("sellerId") ?? "";
    if (![buyerId, sellerId].includes(uid)) {
      throw httpsError("permission-denied", "Tidak berhak membatalkan pesanan ini.");
    }

    await cancelOrderCore(orderId, {
      reason,
      by: uid === sellerId ? "SELLER" : "BUYER",
    });

    return { ok: true };
  }
);

// --- 5) acceptOrder (potong stok + ubah status ke ACCEPTED)
export const acceptOrder = onCall({ region: REGION }, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw httpsError("unauthenticated", "Login diperlukan.");
  const orderId: string | undefined = req.data?.orderId;
  if (!orderId) throw httpsError("invalid-argument", "orderId wajib.");

  const orderRef = db.collection("orders").doc(orderId);

  await db.runTransaction(async (t) => {
    const snap = await t.get(orderRef);
    if (!snap.exists) throw httpsError("not-found", "Order tidak ditemukan.");

    const order = snap.data()!;
    const status: string = (order.status || "PLACED").toUpperCase();

    if (status !== "PLACED") {
      // idempotent: if already beyond PLACED, silently allow
      if (["ACCEPTED", "SHIPPED", "DELIVERED", "COMPLETED", "SUCCESS"].includes(status)) return;
      throw httpsError("failed-precondition", `Tidak bisa diterima pada status ${status}.`);
    }

    // only owner seller
    if (String(order.sellerId || "") !== uid) {
      throw httpsError("permission-denied", "Bukan seller pemilik pesanan.");
    }

    const items: any[] = order.items || [];
    if (!items.length) throw httpsError("failed-precondition", "Item kosong.");

    // check stock
    const prodRefs = items.map((it) => db.collection("products").doc(String(it.productId)));
    const prodSnaps = await Promise.all(prodRefs.map((r) => t.get(r)));

    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      const prod = prodSnaps[i];
      if (!prod.exists) throw httpsError("failed-precondition", "Produk tidak ditemukan.");
      const data = prod.data()!;
      const stock = asInt(data.stock);
      const qty = asInt(it.qty);
      if (qty <= 0) throw httpsError("failed-precondition", "Qty tidak valid.");
      if (stock < qty) {
        throw httpsError(
          "failed-precondition",
          `Stok ${data.name || it.productId} tidak cukup (tersisa ${stock}).`
        );
      }
    }

    // deduct stock
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      const qty = asInt(it.qty);
      t.update(prodRefs[i], { stock: admin.firestore.FieldValue.increment(-qty) });
    }

    // update order
    t.update(orderRef, {
      status: "ACCEPTED",
      stockDeducted: true,
      updatedAt: NOW,
      autoCancelAt: admin.firestore.FieldValue.delete(), // stop countdown
      "shippingAddress.status": "ACCEPTED",
    });
  });

  return { ok: true };
});

// --- 6) Scheduler: auto-cancel after 24h if still PLACED
export const autoCancelUnacceptedOrders = functions
  .region(REGION)
  .pubsub.schedule("every 15 minutes")
  .timeZone("Asia/Jakarta")
  .onRun(async () => {
    const nowTs = admin.firestore.Timestamp.now();

    const q = db
      .collection("orders")
      .where("status", "==", "PLACED")
      .where("autoCancelAt", "<=", nowTs)
      .limit(300);

    let processed = 0;
    while (true) {
      const snap = await q.get();
      if (snap.empty) break;

      for (const doc of snap.docs) {
        try {
          await cancelOrderCore(doc.id, {
            reason: "Timeout: seller did not accept within 24h",
            by: "SYSTEM",
          });
          processed++;
        } catch (e) {
          console.error("auto-cancel failed for", doc.id, e);
        }
      }

      if (snap.size < 300) break; // done
    }

    console.log(`autoCancel processed: ${processed}`);
    return null;
  });
