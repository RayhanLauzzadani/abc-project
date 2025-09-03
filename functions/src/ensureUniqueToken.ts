// functions/src/ensureUniqueToken.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// JANGAN panggil initializeApp() lagi; sudah dipanggil di index.ts
const db = admin.firestore();

/**
 * Callable: klaim sebuah FCM token agar hanya menempel di user yang memanggil.
 * - Authed saja
 * - Hapus token tsb dari user lain
 * - Pastikan token tsb ada di dokumen user pemanggil (arrayUnion)
 *
 * Cara pakai (opsional, di klien setelah getToken/refresh):
 *   await FirebaseFunctions.instance.httpsCallable('ensureUniqueToken')({'token': token});
 */
export const ensureUniqueToken = functions.https.onCall(async (data, context) => {
  const callerUid = context.auth?.uid;
  const token = String(data?.token ?? "").trim();

  if (!callerUid) {
    throw new functions.https.HttpsError("unauthenticated", "Login required.");
  }
  if (!token) {
    throw new functions.https.HttpsError("invalid-argument", "token is required.");
  }

  // Cari semua user yang menyimpan token ini
  const snap = await db
    .collection("users")
    .where("fcmTokens", "array-contains", token)
    .get();

  let removed = 0;

  // Hapus dari user lain
  const batch = db.batch();
  snap.docs.forEach((doc) => {
    if (doc.id !== callerUid) {
      batch.update(doc.ref, {
        fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
      });
      removed++;
    }
  });

  // Pastikan user pemanggil menyimpan token tsb
  const callerRef = db.collection("users").doc(callerUid);
  batch.set(
    callerRef,
    { fcmTokens: admin.firestore.FieldValue.arrayUnion(token) },
    { merge: true }
  );

  await batch.commit();

  functions.logger.info("[ensureUniqueToken] claimed", {
    callerUid,
    tokenHash: token.slice(0, 6) + "…",
    removedFromOthers: removed,
  });

  return { ok: true, removedFromOthers: removed };
});

/**
 * Trigger protektif (opsional):
 * Saat users/{uid}.fcmTokens berubah, untuk semua token yang BARU ditambahkan,
 * hapus token tsb dari user lain agar tetap unik.
 *
 * Catatan: kita hanya reaksi ke "penambahan", bukan keseluruhan array,
 * untuk menghindari loop update yang tidak perlu.
 */
export const onUserFcmTokensUpdated = functions.firestore
  .document("users/{uid}")
  .onUpdate(async (change, ctx) => {
    const uid = ctx.params.uid as string;

    const before = new Set<string>(Array.isArray(change.before.get("fcmTokens")) ? change.before.get("fcmTokens") : []);
    const after  = new Set<string>(Array.isArray(change.after.get("fcmTokens"))  ? change.after.get("fcmTokens")  : []);

    // token yang baru ditambahkan
    const added = [...after].filter((t) => t && !before.has(t));
    if (added.length === 0) return;

    for (const token of added) {
      // Cari user lain yang masih menyimpan token ini
      const snap = await db
        .collection("users")
        .where("fcmTokens", "array-contains", token)
        .get();

      const batch = db.batch();
      let removed = 0;

      snap.docs.forEach((doc) => {
        if (doc.id !== uid) {
          batch.update(doc.ref, {
            fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
          });
          removed++;
        }
      });

      if (removed > 0) {
        await batch.commit();
        functions.logger.info("[onUserFcmTokensUpdated] deduped token", {
          uid,
          tokenHash: token.slice(0, 6) + "…",
          removedFromOthers: removed,
        });
      }
    }
  });
