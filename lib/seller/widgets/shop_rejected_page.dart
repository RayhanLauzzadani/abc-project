import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:abc_e_mart/buyer/features/profile/profile_page.dart';
import 'package:abc_e_mart/seller/features/registration/registration_welcome_page.dart';

class ShopRejectedPage extends StatelessWidget {
  final String rejectionReason;

  const ShopRejectedPage({
    Key? key,
    required this.rejectionReason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Status Verifikasi",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 28),
              Lottie.asset(
                "assets/lottie/rejected.json",
                width: 110,
                height: 110,
                repeat: false,
              ),
              const SizedBox(height: 22),
              Text(
                "Ajuan Ditolak",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: const Color(0xFFD32F2F), // Warna merah
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Alasan Penolakan :",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF232323),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  rejectionReason,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: const Color(0xFF757575),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                "Jika Anda berkenan, Anda dapat mengajukan kembali perizinan toko dengan mengisi ulang data pengajuan toko secara lengkap dan sesuai.",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: const Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              // Button kembali ke profile
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2056D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst); // Atau bisa custom logic sesuai nav stackmu
                  },
                  child: Text(
                    "Kembali ke Profil Saya",
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Button isi ulang
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2056D3), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const RegistrationWelcomePage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "Isi Ulang Data Ajuan Toko",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF2056D3),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
