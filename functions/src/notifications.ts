// functions/src/notifications.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

type NotifData = {
  title?: string;
  body?: string;
  type?: string;
  orderId?: string;
  chatId?: string;
  invoiceId?: string;
  // dll sesuai payload yang kamu tulis dari app
};

type ChatNotifData = {
  // wajib di dokumen (minimal salah satu)
  chatId?: string;
  receiverId?: string;
  senderId?: string;

  // metadata yang ingin dipastikan ada
  type?: string; // 'chat_message'
  buyerId?: string;
  shopId?: string;
  shopOwnerId?: string;
  receiverSide?: "buyer" | "seller";
  isRead?: boolean;
  timestamp?: admin.firestore.FieldValue | admin.firestore.Timestamp;

  // opsional, untuk FCM/body
  title?: string;
  body?: string;
};

const db = admin.firestore();

/** Ambil token FCM dari users/{uid}.fcmTokens: string[] */
async function getUserTokens(uid: string): Promise<string[]> {
  const snap = await db.collection("users").doc(uid).get();
  const tokens: string[] = (snap.get("fcmTokens") ?? []) as string[];
  return tokens.filter(Boolean);
}

/** Bersihkan token yang invalid dari users/{uid}.fcmTokens */
async function pruneInvalidTokens(
  uid: string,
  tokens: string[],
  responses: admin.messaging.BatchResponse
) {
  const invalid: string[] = [];
  responses.responses.forEach((r, i) => {
    if (!r.success) {
      const code = (r.error as any)?.errorInfo?.code ?? r.error?.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token"
      ) {
        invalid.push(tokens[i]);
      }
    }
  });
  if (invalid.length) {
    const ref = db.collection("users").doc(uid);
    await ref.update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalid),
    });
  }
}

/** Map dokumen Firestore -> payload FCM */
function buildPayload(data: NotifData, extra: Record<string, string> = {}) {
  const title = data.title ?? "Notifikasi";
  const body = data.body ?? "";
  return {
    notification: { title, body },
    data: {
      type: data.type ?? "",
      orderId: data.orderId ?? "",
      chatId: data.chatId ?? "",
      invoiceId: data.invoiceId ?? "",
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      ...extra,
    },
    android: {
      priority: "high" as const,
      notification: { channelId: "high_importance_channel" },
    },
  };
}

/** Helper: pilih nilai pertama yang terdefinisi */
function pickFirst<T>(...vals: (T | undefined | null)[]): T | undefined {
  for (const v of vals) {
    if (v !== undefined && v !== null && v !== "") return v as T;
  }
  return undefined;
}

/** Ambil meta chat (buyerId, shopId, shopOwnerId) dari chats/{chatId} dan stores/{shopId} */
async function resolveChatMeta(chatId: string): Promise<{
  buyerId?: string;
  shopId?: string;
  shopOwnerId?: string;
}> {
  const chatSnap = await db.collection("chats").doc(chatId).get();
  const chat = chatSnap.data() || {};

  const buyerId = pickFirst<string>(
    chat.buyerId,
    chat.buyerUID,
    chat.buyerUid,
    chat.buyer
  );

  const shopId = pickFirst<string>(
    chat.shopId,
    chat.storeId,
    chat.shopID,
    chat.storeID
  );

  let shopOwnerId = pickFirst<string>(
    chat.shopOwnerId,
    chat.ownerId,
    chat.ownerUid,
    chat.sellerId,
    chat.sellerUid
  );

  // Jika owner belum ketemu, coba resolve dari stores/{shopId}
  if (!shopOwnerId && shopId) {
    const storeSnap = await db.collection("stores").doc(shopId).get();
    if (storeSnap.exists) {
      const store = storeSnap.data() || {};
      shopOwnerId = pickFirst<string>(
        store.ownerId,
        store.ownerUid,
        store.sellerId,
        store.uid
      );
    }
  }

  return { buyerId, shopId, shopOwnerId };
}

/**
 * Lengkapi dokumen chatNotifications (onCreate) agar selalu punya:
 * - type = 'chat_message' (default)
 * - buyerId, shopId, shopOwnerId
 * - receiverId (fallback dari sender vs relasi)
 * - receiverSide ('buyer' | 'seller')
 * - timestamp & isRead default
 *
 * return: receiverId final (jika berhasil) — dipakai untuk FCM.
 */
