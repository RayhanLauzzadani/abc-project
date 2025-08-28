import * as functions from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

export const onRatingWritten = functions.onDocumentWritten("ratings/{ratingId}", async (event) => {
  const after = event.data?.after;
  if (!after) return;                      // delete: tidak dipakai

  const ratingDoc = after.data() as any;
  const storeId: string | undefined = ratingDoc.storeId;
  const orderId: string | undefined = ratingDoc.orderId;
  const raterUid: string | undefined = ratingDoc.userId;

  // 1) Recompute agregat store (aman, tidak memicu loop karena nulis ke /stores)
  if (storeId) {
    const snap = await db.collection("ratings").where("storeId", "==", storeId).get();
    const scores = snap.docs.map(d => Number(d.data().rating) || 0);
    const avg = scores.length ? (scores.reduce((a,b)=>a+b,0) / scores.length) : 0;
    await db.collection("stores").doc(storeId).set(
      { rating: avg, ratingCount: scores.length },
      { merge: true }
    );
  }

  // 2) Idempotent: stempel order buyerRated=true jika yang menilai memang pembelinya
  if (orderId && raterUid) {
    const orderRef = db.collection("orders").doc(orderId);
    await db.runTransaction(async t => {
      const os = await t.get(orderRef);
      if (!os.exists) return;
      const order = os.data() || {};
      if (String(order.buyerId || "") !== raterUid) return;   // bukan pembelinya
      if (order.buyerRated === true) return;                  // sudah distempel
      t.set(orderRef, { buyerRated: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    });
  }
});
