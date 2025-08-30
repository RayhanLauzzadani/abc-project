import * as admin from "firebase-admin";
import * as functionsV1 from "firebase-functions/v1";
import { UserRecord } from "firebase-admin/auth";
import { Transaction } from "firebase-admin/firestore";
// v2 (https callable)
import {
  onCall,
  HttpsError,
  FunctionsErrorCode,
  CallableRequest,
} from "firebase-functions/v2/https";
// v2 secrets
import { defineSecret } from "firebase-functions/params";

if (!admin.apps.length) admin.initializeApp();

const db = admin.firestore();
const NOW = admin.firestore.FieldValue.serverTimestamp();
const REGION = "asia-southeast2";
const ONE_DAY_MS = 24 * 60 * 60 * 1000;
const TWO_DAYS_MS = 2 * ONE_DAY_MS;

// ======================= FEES & ADMIN SECRET =======================
// Pastikan konsisten dengan lib/common/fees.dart di client
const SERVICE_FEE = 2000;       // biaya layanan flat
const TAX_RATE = 0.01;          // 1%
const taxOn = (base: number) => Math.round(base * TAX_RATE);

// Secret ADMIN_UID (UID user admin yang menampung fee & pajak)
const ADMIN_UID_SECRET = defineSecret("ADMIN_UID");

// Fallback agar emulator/dev tetap bisa jalan kalau secret belum diset.
function resolveAdminUid(): string {
  return (
    ADMIN_UID_SECRET.value() ||                      // Secret V2 (prod)
    process.env.ADMIN_UID ||                         // ENV (emulator/CI)
    (functionsV1.config().app?.admin_uid as string)  // v1 runtime config (opsional)
  );
}

// ============================ helpers ==============================
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

    // IZINKAN cancel pada PLACED/ACCEPTED selama dana ESCROWED
    if (!["PLACED", "ACCEPTED"].includes(status) || payStatus !== "ESCROWED")
      return;

    const total = asInt(order.amounts?.total);
    if (total <= 0) return;

    const buyerId: string = String(order.buyerId || "");
    const buyerRef = db.collection("users").doc(buyerId);
    const buyerSnap = await t.get(buyerRef);
    const bWallet = buyerSnap.get("wallet") ?? { available: 0, onHold: 0 };

    // 1) release hold -> back to buyer.available
    t.update(buyerRef, {
      "wallet.onHold": Math.max(0, asInt(bWallet.onHold) - total),
      "wallet.available":
        asInt(buyerSnap.get("wallet")?.available ?? 0) + total,
      "wallet.updatedAt": NOW,
    });

    // 2) return stock if it was deducted
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
      autoCancelAt: admin.firestore.FieldValue.delete(),
      shipByAt: admin.firestore.FieldValue.delete(),
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

