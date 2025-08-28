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
  /// (Tetap dipakai oleh WaitingPaymentWalletPage)
  Future<({String url, int bytes, String name})> uploadProof({
    required File file,
    required String filenameHint, // mis. "topup_ORD123.jpg"
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User belum login');

    final ext = filenameHint.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final path = 'payment_proofs/$uid/${DateTime.now().millisecondsSinceEpoch}_$filenameHint';
    final task = await _st.ref(path).putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    final url = await task.ref.getDownloadURL();
    final bytes = (await file.length());
    return (url: url, bytes: bytes, name: filenameHint);
  }

  /// Upload **bukti transfer admin** untuk withdrawal ke:
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
    final bytes = (await file.length());
    return (url: url, bytes: bytes, name: name);
  }

  // ---------------------------------------------------------------------------
  // TOPUP (tetap kompatibel dengan alur kamu)
  // ---------------------------------------------------------------------------
  /// Buat dokumen paymentApplications untuk TOPUP
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
      'method': methodLabel,
      'amount': amountTopUp,           // jumlah isi saldo
      'fee': adminFee,
      'totalPaid': totalPaid,
      'proof': {
        'url': proof.url,
        'name': proof.name,
        'bytes': proof.bytes,
      },
    };

    final doc = await _fs.collection('paymentApplications').add(data);

    // Notif ringkas ke user (riwayat/center user)
    await _fs.collection('users').doc(user.uid)
      .collection('notifications').add({
        'title': 'Pengajuan Isi Saldo Terkirim',
        'body': 'Menunggu verifikasi admin.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'wallet_topup_submitted',
        'paymentAppId': doc.id,
      });

    // (opsional) Notif admin – kalau kamu mau admin juga diingatkan untuk topup
    await _fs.collection('admin_notifications').add({
      'title': 'Pengajuan Isi Saldo',
      'body': 'Pembeli mengajukan isi saldo.',
      'type': 'wallet_topup',
      'paymentAppId': doc.id,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ---------------------------------------------------------------------------
  // WITHDRAWAL (fokus kita)
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
      'proof': null, // nanti admin unggah bukti transfer → update field ini
    };

    final doc = await _fs.collection('paymentApplications').add(data);

    // Notif ringkas ke seller (riwayat/center user)
    await _fs.collection('users').doc(ownerId)
      .collection('notifications').add({
        'title': 'Pengajuan Penarikan Dikirim',
        'body': 'Menunggu verifikasi admin.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'wallet_withdraw_submitted',
        'paymentAppId': doc.id,
      });

    // Notif ke admin (dipakai pusat notifikasi admin)
    await _fs.collection('admin_notifications').add({
      'title': 'Pengajuan Tarik Saldo',
      'body': 'Ada penjual mengajukan pencairan dana.',
      'type': 'wallet_withdrawal',
      'paymentAppId': doc.id,
      'storeId': storeId,
      'ownerId': ownerId,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ---------------------------------------------------------------------------
  // ADMIN ACTIONS (WITHDRAWAL)
  // ---------------------------------------------------------------------------
  /// Admin: APPROVE withdrawal
  /// - Kurangi wallet.available penjual sebesar `amount`
  /// - Simpan bukti transfer admin (opsional)
  /// - Update status ajuan
  /// - Kirim notif ke seller: berhasil
  Future<void> approveWithdrawalApplication({
    required String applicationId,
    ({String url, int bytes, String name})? adminProof,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) throw Exception('Admin belum login');

    await _fs.runTransaction((tx) async {
      final appRef  = _fs.collection('paymentApplications').doc(applicationId);
      final appSnap = await tx.get(appRef);
      if (!appSnap.exists) throw Exception('Ajuan tidak ditemukan');

      final data = appSnap.data() as Map<String, dynamic>;
      if ((data['type'] as String?) != 'withdrawal') throw Exception('Tipe ajuan bukan withdrawal');
      if ((data['status'] as String?) != 'pending')    throw Exception('Ajuan sudah diproses');

      final ownerId = data['ownerId'] as String?;
      final amount  = (data['amount'] as num?)?.toInt() ?? 0;
      if (ownerId == null) throw Exception('ownerId kosong');

      final userRef = _fs.collection('users').doc(ownerId);

      // - Kurangi saldo di users/{uid}/wallet.available
      tx.update(userRef, {
        'wallet.available': FieldValue.increment(-amount),
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });

      // Update status + bukti (kalau ada)
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

    // Ambil ulang aplikasi untuk kirim notif (di luar tx agar simple)
    final app = await _fs.collection('paymentApplications').doc(applicationId).get();
    final ownerId = app.data()?['ownerId'] as String?;

    if (ownerId != null) {
      // Notif ke seller
      await _fs.collection('users').doc(ownerId)
        .collection('notifications').add({
          'title': 'Pencairan Dana Berhasil',
          'body': 'Permintaan penarikan saldo telah disetujui.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'wallet_withdraw_approved',
          'paymentAppId': applicationId,
        });

      // (opsional) Notif admin audit
      await _fs.collection('admin_notifications').add({
        'title': 'Pencairan Dana Disetujui',
        'body': 'Ajuan pencairan telah diverifikasi.',
        'type': 'wallet_withdrawal_approved',
        'paymentAppId': applicationId,
        'ownerId': ownerId,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Admin: REJECT withdrawal
  /// - Update status + alasan
  /// - Kirim notif ke seller: ditolak (beserta alasan)
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
      // Notif ke seller
      await _fs.collection('users').doc(ownerId)
        .collection('notifications').add({
          'title': 'Pencairan Dana Ditolak',
          'body': 'Alasan: $reason',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'wallet_withdraw_rejected',
          'paymentAppId': applicationId,
        });

      // (opsional) Notif admin audit
      await _fs.collection('admin_notifications').add({
        'title': 'Penolakan Pencairan Dana',
        'body': 'Ajuan pencairan ditolak.',
        'type': 'wallet_withdrawal_rejected',
        'paymentAppId': applicationId,
        'ownerId': ownerId,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // ---------------------------------------------------------------------------
  // (Opsional) Admin actions untuk TOPUP disini juga bisa kamu tambahkan
  // ---------------------------------------------------------------------------
  /// Admin: APPROVE topup → tambah saldo buyer
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

      tx.update(userRef, {
        'wallet.available': FieldValue.increment(amount),
        'wallet.updatedAt': FieldValue.serverTimestamp(),
      });

      tx.update(appRef, {
        'status': 'approved',
        'verifiedBy': adminUid,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final app = await _fs.collection('paymentApplications').doc(applicationId).get();
    final buyerId = app.data()?['buyerId'] as String?;

    if (buyerId != null) {
      await _fs.collection('users').doc(buyerId)
        .collection('notifications').add({
          'title': 'Isi Saldo Berhasil',
          'body': 'Saldo telah ditambahkan ke dompet kamu.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'wallet_topup_approved',
          'paymentAppId': applicationId,
        });
    }
  }

  /// Admin: REJECT topup
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
      await _fs.collection('users').doc(buyerId)
        .collection('notifications').add({
          'title': 'Isi Saldo Ditolak',
          'body': 'Alasan: $reason',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'wallet_topup_rejected',
          'paymentAppId': applicationId,
        });
    }
  }
}
