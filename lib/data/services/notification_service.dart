import 'package:cloud_firestore/cloud_firestore.dart';

/// =======================================================
/// NOTIFICATION SERVICE (OOP, single entry point)
/// =======================================================
/// - Semua notifikasi order buyer↔seller lewat subcollection:
///   users/{recipientId}/notifications
/// - Chat notif tetap di top-level collection: chatNotifications
/// - Admin notif: admin_notifications
///
/// Pastikan Firestore Rules sudah mengizinkan field:
///   recipientId, senderId, orderId, type, title, body, archived, createdAt
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // ------------- Low-level helpers -------------

  Future<void> _addUserNotification({
    required String recipientId,
    required Map<String, dynamic> payload,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .collection('notifications')
        .add({
      ...payload,
      // default:
      'archived': payload['archived'] ?? false,
      'createdAt': payload['createdAt'] ?? FieldValue.serverTimestamp(),
    });
  }

  // ------------- ORDER (buyer ↔ seller) -------------

  Future<void> notifyOrderCreated({
    required String sellerId, // recipient
    required String buyerId,  // sender
    required String orderId,
    String? storeName,
    String? invoiceId,
  }) async {
    final storeText = (storeName != null && storeName.trim().isNotEmpty)
        ? ' untuk toko $storeName'
        : '';
    final body = (invoiceId != null && invoiceId.trim().isNotEmpty)
        ? 'Ada pesanan baru (Invoice: $invoiceId). Mohon ditinjau.'
        : 'Ada pesanan baru$storeText. Mohon ditinjau.';

    await _addUserNotification(
      recipientId: sellerId,
      payload: {
        'recipientId': sellerId,
        'senderId': buyerId,
        'orderId': orderId,
        'type': 'order_created',
        'title': 'Pesanan Baru',
        'body': body,
        'invoiceId': invoiceId,
      },
    );
  }

  Future<void> notifyOrderAccepted({
    required String buyerId,   // recipient
    required String sellerId,  // sender
    required String orderId,
    String? invoiceId,
  }) async {
    await _addUserNotification(
      recipientId: buyerId,
      payload: {
        'recipientId': buyerId,
        'senderId': sellerId,
        'orderId': orderId,
        'type': 'order_accepted',
        'title': 'Pesanan Diterima',
        'body': (invoiceId != null && invoiceId.trim().isNotEmpty)
            ? 'Pesanan (Invoice: $invoiceId) telah diterima penjual. Tunggu pengiriman ya.'
            : 'Pesanan kamu telah diterima penjual. Tunggu pengiriman ya.',
        'invoiceId': invoiceId,
      },
    );
  }

  Future<void> notifyOrderShipped({
    required String buyerId,   // recipient
    required String sellerId,  // sender
    required String orderId,
    String? invoiceId,
  }) async {
    await _addUserNotification(
      recipientId: buyerId,
      payload: {
        'recipientId': buyerId,
        'senderId': sellerId,
        'orderId': orderId,
        'type': 'order_shipped',
        'title': 'Pesanan Dikirim',
        'body': (invoiceId != null && invoiceId.trim().isNotEmpty)
            ? 'Pesanan (Invoice: $invoiceId) sedang dikirim.'
            : 'Pesanan kamu sedang dikirim.',
        'invoiceId': invoiceId,
      },
    );
  }

  Future<void> notifyOrderDelivered({
    required String sellerId,  // recipient
    required String buyerId,   // sender
    required String orderId,
    String? invoiceId,
    int? amountToSeller, // tampilkan nominal saldo jika ada
  }) async {
    final body = () {
      final base = (invoiceId != null && invoiceId.trim().isNotEmpty)
          ? 'Pembeli telah menerima pesanan (Invoice: $invoiceId).'
          : 'Pembeli telah menerima pesanan.';
      if (amountToSeller != null && amountToSeller > 0) {
        final rp = _formatRupiah(amountToSeller);
        return '$base Saldo Anda bertambah $rp.';
      }
      return '$base Saldo masuk ke dompet Anda.';
    }();

    await _addUserNotification(
      recipientId: sellerId,
      payload: {
        'recipientId': sellerId,
        'senderId': buyerId,
        'orderId': orderId,
        'type': 'order_delivered',
        'title': 'Pesanan Selesai',
        'body': body,
        'invoiceId': invoiceId,
      },
    );
  }

  // ------------- CHAT (top-level) -------------

  Future<void> sendOrUpdateChatNotification({
    required String receiverId,
    required String chatId,
    required String senderName,
    required String lastMessage,
    required String senderRole, // "buyer" | "seller"
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

  // ------------- ADMIN / WALLET -------------

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

  Future<void> notifyBuyerTopupApproved({
    required String buyerId,
    required int amount,
    required String paymentAppId,
  }) async {
    await _addUserNotification(
      recipientId: buyerId,
      payload: {
        'type': 'wallet_topup_approved',
        'title': 'Saldo Berhasil Ditambahkan',
        'body': 'Pengisian saldo Rp$amount telah disetujui admin.',
        'paymentAppId': paymentAppId,
        'recipientId': buyerId,
      },
    );
  }

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

  Future<void> notifySellerWithdrawApproved({
    required String sellerId,
    required int amount,
    required String requestId,
  }) async {
    await _addUserNotification(
      recipientId: sellerId,
      payload: {
        'type': 'seller_withdraw_approved',
        'title': 'Pencairan Dana Disetujui',
        'body': 'Pengajuan pencairan Rp$amount telah disetujui admin.',
        'requestId': requestId,
        'recipientId': sellerId,
      },
    );
  }

  Future<void> notifySellerWithdrawRejected({
    required String sellerId,
    required int amount,
    required String requestId,
    required String reason,
  }) async {
    await _addUserNotification(
      recipientId: sellerId,
      payload: {
        'type': 'seller_withdraw_rejected',
        'title': 'Pencairan Dana Ditolak',
        'body': 'Pengajuan pencairan Rp$amount ditolak. Alasan: $reason',
        'requestId': requestId,
        'recipientId': sellerId,
      },
    );
  }

  // ------------- utils -------------

  String _formatRupiah(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromRight = s.length - i;
      b.write(s[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    return 'Rp $b';
  }
}
