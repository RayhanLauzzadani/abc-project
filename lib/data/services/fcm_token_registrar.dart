// lib/data/services/fcm_token_registrar.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Registers/unregisters the device FCM token on the user doc,
/// dan memastikan token tersebut unik (tidak menempel di akun lain).
class FcmTokenRegistrar {
  // Menyimpan subscription agar tidak terjadi double-listen
  static StreamSubscription<String>? _tokenRefreshSub;

  /// Panggil setelah user login / app cold start jika sudah login.
  static Future<void> register() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Android 13+ / iOS: minta izin notifikasi
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}

    // Ambil token saat ini
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null && token.isNotEmpty) {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Simpan token ke user (arrayUnion mendedup di sisi Firestore)
      await ref.set(
        {'fcmTokens': FieldValue.arrayUnion([token])},
        SetOptions(merge: true),
      );

      // Klaim token agar tidak “nempel” di user lain (idempoten & cepat)
      await _claimToken(token);
    }

    // Pastikan hanya SATU listener onTokenRefresh yang aktif
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub =
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        if (newToken.isEmpty) return;
        final u = FirebaseAuth.instance.currentUser;
        if (u == null) return;

        final ref = FirebaseFirestore.instance.collection('users').doc(u.uid);
        await ref.set(
          {'fcmTokens': FieldValue.arrayUnion([newToken])},
          SetOptions(merge: true),
        );

        // Klaim token baru (hapus dari akun lain jika ada)
        await _claimToken(newToken);
      } catch (_) {
        // Biarkan senyap; tidak memblokir alur aplikasi
      }
    });
  }

  /// Optional: panggil saat logout untuk melepas token dari akun ini.
  static Future<void> unregister() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Lepas listener agar bersih saat ganti akun
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmTokens': FieldValue.arrayRemove([token])});
      }
    } catch (_) {
      // Abaikan error kecil (mis. doc tidak ada / token null)
    }
  }

  /// Memanggil callable ensureUniqueToken agar token hanya menempel di user aktif.
  static Future<void> _claimToken(String token) async {
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('ensureUniqueToken');
      await fn.call(<String, dynamic>{'token': token});
    } catch (_) {
      // Jangan mengganggu UX jika callable gagal (jaringan, dll)
    }
  }
}
