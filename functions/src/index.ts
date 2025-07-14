import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const notifyAdminOnShopApplication = functions.firestore
  .document('shopApplications/{docId}')
  .onCreate(async (snap, context) => {
    const shopAppData = snap.data();
    const docId = context.params.docId;

    // Buat dokumen notifikasi ke admin
    await admin.firestore().collection('admin_notifications').add({
      title: 'Pengajuan Toko Baru',
      body: `Ada pengajuan toko baru dari ${shopAppData.owner?.nama || 'User baru'}.`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      type: 'store_submission',
      shopApplicationId: docId,
      isRead: false,
      status: shopAppData.status || 'pending',
    });

    return null;
  });
