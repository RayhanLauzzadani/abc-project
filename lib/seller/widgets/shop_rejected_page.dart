import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopRejectedPage extends StatelessWidget {
  final String reason;

  const ShopRejectedPage({super.key, required this.reason});

  static const colorPrimary = Color(0xFF1C55C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Pengajuan Toko Ditolak",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    color: const Color(0xFFDC2626),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),
                // Lottie looping
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    'assets/lottie/rejected.json', // Pastikan asset ada!
                    repeat: true,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.cancel, color: Colors.red, size: 80);
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "Maaf, pengajuan toko Anda ditolak",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color(0xFF232323),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Alasan penolakan:",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC2626),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reason.isNotEmpty ? reason : "-",
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: const Color(0xFF232323),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/registration_welcome');
                    },
                    child: Text(
                      "Isi Ulang Data Ajuan Toko",
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorPrimary, width: 1.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text(
                      "Kembali ke Profil Saya",
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
