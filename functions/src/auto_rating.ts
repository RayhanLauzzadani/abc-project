import * as functions from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

// Pastikan sudah ada inisialisasi admin SDK di salah satu file kamu (biasanya di index.ts)
if (!admin.apps.length) admin.initializeApp();

/**
 * Fungsi ini trigger setiap ada dokumen baru di 'ratings'
 * Dia akan hitung rata-rata rating & jumlah rating untuk storeId terkait,
 * lalu update ke stores/{storeId} secara otomatis.
 */
export const onRatingCreated = functions.onDocumentCreated("ratings/{ratingId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const newRating = snapshot.data();
  const storeId = newRating.storeId;
  if (!storeId) return;

  // Ambil semua rating untuk storeId ini
  const ratingsSnap = await admin.firestore().collection("ratings").where("storeId", "==", storeId).get();
  const ratings = ratingsSnap.docs.map(doc => doc.data().rating as number);
  const avgRating = ratings.length > 0
    ? ratings.reduce((a, b) => a + b, 0) / ratings.length
    : 0;

  // Update fields di stores/{storeId}
  await admin.firestore().collection("stores").doc(storeId).update({
    rating: avgRating,
    ratingCount: ratings.length
  });
});