import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buyer/features/home/splash_screen.dart';
// import 'package:abc_e_mart/buyer/features/profile/profile_page.dart';
// import 'package:abc_e_mart/buyer/features/store/store_detail_page.dart';
// import 'package:abc_e_mart/buyer/features/home/home_page_buyer.dart';
// import 'package:abc_e_mart/seller/features/home/home_page_seller.dart';
import 'package:abc_e_mart/admin/features/home/home_page_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABC e-Mart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
        home: const SplashScreen(),
        // home: const StoreDetailPage(),
        // home: HomePage(),
        // home: const HomePageSeller(),
        //home: const RegistrationWelcomePage(),
        //home: const ProfilePage(),
      

    );
  }
}
