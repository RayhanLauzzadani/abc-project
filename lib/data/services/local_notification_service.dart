// lib/data/services/local_notification_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Menangani pembuatan channel & inisialisasi local notifications.
/// Channel id HARUS sama dengan default channel di AndroidManifest:
///   android:value="high_importance_channel"
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // <- harus sama dgn Manifest & payload FCM
    'High Importance Notifications',
    description: 'Channel untuk notifikasi penting.',
    importance: Importance.high,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin _flnp =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _flnp;

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flnp.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        // Tangani klik notifikasi lokal (jika dipakai)
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Buat channel (Android 8+)
    final androidImpl = _flnp
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_channel);

    // iOS: minta izin via plugin (Android 13+ handled via FirebaseMessaging di tempat lain)
    if (Platform.isIOS) {
      await _flnp
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }
}

/// Diperlukan oleh flutter_local_notifications untuk background tap handler.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('Notification tapped in background: ${response.payload}');
  }
}
