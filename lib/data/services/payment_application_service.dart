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

  // ---------------------------------------------------------------------------
  // UPLOAD PROOF
  // ---------------------------------------------------------------------------

  /// Upload bukti **pembeli** (TOPUP) ke:
  ///   payment_proofs/{uid}/{timestamp}_<hint>
  /// (Dipakai di WaitingPaymentWalletPage)
  Future<({String url, int bytes, String name})> uploadProof({
    required File file,
    required String filenameHint, // mis. "topup_ORD123.jpg"
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User belum login');

    final ext = filenameHint.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final name = '${DateTime.now().millisecondsSinceEpoch}_$filenameHint';
    final path = 'payment_proofs/$uid/$name';

    final task = await _st.ref(path).putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    final url = await task.ref.getDownloadURL();
    final bytes = await file.length();
    return (url: url, bytes: bytes, name: name);
  }

  /// Upload **bukti transfer admin** (WITHDRAW) ke:
  ///   withdraw_proofs/{ownerId}/{timestamp}_<hint>
  Future<({String url, int bytes, String name})> uploadAdminWithdrawProof({
    required File file,
    required String filenameHint, // mis. "withdraw_APPID123.jpg"
    required String ownerId,
  }) async {
    final ext = filenameHint.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final name = '${DateTime.now().millisecondsSinceEpoch}_$filenameHint';
    final path = 'withdraw_proofs/$ownerId/$name';

    final task = await _st.ref(path).putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    final url = await task.ref.getDownloadURL();
    final bytes = await file.length();
    return (url: url, bytes: bytes, name: name);
  }

  // ---------------------------------------------------------------------------
  // TOPUP
  // ---------------------------------------------------------------------------

  /// Buyer klik "Saya sudah bayar" → buat dokumen ajuan TOPUP (pending).
  /// return: docId
  Future<String> createTopUpApplication({
    required String orderId,
    required int amountTopUp, // jumlah isi saldo (tanpa fee)
    required int adminFee,
    required int totalPaid,
    required String methodLabel,
    required ({String url, int bytes, String name}) proof,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User belum login');

    final data = <String, dynamic>{
      'type': 'topup',                 // 'topup' | 'withdrawal'
      'status': 'pending',             // 'pending' | 'approved' | 'rejected'
      'orderId': orderId,
      'buyerId': user.uid,
      'buyerEmail': user.email,
      'submittedAt': FieldValue.serverTimestamp(),
      'methodLabel': methodLabel,
      'amount': amountTopUp,           // jumlah isi saldo
      'fee': adminFee,
      'totalPaid': totalPaid,
      'proof': {
        'url': proof.url,
        'name': proof.name,
        'bytes': proof.bytes,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await _fs.collection('paymentApplications').add(data);

    // Notif ke buyer (riwayat user)
    await _fs
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
      'title': 'Pengajuan Isi Saldo Terkirim',
      'body': 'Menunggu verifikasi admin.',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'wallet_topup_submitted',
      'paymentAppId': doc.id,
    });

    // Notif ke ADMIN (ditampilkan oranye di UI admin)
    await _fs.collection('admin_notifications').add({
      'title': 'Pengajuan Isi Saldo',
      'body': 'Pembeli mengajukan isi saldo.',
      'type': 'wallet_topup_submitted', // <- konsisten
      'paymentAppId': doc.id,
      'buyerId': user.uid,
      'buyerEmail': user.email,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// ADMIN: Approve TOPUP → tambah saldo buyer + notif ke buyer
  Future<void> approveTopUpApplication({required String applicationId}) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    String buyerId = '';
    int amount = 0;

    await _fs.runTransaction((tx) async {
      final appRef  = _fs.collection('paymentApplications').doc(applicationId);
      final appSnap = await tx.get(appRef);
      if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');

      final data = appSnap.data() as Map<String, dynamic>;
      if ((data['type'] as String?) != 'topup') throw Exception('Tipe ajuan bukan topup');
      if ((data['status'] as String?) != 'pending') throw Exception('Ajuan sudah diproses');

      buyerId = data['buyerId'] as String? ?? '';
      amount  = (data['amount'] as num?)?.toInt() ?? 0;
      if (buyerId.isEmpty) throw Exception('buyerId kosong');

      final userRef = _fs.collection('users').doc(buyerId);

      // Tambah saldo
      tx.update(userRef, {
        'wallet.available': FieldValue.increment(amount),
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });

      // Update status
      tx.update(appRef, {
        'status': 'approved',
        'verifiedBy': adminUid,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // Notif ke buyer (hasil)
    if (buyerId.isNotEmpty) {
      await _fs
          .collection('users')
          .doc(buyerId)
          .collection('notifications')
          .add({
        'title': 'Isi Saldo Berhasil',
        'body': 'Saldo telah ditambahkan ke dompet kamu.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'wallet_topup_approved',
        'paymentAppId': applicationId,
      });
    }
  }

  /// ADMIN: Reject TOPUP
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

    final buyerId = data['buyerId'] as String?;
    if (buyerId != null) {
      await _fs
          .collection('users')
          .doc(buyerId)
          .collection('notifications')
          .add({
        'title': 'Isi Saldo Ditolak',
        'body': 'Alasan: $reason',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'wallet_topup_rejected',
        'paymentAppId': applicationId,
      });
    }
  }

  // ---------------------------------------------------------------------------
  // WITHDRAWAL
  // ---------------------------------------------------------------------------

  /// Seller mengajukan penarikan saldo (withdrawal)
  Future<String> createWithdrawalApplication({
    required String ownerId,
    required String storeId,
    required String bankName,
    required String accountNumber,
    required int amountRequested, // nominal diajukan
    required int adminFee,
    required int received,        // bersih diterima = amountRequested - adminFee
  }) async {
    final data = <String, dynamic>{
      'type': 'withdrawal',
      'status': 'pending',
      'storeId': storeId,
      'ownerId': ownerId,
      'submittedAt': FieldValue.serverTimestamp(),
      'bankName': bankName,
      'accountNumber': accountNumber,
      'amount': amountRequested,
      'fee': adminFee,
      'received': received,
      'proof': null, // admin upload bukti transfer → update field ini
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await _fs.collection('paymentApplications').add(data);

    // Notif ke seller (riwayat user)
    await _fs
        .collection('users')
        .doc(ownerId)
        .collection('notifications')
        .add({
      'title': 'Pengajuan Penarikan Dikirim',
      'body': 'Menunggu verifikasi admin.',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'wallet_withdraw_submitted',
      'paymentAppId': doc.id,
    });

    // Notif ke admin (ditampilkan biru/indigo di UI admin)
    await _fs.collection('admin_notifications').add({
      'title': 'Pengajuan Tarik Saldo',
      'body': 'Ada penjual mengajukan pencairan dana.',
      'type': 'wallet_withdraw_submitted', // konsisten
      'paymentAppId': doc.id,
      'storeId': storeId,
      'ownerId': ownerId,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// ADMIN: Approve withdrawal
  /// - Kurangi wallet.available penjual
  /// - Simpan bukti transfer admin (opsional)
  /// - Update status
  /// - Notif ke seller (berhasil)
  Future<void> approveWithdrawalApplication({
    required String applicationId,
    ({String url, int bytes, String name})? adminProof,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    String ownerId = '';
    int amount = 0;

    await _fs.runTransaction((tx) async {
      final appRef  = _fs.collection('paymentApplications').doc(applicationId);
      final appSnap = await tx.get(appRef);
      if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');

      final data = appSnap.data() as Map<String, dynamic>;
      if ((data['type'] as String?) != 'withdrawal') throw Exception('Tipe ajuan bukan withdrawal');
      if ((data['status'] as String?) != 'pending')    throw Exception('Ajuan sudah diproses');

      ownerId = data['ownerId'] as String? ?? '';
      amount  = (data['amount'] as num?)?.toInt() ?? 0;
      if (ownerId.isEmpty) throw Exception('ownerId kosong');

      final userRef = _fs.collection('users').doc(ownerId);

      // Kurangi saldo
      tx.update(userRef, {
        'wallet.available': FieldValue.increment(-amount),
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });

      // Update status + bukti (jika ada)
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

    // Notif ke seller (hasil)
    if (ownerId.isNotEmpty) {
      await _fs
          .collection('users')
          .doc(ownerId)
          .collection('notifications')
          .add({
        'title': 'Pencairan Dana Berhasil',
        'body': 'Permintaan penarikan saldo telah disetujui.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'wallet_withdraw_approved',
        'paymentAppId': applicationId,
      });
    }

    // ⛔️ Tidak menulis admin_notifications lagi saat approved
    // agar tidak tampil di UI admin.
  }

  /// ADMIN: Reject withdrawal
  /// - Update status + alasan
  /// - Notif ke seller (ditolak)
  Future<void> rejectWithdrawalApplication({
    required String applicationId,
    required String reason,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    final appRef  = _fs.collection('paymentApplications').doc(applicationId);
    final appSnap = await appRef.get();
    if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');
    final data = appSnap.data() as Map<String, dynamic>;
    if ((data['type'] as String?) != 'withdrawal') throw Exception('Tipe bukan withdrawal');

    await appRef.update({
      'status': 'rejected',
      'rejectionReason': reason,
      'verifiedBy': adminUid,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final ownerId = data['ownerId'] as String?;
    if (ownerId != null) {
      await _fs
          .collection('users')
          .doc(ownerId)
          .collection('notifications')
          .add({
        'title': 'Pencairan Dana Ditolak',
        'body': 'Alasan: $reason',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'wallet_withdraw_rejected',
        'paymentAppId': applicationId,
      });
    }

    // ⛔️ Tidak menulis admin_notifications lagi saat rejected,
    // supaya tidak muncul di UI admin.
  }
}
