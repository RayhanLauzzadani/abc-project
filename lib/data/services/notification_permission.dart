import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermission {
  static const _askedFlagKey = 'notif_perm_asked_once';

  /// Minta izin notifikasi hanya sekali (non-blocking dari pemanggil).
  static Future<void> askOnceIfNeeded() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final alreadyAsked = sp.getBool(_askedFlagKey) ?? false;
      if (alreadyAsked) return;

      await FirebaseMessaging.instance.requestPermission(); // aman dipanggil berulang
      await sp.setBool(_askedFlagKey, true);
    } catch (_) {/* ignore */}
  }
}