// ===================== 1) init wallet on signup ====================
export const initWalletOnSignup = functionsV1
  .region(REGION)
  .auth.user()
  .onCreate(async (user: UserRecord) => {
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

// ========== 2) placeOrder: hold saldo buyer + buat order ===========
/**
 * Callable: placeOrder
 * data:
 *  - sellerId: string
 *  - storeId: string
 *  - storeName: string
 *  - items: Array<{ productId,name,imageUrl,price,qty,variant? }>
 *  - amounts: { subtotal, shipping, serviceFee, tax, total }
 *  - shippingAddress: { label, address }
 *  - idempotencyKey?: string
 */
export const placeOrder = onCall(
  { region: REGION, secrets: [ADMIN_UID_SECRET] }, // (bind secret, walau tidak dipakai di sini)
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

    const clientSubtotal = asInt((amounts as any)?.subtotal);
    const clientShipping = asInt((amounts as any)?.shipping);
    // NOTE: kita sengaja tidak memakai nilai serviceFee/tax/total dari client
    // agar aman dari manipulasi → dihitung ulang di server.

    if (
      !sellerId ||
      !storeId ||
      !storeName ||
      !Array.isArray(items) ||
      clientSubtotal <= 0
    ) {
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
          invoiceId: d.invoiceId ?? null,
        };
      }
    }

    // Recompute di server (anti manipulasi)
    const serviceFee = SERVICE_FEE;
    const tax = taxOn(clientSubtotal);
    const expectedTotal = clientSubtotal + clientShipping + serviceFee + tax;

    // Pakai nilai server sebagai sumber kebenaran
    const total = expectedTotal;

    const buyerRef = db.collection("users").doc(buyerId);
    const orderRef = db.collection("orders").doc();
    const buyerTxRef = buyerRef.collection("transactions").doc();

    const autoCancelAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + ONE_DAY_MS
    );
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

      // 2) buat order dengan amounts lengkap
      t.set(orderRef, {
        buyerId,
        sellerId,
        storeId,
        storeName,
        items,
        amounts: {
          subtotal: clientSubtotal,
          shipping: clientShipping,
          serviceFee, // NEW
          tax,        // NEW
          total,      // NEW
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
        autoCancelAt, // deadline auto-cancel 24 jam
        idempotencyKey: (idempotencyKey as string) ?? null,
        invoiceId,
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

// ====== 3) completeOrder: lepas hold & split ke seller/admin ======
/**
 * Callable: completeOrder
 * data: { orderId: string }
 * Hanya buyer pemilik order yang boleh menyelesaikan.
 */
export const completeOrder = onCall(
  { region: REGION, secrets: [ADMIN_UID_SECRET] }, // butuh secret
  async (req: CallableRequest<any>) => {
    const buyerId = req.auth?.uid;
    if (!buyerId) throw httpsError("unauthenticated", "Login diperlukan.");
    const orderId: string | undefined = req.data?.orderId;
    if (!orderId) throw httpsError("invalid-argument", "orderId wajib.");

    const ADMIN_UID = resolveAdminUid();
    if (!ADMIN_UID) {
      throw httpsError(
        "failed-precondition",
        "ADMIN_UID belum dikonfigurasi sebagai Secret/ENV."
      );
    }

    const orderRef = db.collection("orders").doc(orderId);

    await db.runTransaction(async (t: Transaction) => {
      const orderSnap = await t.get(orderRef);
      if (!orderSnap.exists)
        throw httpsError("not-found", "Order tidak ditemukan.");

      const order = orderSnap.data()!;
      if (order.buyerId !== buyerId)
        throw httpsError("permission-denied", "Bukan pemilik pesanan.");
      if ((order.payment?.status ?? "") !== "ESCROWED")
        throw httpsError(
          "failed-precondition",
          "Pembayaran tidak berstatus ESCROWED."
        );

      const subtotal = asInt(order.amounts?.subtotal);
      const shipping = asInt(order.amounts?.shipping);
      const service = asInt(order.amounts?.serviceFee);
      const tax = asInt(order.amounts?.tax);
      const total = asInt(order.amounts?.total);

      const sellerId = String(order.sellerId ?? "");
      if (!sellerId || total <= 0)
        throw httpsError("internal", "Data order tidak valid.");

      // Hitung pembagian
      const sellerTake = subtotal + shipping;
      let adminTake = service + tax;

      // Antisipasi mismatch pembulatan/versi lama
      const remainder = total - sellerTake - adminTake;
      if (remainder > 0) adminTake += remainder;

      const buyerRef = db.collection("users").doc(buyerId);
      const sellerRef = db.collection("users").doc(sellerId);
      const adminRef = db.collection("users").doc(ADMIN_UID);

      const buyerTxRef = buyerRef.collection("transactions").doc();
      const sellerTxRef = sellerRef.collection("transactions").doc();
      const adminTxRef = adminRef.collection("transactions").doc();

      const buyerSnap = await t.get(buyerRef);
      const sellerSnap = await t.get(sellerRef);
      const adminSnap = await t.get(adminRef);

      const bWallet = buyerSnap.get("wallet") ?? { available: 0, onHold: 0 };
      const sWallet = sellerSnap.get("wallet") ?? { available: 0, onHold: 0 };
      const aWallet = adminSnap.get("wallet") ?? { available: 0, onHold: 0 };

      // 1) lepas hold buyer
      t.update(buyerRef, {
        "wallet.onHold": Math.max(0, asInt(bWallet.onHold) - total),
        "wallet.updatedAt": NOW,
      });

      // 2) kredit seller (subtotal + shipping)
      t.update(sellerRef, {
        "wallet.available": asInt(sWallet.available) + sellerTake,
        "wallet.updatedAt": NOW,
      });

      // 3) kredit admin (service + tax + remainder kalau ada)
      if (adminTake > 0) {
        t.set(
          adminRef,
          {
            wallet: {
              available: asInt(aWallet.available) + adminTake,
              onHold: asInt(aWallet.onHold) || 0,
              currency: aWallet.currency || "IDR",
              updatedAt: NOW,
            },
          },
          { merge: true }
        );
      }

      // 4) metrik produk & toko
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

      // 5) update order + settlement breakdown
      t.update(orderRef, {
        status: "COMPLETED",
        "payment.status": "SETTLED",
        "shippingAddress.status": "COMPLETED",
        updatedAt: NOW,
        settlement: {
          sellerTake,
          adminTake,
          settledAt: NOW,
        },
        autoCancelAt: admin.firestore.FieldValue.delete(),
        shipByAt: admin.firestore.FieldValue.delete(),
      });

      // 6) transaksi ringkas
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
        amount: sellerTake,
        status: "SUCCESS",
        orderId,
        counterpartyUid: buyerId,
        title: "Pencairan",
        createdAt: NOW,
      });

      if (adminTake > 0) {
        t.set(adminTxRef, {
          type: "FEE",
          direction: "IN",
          amount: adminTake,
          status: "SUCCESS",
          orderId,
          counterpartyUid: buyerId,
          title: "Biaya Layanan & Pajak",
          createdAt: NOW,
        });
      }
    });

    return { ok: true };
  }
);

// ========== 4) cancelOrder: refund hold ke buyer ==========
/**
 * Callable: cancelOrder
 * data: { orderId: string, reason?: string }
 */
export const cancelOrder = onCall(
  { region: REGION, secrets: [ADMIN_UID_SECRET] },
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
      throw httpsError(
        "permission-denied",
        "Tidak berhak membatalkan pesanan ini."
      );
    }

    await cancelOrderCore(orderId, {
      reason,
      by: uid === sellerId ? "SELLER" : "BUYER",
    });

    return { ok: true };
  }
);

