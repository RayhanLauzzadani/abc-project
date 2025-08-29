import 'package:cloud_firestore/cloud_firestore.dart';

/// CHAT: kirim / update notifikasi chat
Future<void> sendOrUpdateChatNotification({
  required String receiverId,
  required String chatId,
  required String senderName,
  required String lastMessage,
  required String senderRole, // "buyer" atau "seller"
}) async {
  final notifRef = FirebaseFirestore.instance.collection('chatNotifications');

  final exist = await notifRef
      .where('receiverId', isEqualTo: receiverId)
      .where('chatId', isEqualTo: chatId)
      .where('type', isEqualTo: 'chat_message')
      .where('isRead', isEqualTo: false)
      .limit(1)
      .get();

  final now = DateTime.now();

  if (exist.docs.isNotEmpty) {
    await exist.docs.first.reference.update({
      'title': senderRole == "buyer"
          ? "Pesan baru dari Pembeli"
          : "Pesan baru dari Penjual",
      'body': "$senderName: $lastMessage",
      'lastMessage': lastMessage,
      'timestamp': now,
      'isRead': false,
    });
  } else {
    await notifRef.add({
      'receiverId': receiverId,
      'title': senderRole == "buyer"
          ? "Pesan baru dari Pembeli"
          : "Pesan baru dari Penjual",
      'body': "$senderName: $lastMessage",
      'chatId': chatId,
      'lastMessage': lastMessage,
      'timestamp': now,
      'isRead': false,
      'type': 'chat_message',
    });
  }
}

/// BUYER submit TOPUP -> notif ke ADMIN
Future<void> notifyAdminTopupSubmitted({
  required String paymentAppId,
  required String buyerId,
  required String? buyerEmail,
  required int amount,
  required int adminFee,
  required int totalPaid,
  String? methodLabel,
}) async {
  final m = methodLabel?.trim();
  final via = (m != null && m.isNotEmpty) ? " via $m" : "";

  await FirebaseFirestore.instance.collection('admin_notifications').add({
    'type': 'wallet_topup_submitted',
    'title': 'Pengajuan Isi Saldo',
    'body': 'Pembeli ${buyerEmail ?? buyerId} mengajukan isi saldo Rp$amount$via.',
    'buyerId': buyerId,
    'buyerEmail': buyerEmail,
    'paymentAppId': paymentAppId,
    'amount': amount,
    'adminFee': adminFee,
    'totalPaid': totalPaid,
    'methodLabel': methodLabel,
    'isRead': false,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// BUYER: topup disetujui admin
Future<void> notifyBuyerTopupApproved({
  required String buyerId,
  required int amount,
  required String paymentAppId,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(buyerId)
      .collection('notifications')
      .add({
    'type': 'wallet_topup_approved',
    'title': 'Saldo Berhasil Ditambahkan',
    'body': 'Pengisian saldo Rp$amount telah disetujui admin.',
    'paymentAppId': paymentAppId,
    'isRead': false,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// ADMIN: ada pengajuan withdraw dari seller
Future<void> notifyAdminWithdrawSubmitted({
  required String requestId,
  required String sellerId,
  required String storeId,
  required int amount,
  String? storeName,
}) async {
  final who = (storeName != null && storeName.trim().isNotEmpty)
      ? storeName
      : 'Penjual $sellerId';

  await FirebaseFirestore.instance.collection('admin_notifications').add({
    'type': 'wallet_withdraw_submitted',
    'title': 'Pengajuan Pencairan Saldo',
    'body': '$who mengajukan pencairan Rp$amount.',
    'requestId': requestId,
    'sellerId': sellerId,
    'storeId': storeId,
    'storeName': storeName,
    'amount': amount,
    'isRead': false,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// SELLER: pencairan disetujui
Future<void> notifySellerWithdrawApproved({
  required String sellerId,
  required int amount,
  required String requestId,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(sellerId)
      .collection('notifications')
      .add({
    // >>> selaraskan dengan filter di UI seller
    'type': 'seller_withdraw_approved',
    'title': 'Pencairan Dana Disetujui',
    'body': 'Pengajuan pencairan Rp$amount telah disetujui admin.',
    'requestId': requestId,
    'isRead': false,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// SELLER: pencairan ditolak (optional tapi bagus ada)
Future<void> notifySellerWithdrawRejected({
  required String sellerId,
  required int amount,
  required String requestId,
  required String reason,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(sellerId)
      .collection('notifications')
      .add({
    'type': 'seller_withdraw_rejected',
    'title': 'Pencairan Dana Ditolak',
    'body': 'Pengajuan pencairan Rp$amount ditolak. Alasan: $reason',
    'requestId': requestId,
    'isRead': false,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
