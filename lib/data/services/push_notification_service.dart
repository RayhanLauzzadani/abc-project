import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'local_notification_service.dart';

typedef OnTapNotification = Future<void> Function(Map<String, dynamic> data);

/// Menghubungkan FirebaseMessaging dengan Local Notifications:
/// - Foreground: tampilkan via local notif
/// - onMessageOpenedApp / initialMessage: panggil callback onTap
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  Future<void> setup({required OnTapNotification onTap}) async {
    final messaging = FirebaseMessaging.instance;

    // Foreground messages → tampilkan local notif (jika ada notification)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notif = message.notification;
      if (notif != null) {
        final android = notif.android;
        final details = NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'Channel untuk notifikasi penting.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        );

        await LocalNotificationService.instance.plugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          notif.title,
          notif.body,
          details,
          payload: message.data.isEmpty ? null : message.data.toString(),
        );
      }
    });

    // App dibuka dari notifikasi (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await onTap(message.data);
    });

    // App dibuka dari terminated via notifikasi
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      await onTap(initial.data);
    }
  }
}