async function normalizeChatNotification(
  docRef: FirebaseFirestore.DocumentReference,
  data: ChatNotifData
): Promise<{ receiverId?: string; normalized: ChatNotifData }> {
  const updates: Partial<ChatNotifData> = {};

  // Pastikan type
  const type = (data.type ?? "chat_message").toLowerCase();
  if (type !== data.type) updates.type = type;

  // Pastikan timestamp & isRead
  if (!data.timestamp) updates.timestamp = admin.firestore.FieldValue.serverTimestamp();
  if (data.isRead === undefined) updates.isRead = false;

  // Wajib punya chatId
  const chatId = data.chatId;
  if (!chatId || typeof chatId !== "string") {
    // Tidak bisa dilengkapi — kembalikan apa adanya
    if (Object.keys(updates).length) await docRef.set(updates, { merge: true });
    return { receiverId: data.receiverId, normalized: { ...data, ...updates } };
  }

  // Lengkapi meta dari chats/{chatId} (dan stores/{shopId} jika perlu)
  const { buyerId, shopId, shopOwnerId } = await resolveChatMeta(chatId);
  if (!data.buyerId && buyerId) updates.buyerId = buyerId;
  if (!data.shopId && shopId) updates.shopId = shopId;
  if (!data.shopOwnerId && shopOwnerId) updates.shopOwnerId = shopOwnerId;

  const finalBuyerId = (updates.buyerId ?? data.buyerId);
  const finalOwnerId = (updates.shopOwnerId ?? data.shopOwnerId);

  // Tentukan receiverId bila belum ada (berdasarkan senderId vs relasi)
  let receiverId = data.receiverId;
  if (!receiverId && data.senderId && finalBuyerId && finalOwnerId) {
    receiverId = data.senderId === finalBuyerId
      ? finalOwnerId
      : data.senderId === finalOwnerId
        ? finalBuyerId
        : undefined;
    if (receiverId) updates.receiverId = receiverId;
  } else if (!receiverId) {
    // fallback terakhir: jika cuma ada buyer/owner, pilih salah satu (tidak kirim FCM jika ambigu)
    receiverId = receiverId ?? undefined;
  }

  // Tentukan receiverSide
  const finalReceiverId = receiverId ?? data.receiverId;
  if (finalReceiverId && finalBuyerId && finalOwnerId) {
    const side: "buyer" | "seller" =
      finalReceiverId === finalBuyerId ? "buyer" : "seller";
    if (data.receiverSide !== side) updates.receiverSide = side;
  }

  if (Object.keys(updates).length) {
    await docRef.set(updates, { merge: true });
  }

  return { receiverId: finalReceiverId, normalized: { ...data, ...updates } };
}

/**
 * Trigger ketika ada dokumen baru di:
 * users/{uid}/notifications/{notifId}
 * -> kirim push ke semua token user tsb
 */
export const onUserNotificationCreated = functions.firestore
  .document("users/{uid}/notifications/{notifId}")
  .onCreate(async (snap, ctx) => {
    const uid = ctx.params.uid as string;
    const data = snap.data() as NotifData;

    const tokens = await getUserTokens(uid);
    if (!tokens.length) return;

    const payload = buildPayload(data);
    const res = await admin.messaging().sendEachForMulticast({ tokens, ...payload });
    await pruneInvalidTokens(uid, tokens, res);
  });

/**
 * Trigger ketika ada dokumen baru di:
 * chatNotifications/{docId}
 * -> pastikan shape (receiverSide, buyerId, shopOwnerId, timestamp, dst)
 * -> kirim push ke receiverId
 */
export const onChatNotificationCreated = functions.firestore
  .document("chatNotifications/{docId}")
  .onCreate(async (snap) => {
    const raw = snap.data() as ChatNotifData;
    const ref = snap.ref;

    // Normalisasi shape
    const { receiverId, normalized } = await normalizeChatNotification(ref, raw);

    // Tanpa receiverId yang jelas, tidak kirim FCM (hindari salah kirim)
    if (!receiverId) return;

    const tokens = await getUserTokens(receiverId);
    if (!tokens.length) return;

    const payload = buildPayload(
      {
        title: normalized.title ?? "Pesan Baru",
        body: normalized.body ?? "",
        type: normalized.type ?? "chat_message",
        chatId: normalized.chatId,
      },
      {
        receiverSide: String(normalized.receiverSide ?? ""),
        buyerId: String(normalized.buyerId ?? ""),
        shopId: String(normalized.shopId ?? ""),
        shopOwnerId: String(normalized.shopOwnerId ?? ""),
      }
    );

    const res = await admin.messaging().sendEachForMulticast({ tokens, ...payload });
    await pruneInvalidTokens(receiverId, tokens, res);
  });

/**
 * (OPSIONAL) Callable untuk backfill dokumen lama di chatNotifications
 * yang belum punya receiverSide/buyerId/shopOwnerId/timestamp.
 * Jalankan manual sekali/kalau perlu.
 */
export const backfillChatNotifications = functions.https.onCall(async (_data, context) => {
  // (opsional) batasi hanya admin
  const auth = context.auth;
  if (!auth) {
    throw new functions.https.HttpsError("unauthenticated", "Login required");
  }
  // Jika pakai custom claims admin, bisa cek di sini.
  // const token = await admin.auth().getUser(auth.uid);
  // const isAdmin = (token.customClaims?.admin === true);

  const batchSize = 300; // batasi per eksekusi
  const q = await db.collection("chatNotifications")
    .where("type", "==", "chat_message")
    .limit(batchSize)
    .get();

  let fixed = 0;
  for (const doc of q.docs) {
    const d = doc.data() as ChatNotifData;
    if (!d.receiverSide || !d.buyerId || !d.shopOwnerId || !d.timestamp) {
      await normalizeChatNotification(doc.ref, d);
      fixed++;
    }
  }

  return { scanned: q.size, fixed };
});
