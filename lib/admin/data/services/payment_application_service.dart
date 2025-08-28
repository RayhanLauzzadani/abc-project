import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PaymentApplicationService {
  PaymentApplicationService._();
  static final instance = PaymentApplicationService._();

  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _st  = FirebaseStorage.instance;

  /// Upload bukti transfer (admin) untuk withdrawal.
  /// Disimpan ke: withdraw_proofs/{ownerId}/{timestamp}_<hint>
  Future<({String url, int bytes, String name})> uploadProof({
    required File file,
    required String filenameHint,
    String? ownerId, // opsional: kalau null, pakai uid admin sebagai folder
  }) async {
    final who = ownerId ?? (_auth.currentUser?.uid ?? 'unknown');
    final ts  = DateTime.now().millisecondsSinceEpoch;
    final name = '${ts}_$filenameHint';
    final ref  = _st.ref('withdraw_proofs/$who/$name');

    final bytes = await file.length();
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/${name.split('.').last.toLowerCase()}'),
    );
    final url = await ref.getDownloadURL();
    return (url: url, bytes: bytes, name: name);
  }

  // ------------------------
  // Helpers: push notif ke SELLER (users/{uid}/notifications)
  // ------------------------
  Future<void> _pushSellerNotif({
    required String ownerId,
    required String title,
    required String body,
    required String type, // 'seller_withdraw_approved' | 'seller_withdraw_rejected'
    required String paymentAppId,
  }) async {
    await _fs
        .collection('users')
        .doc(ownerId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': type,
      'paymentAppId': paymentAppId,
    });
  }

  /// ===== ADMIN: APPROVE TOPUP =====
  Future<void> approveTopUpApplication({required String applicationId}) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    await _fs.runTransaction((tx) async {
      final appRef  = _fs.collection('paymentApplications').doc(applicationId);
      final appSnap = await tx.get(appRef);
      if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');

      final data = appSnap.data() as Map<String, dynamic>;
      if ((data['type'] as String?) != 'topup') throw Exception('Tipe ajuan bukan topup');
      if ((data['status'] as String?) != 'pending') throw Exception('Ajuan sudah diproses');

      final buyerId = data['buyerId'] as String?;
      final amount  = (data['amount'] as num?)?.toInt() ?? 0;
      if (buyerId == null) throw Exception('buyerId kosong');

      final userRef = _fs.collection('users').doc(buyerId);

      // + Tambahkan saldo
      tx.update(userRef, {
        'wallet.available': FieldValue.increment(amount),
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });

      // Update status ajuan
      tx.update(appRef, {
        'status': 'approved',
        'verifiedBy': adminUid,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // (Opsional) kirim notif ke buyer kalau kamu punya halaman buyer notif topup.
    // Tidak membuat admin_notifications di sini.
  }

  Future<void> rejectTopUpApplication({
    required String applicationId,
    required String reason,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    final appRef  = _fs.collection('paymentApplications').doc(applicationId);
    final appSnap = await appRef.get();
    if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');
    final data = appSnap.data() as Map<String, dynamic>;
    if ((data['type'] as String?) != 'topup') throw Exception('Tipe bukan topup');

    await appRef.update({
      'status': 'rejected',
      'rejectionReason': reason,
      'verifiedBy': adminUid,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // (Opsional) kirim notif ke buyer. Jangan ke admin_notifications.
  }

  /// ===== ADMIN: APPROVE WITHDRAWAL =====
  Future<void> approveWithdrawalApplication({
    required String applicationId,
    ({String url, int bytes, String name})? adminProof,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    String? ownerId;
    int amount = 0;

    await _fs.runTransaction((tx) async {
      final appRef  = _fs.collection('paymentApplications').doc(applicationId);
      final appSnap = await tx.get(appRef);
      if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');

      final data = appSnap.data() as Map<String, dynamic>;
      if ((data['type'] as String?) != 'withdrawal') throw Exception('Tipe ajuan bukan withdrawal');
      if ((data['status'] as String?) != 'pending')    throw Exception('Ajuan sudah diproses');

      ownerId = data['ownerId'] as String?;
      amount  = (data['amount'] as num?)?.toInt() ?? 0;
      if (ownerId == null) throw Exception('ownerId kosong');

      final userRef = _fs.collection('users').doc(ownerId);

      // - Kurangi saldo
      tx.update(userRef, {
        'wallet.available': FieldValue.increment(-amount),
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });

      // Update status + bukti transfer
      final update = <String, dynamic>{
        'status': 'approved',
        'verifiedBy': adminUid,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (adminProof != null) {
        update['proof'] = {
          'url':   adminProof.url,
          'name':  adminProof.name,
          'bytes': adminProof.bytes,
        };
      }
      tx.update(appRef, update);
    });

    // >>> Kirim NOTIF ke SELLER, bukan ke admin_notifications!
    await _pushSellerNotif(
      ownerId: ownerId!,
      title: 'Pencairan Dana Disetujui',
      body: 'Ajuan pencairan telah diverifikasi.',
      type: 'seller_withdraw_approved',
      paymentAppId: applicationId,
    );
  }

  Future<void> rejectWithdrawalApplication({
    required String applicationId,
    required String reason,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    String? ownerId;

    final appRef  = _fs.collection('paymentApplications').doc(applicationId);
    final appSnap = await appRef.get();
    if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');
    final data = appSnap.data() as Map<String, dynamic>;
    if ((data['type'] as String?) != 'withdrawal') throw Exception('Tipe bukan withdrawal');

    ownerId = data['ownerId'] as String?;

    await appRef.update({
      'status': 'rejected',
      'rejectionReason': reason,
      'verifiedBy': adminUid,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // >>> Kirim NOTIF ke SELLER, bukan ke admin_notifications!
    if (ownerId != null && ownerId!.isNotEmpty) {
      await _pushSellerNotif(
        ownerId: ownerId!,
        title: 'Pencairan Dana Ditolak',
        body: reason.isNotEmpty ? reason : 'Ajuan pencairan ditolak.',
        type: 'seller_withdraw_rejected',
        paymentAppId: applicationId,
      );
    }
  }
}
