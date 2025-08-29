import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Intl (locale id)
import 'package:intl/date_symbol_data_local.dart';

// Provider
import 'seller/providers/seller_registration_provider.dart';

// Pages & gate
import 'buyer/features/home/splash_screen.dart';
import 'buyer/features/auth/login_page.dart';
import 'buyer/features/home/home_page_buyer.dart';
import 'seller/features/registration/registration_welcome_page.dart';
// import 'admin/features/home/home_page_admin.dart'; // tidak wajib di-import di sini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id', null);
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
        // Gunakan gate reaktif yang tidak melakukan push/pop
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
