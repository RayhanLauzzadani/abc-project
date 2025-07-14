import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import Provider dan page utama
import 'seller/providers/seller_registration_provider.dart';

import 'buyer/features/home/splash_screen.dart';
import 'buyer/features/auth/login_page.dart';
import 'buyer/features/home/home_page_buyer.dart';
// import 'package:abc_e_mart/admin/features/home/home_page_admin.dart';
// import page lain jika ingin tambahkan ke routes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SellerRegistrationProvider()),
        // Provider lain bisa ditambah di sini
      ],
      child: MaterialApp(
        title: 'ABC e-Mart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.dmSansTextTheme(),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
                // home: const HomePageAdmin(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          // Tambahkan route lain jika perlu
        },
      ),
    );
  }
}
