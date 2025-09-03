import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Provider
import 'seller/providers/seller_registration_provider.dart';

// Pages & gate
import 'buyer/features/home/splash_screen.dart';
import 'buyer/features/auth/login_page.dart';
import 'buyer/features/home/home_page_buyer.dart';
import 'seller/features/registration/registration_welcome_page.dart';

// Notifications services
import 'data/services/local_notification_service.dart';
import 'data/services/push_notification_service.dart';
import 'data/services/fcm_token_registrar.dart';

/// Top-level FCM background handler (wajib untuk Android).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // debugPrint('BG message: ${message.messageId} data=${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('id', null);

  // Daftarkan handler background sebelum runApp.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // iOS: agar notif terlihat saat app foreground.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, badge: true, sound: true,
  );

  // Inisialisasi local notifications (buat channel, minta izin iOS via plugin).
  await LocalNotificationService.instance.initialize();

  // Set listener FCM (foreground → local notif, tap handling, initial message).
  await PushNotificationService.instance.setup(
    onTap: (data) async {
      // TODO: arahkan user sesuai payload dari Cloud Functions
      // final type = (data['type'] ?? '') as String;
      // final orderId = (data['orderId'] ?? '') as String;
    },
  );

  // ⚠️ Penting: TIDAK minta permission notifikasi di sini,
  // supaya tidak memblok boot/splash. (Diminta di LoginPage.)

  // Jika sudah login saat cold start: attach token sekarang (guarded).
  final current = FirebaseAuth.instance.currentUser;
  if (current != null) {
    try {
      await FcmTokenRegistrar.register();
    } catch (_) {}
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SellerRegistrationProvider()),
      ],
      child: MaterialApp(
        title: 'ABC e-Mart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.dmSansTextTheme(),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashGate(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/registration_welcome': (context) => const RegistrationWelcomePage(),
        },
      ),
    );
  }
}
