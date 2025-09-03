// lib/data/services/fcm_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_token_registrar.dart';

/// Satu-satunya tempat memasang onTokenRefresh listener.
/// - Panggil sekali di main(): await FcmService.instance.initialize()
/// - Saat token rotate & user login, kita panggil FcmTokenRegistrar.register()
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  StreamSubscription<String>? _tokenSub;

  Future<void> initialize() async {
    // Hindari double-listen
    await _tokenSub?.cancel();

    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // belum login
      await FcmTokenRegistrar.register();
    });
  }

  Future<void> dispose() async {
    await _tokenSub?.cancel();
    _tokenSub = null;
  }
}
