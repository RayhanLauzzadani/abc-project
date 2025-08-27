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

// ---------- helpers ----------
const asInt = (v: unknown, def = 0) =>
  typeof v === "number" && Number.isFinite(v) ? Math.trunc(v) : def;

const httpsError = (code: FunctionsErrorCode, message: string) =>
  new HttpsError(code, message);

// ---------- (NEW) invoice helpers ----------
// INV-YYYYMMDD-XXXXXX (X = A..Z / 2..9 tanpa karakter yang mirip)  // <<< NEW
function generateInvoiceId(): string {                               // <<< NEW
  const now = new Date();                                           // <<< NEW
  const yyyy = now.getFullYear().toString();                        // <<< NEW
  const mm = String(now.getMonth() + 1).padStart(2, "0");           // <<< NEW
  const dd = String(now.getDate()).padStart(2, "0");                // <<< NEW
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";              // <<< NEW
  let rand = "";                                                    // <<< NEW
  for (let i = 0; i < 6; i++) {                                     // <<< NEW
    rand += alphabet.charAt(Math.floor(Math.random() * alphabet.length));
  }
  return `INV-${yyyy}${mm}${dd}-${rand}`;
}

// pastikan unik di koleksi `orders` (3x percobaan, lalu fallback timestamp)     // <<< NEW
async function generateUniqueInvoiceId(): Promise<string> {                      // <<< NEW
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
          invoiceId: d.invoiceId ?? null, // <<< NEW (kembalikan juga kalau sudah ada)
        };
      }
    }

    const buyerRef = db.collection("users").doc(buyerId);
    const orderRef = db.collection("orders").doc();
    const buyerTxRef = buyerRef.collection("transactions").doc();

    // generate invoice unik (di luar transaksi supaya tidak memanjang)  // <<< NEW
    const invoiceId = await generateUniqueInvoiceId();                 // <<< NEW

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
        },
        // --- waktu + idempoten
        createdAt: NOW,
        updatedAt: NOW,
        idempotencyKey: (idempotencyKey as string) ?? null,

        // --- (NEW) simpan invoiceId
        invoiceId, // <<< NEW
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

    return { ok: true, orderId: orderRef.id, invoiceId }; // <<< CHANGED (kembalikan invoiceId)
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

      const items: any[] = order.items || [];
      for (const it of items) {
        const ref = db.collection("products").doc(String(it.productId));
        const qty = asInt(it.qty);
        t.update(ref, { sold: admin.firestore.FieldValue.increment(qty) });
      }

      const storeIdStr = String(order.storeId || "");
      if (storeIdStr) {
        // jumlahkan total qty semua item di pesanan
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

    const orderRef = db.collection("orders").doc(orderId);

    await db.runTransaction(async (t: Transaction) => {
      const orderSnap = await t.get(orderRef);
      if (!orderSnap.exists) throw httpsError("not-found", "Order tidak ditemukan.");
      const order = orderSnap.data()!;

      const buyerId: string = order.buyerId ?? "";
      const sellerId: string = order.sellerId ?? "";
      if (![buyerId, sellerId].includes(uid)) {
        throw httpsError("permission-denied", "Tidak berhak membatalkan pesanan ini.");
      }
      if ((order.payment?.status ?? "") !== "ESCROWED") {
        throw httpsError("failed-precondition", "Pesanan tidak bisa direfund.");
      }

      const total = asInt(order.amounts?.total);
      if (total <= 0) throw httpsError("internal", "Nominal pesanan tidak valid.");

      const buyerRef = db.collection("users").doc(buyerId);
      const buyerSnap = await t.get(buyerRef);
      const bWallet = buyerSnap.get("wallet") ?? { available: 0, onHold: 0 };

      // 1) lepas hold -> kembali ke available buyer
      t.update(buyerRef, {
        "wallet.onHold": Math.max(0, asInt(bWallet.onHold) - total),
        "wallet.available": asInt(bWallet.available) + total,
        "wallet.updatedAt": NOW,
      });

      // 2) update order
      const stockDeducted = !!order.stockDeducted;
      if (stockDeducted) {
        const items: any[] = order.items || [];
        for (const it of items) {
          const ref = db.collection("products").doc(String(it.productId));
          const qty = asInt(it.qty);
          t.update(ref, { stock: admin.firestore.FieldValue.increment(qty) });
        }
      }

      t.update(orderRef, {
        status: "CANCELED",
        "payment.status": "REFUNDED",
        "cancel.reason": reason || null,
        "cancel.at": NOW,
        updatedAt: NOW,
        ...(stockDeducted ? { stockDeducted: false } : {}),
      });

      // 3) transaksi buyer
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

    return { ok: true };
  }
);

// --- NEW: acceptOrder (potong stok + ubah status ke ACCEPTED)
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
      // idempoten: kalau sudah ACCEPTED/SHIPPED/COMPLETED, biarkan
      if (["ACCEPTED","SHIPPED","DELIVERED","COMPLETED","SUCCESS"].includes(status)) return;
      throw httpsError("failed-precondition", `Tidak bisa diterima pada status ${status}.`);
    }

    // hanya seller pemilik yang boleh menerima
    if (String(order.sellerId || "") !== uid) {
      throw httpsError("permission-denied", "Bukan seller pemilik pesanan.");
    }

    const items: any[] = order.items || [];
    if (!items.length) throw httpsError("failed-precondition", "Item kosong.");

    // cek stok semua produk
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
        throw httpsError("failed-precondition", `Stok ${data.name || it.productId} tidak cukup (tersisa ${stock}).`);
      }
    }

    // potong stok (pakai increment(-qty))
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
    });
  });

  return { ok: true };
});