// --- 5) acceptOrder (potong stok + ubah status ke ACCEPTED)
export const acceptOrder = onCall(
  { region: REGION, secrets: [ADMIN_UID_SECRET] },
  async (req) => {
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
        // idempotent
        if (
          ["ACCEPTED", "SHIPPED", "DELIVERED", "COMPLETED", "SUCCESS"].includes(
            status
          )
        )
          return;
        throw httpsError(
          "failed-precondition",
          `Tidak bisa diterima pada status ${status}.`
        );
      }

      // only owner seller
      if (String(order.sellerId || "") !== uid) {
        throw httpsError("permission-denied", "Bukan seller pemilik pesanan.");
      }

      const items: any[] = order.items || [];
      if (!items.length) throw httpsError("failed-precondition", "Item kosong.");

      // check stock
      const prodRefs = items.map((it) =>
        db.collection("products").doc(String(it.productId))
      );
      const prodSnaps = await Promise.all(prodRefs.map((r) => t.get(r)));

      for (let i = 0; i < items.length; i++) {
        const it = items[i];
        const prod = prodSnaps[i];
        if (!prod.exists)
          throw httpsError("failed-precondition", "Produk tidak ditemukan.");
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
        t.update(prodRefs[i], {
          stock: admin.firestore.FieldValue.increment(-qty),
        });
      }

      // set deadline kirim 2 hari dari sekarang
      const shipByAt = admin.firestore.Timestamp.fromMillis(
        Date.now() + TWO_DAYS_MS
      );

      // update order
      t.update(orderRef, {
        status: "ACCEPTED",
        stockDeducted: true,
        updatedAt: NOW,
        autoCancelAt: admin.firestore.FieldValue.delete(),
        shipByAt,
        "shippingAddress.status": "ACCEPTED",
      });
    });

    return { ok: true };
  }
);

// --- 6) Scheduler: auto-cancel after 24h if still PLACED
export const autoCancelUnacceptedOrders = functionsV1
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
          console.error("auto-cancel (PLACED) failed for", doc.id, e);
        }
      }

      if (snap.size < 300) break;
    }

    console.log(`autoCancel (PLACED) processed: ${processed}`);
    return null;
  });

// --- 7) Scheduler: auto-cancel after 48h if ACCEPTED not SHIPPED
export const autoCancelUnshippedOrders = functionsV1
  .region(REGION)
  .pubsub.schedule("every 15 minutes")
  .timeZone("Asia/Jakarta")
  .onRun(async () => {
    const nowTs = admin.firestore.Timestamp.now();

    const q = db
      .collection("orders")
      .where("status", "==", "ACCEPTED")
      .where("shipByAt", "<=", nowTs)
      .limit(300);

    let processed = 0;
    while (true) {
      const snap = await q.get();
      if (snap.empty) break;

      for (const doc of snap.docs) {
        try {
          await cancelOrderCore(doc.id, {
            reason: "Timeout: seller did not ship within 48h",
            by: "SYSTEM",
          });
          processed++;
        } catch (e) {
          console.error("auto-cancel (ACCEPTED) failed for", doc.id, e);
        }
      }

      if (snap.size < 300) break;
    }

    console.log(`autoCancel (ACCEPTED/unshipped) processed: ${processed}`);
    return null;
  });
