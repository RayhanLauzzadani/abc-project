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

  /// Upload bukti ke Storage dan return [url, bytes].
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

    // (opsional) salin ringkas ke users/{uid}/notifications
    await _fs.collection('users').doc(user.uid)
      .collection('notifications').add({
        'title': 'Pengajuan Isi Saldo Terkirim',
        'body': 'Menunggu verifikasi admin.',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'wallet_topup_submitted',
        'paymentAppId': doc.id,
      });

    return doc.id;
  }

  /// Buat dokumen paymentApplications untuk TARIK SALDO (seller)
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
    return doc.id;
  }
}
