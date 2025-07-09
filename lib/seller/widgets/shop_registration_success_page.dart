import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:abc_e_mart/seller/widgets/shop_verification_status_page.dart';

class ShopRegistrationSuccessPage extends StatelessWidget {
  const ShopRegistrationSuccessPage({super.key});

  static const colorPrimary = Color(0xFF1C55C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 29),
              Text(
                "Pendaftaran Toko",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF373E3C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 95),
              SizedBox(
                height: 150,
                width: 150,
                child: Lottie.asset(
                  'assets/lottie/success_check.json',
                  repeat: false,
                ),
              ),
              const SizedBox(height: 37),
              Text(
                "Data Toko Berhasil Dikirim",
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Informasi toko Anda sedang dalam proses verifikasi. Kami akan memberi notifikasi setelah data diverifikasi oleh tim admin.",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: const Color(0xFF9A9A9A),
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 44),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Kembali ke Profil Saya",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShopVerificationStatusPage(),
                    ),
                  );
                },
                child: Text(
                  "Lihat Status Verifikasi",
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
