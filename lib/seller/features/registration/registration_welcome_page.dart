import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Hapus jika tidak pakai SVG
// import 'package:flutter_svg/flutter_svg.dart';

class RegistrationWelcomePage extends StatelessWidget {
  const RegistrationWelcomePage({super.key, this.onNext});
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header (Back + Title)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1C55C0)),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Selamat Datang di ABC e-mart!",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ilustrasi/Logo Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE8F0FA), Color(0xFFD6E6F7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Email icon (PNG) kiri atas
                    Positioned(
                      top: 28,
                      left: 25,
                      child: Image.asset(
                        'assets/icons/registration/email_icon.png',
                        width: 35,
                        height: 35,
                      ),
                    ),
                    // Phone icon (PNG) kanan tengah
                    Positioned(
                      right: 28,
                      top: 100,
                      child: Image.asset(
                        'assets/icons/registration/telepon.png',
                        width: 33,
                        height: 33,
                      ),
                    ),
                    // Store icon (PNG) kiri bawah
                    Positioned(
                      left: 25,
                      bottom: 32,
                      child: Image.asset(
                        'assets/icons/registration/store_icon.png',
                        width: 78,
                        height: 44,
                      ),
                    ),
                    // Profile/User icon (PNG) kanan atas
                    Positioned(
                      right: 32,
                      top: 32,
                      child: Image.asset(
                        'assets/icons/registration/form.png',
                        width: 75,
                        height: 35,
                      ),
                    ),
                    // Logo di tengah
                    Center(
                      child: Image.asset(
                        'assets/icons/registration/abc_logo.png',
                        width: 88,
                        height: 88,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Text(
                "Untuk mendaftar sebagai penjual, mohon lengkapi informasi yang diperlukan",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF373E3C),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Spacer(),

            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: onNext ??
                      () {
                        // TODO: Navigasi ke halaman form pendaftaran seller berikutnya
                      },
                  child: const Text("Mulai Pendaftaran"),
                ),
              ),
            ),

            // Bottom indicator (opsional)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Center(
                child: SizedBox(
                  height: 4,
                  width: 42,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF222222),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
