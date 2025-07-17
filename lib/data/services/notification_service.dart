import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendOrUpdateChatNotification({
  required String receiverId,
  required String chatId,
  required String senderName,
  required String lastMessage,
  required String senderRole, // "buyer" atau "seller"
}) async {
  final notifRef = FirebaseFirestore.instance
      .collection('chatNotifications');

  // Cari notif chat_message aktif untuk user & chatId yg sama
  final exist = await notifRef
      .where('receiverId', isEqualTo: receiverId)
      .where('chatId', isEqualTo: chatId)
      .where('type', isEqualTo: 'chat_message')
      .where('isRead', isEqualTo: false)
      .limit(1)
      .get();

  final now = DateTime.now();

  if (exist.docs.isNotEmpty) {
    // Update notif lama (update lastMessage & timestamp)
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
    // Buat notif baru
    await notifRef.add({
      'receiverId': receiverId, // <- wajib
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
