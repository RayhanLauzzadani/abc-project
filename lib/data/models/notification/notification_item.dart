// lib/data/models/notification/notification_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;      // 'chat_message', 'order_update', etc.
  final String? chatId;   // Khusus notif chat
  final String? lastMessage; // Untuk update isi pesan terakhir di notif

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.chatId,
    this.lastMessage,
  });

  factory NotificationItem.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationItem(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? '',
      chatId: data['chatId'],
      lastMessage: data['lastMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type,
      'chatId': chatId,
      'lastMessage': lastMessage,
    };
  }
}