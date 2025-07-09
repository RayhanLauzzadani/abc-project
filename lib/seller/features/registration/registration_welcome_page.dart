import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/registration_app_bar.dart';
import 'package:abc_e_mart/seller/features/registration/verification_form_page.dart';

class RegistrationWelcomePage extends StatelessWidget {
  const RegistrationWelcomePage({super.key, this.onNext});
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = 235.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(79), // 56+23
        child: RegistrationAppBar(
          title: "Selamat Datang di ABC e-mart!", // <-- Tambahkan title
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ILUSTRASI (Fully Responsive)
            Container(
              width: screenWidth,
              height: bannerHeight,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.21],
                  colors: [Color(0xFFFFFFFF), Color(0xFFC8DBFD)],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Logo transparan kiri bawah
                  Positioned(
                    top: bannerHeight * 0.45,
                    left: screenWidth * 0.06,
                    child: Image.asset(
                      'assets/icons/registration/logo_transparan.png',
                      width: screenWidth * 0.16,
                    ),
                  ),
                  // Logo transparan kanan bawah
                  Positioned(
                    top: bannerHeight * 0.41,
                    right: screenWidth * 0.06,
                    child: Image.asset(
                      'assets/icons/registration/logo_transparan.png',
                      width: screenWidth * 0.085,
                    ),
                  ),
                  // Logo transparan (rotate) kanan bawah
                  Positioned(
                    top: bannerHeight * 0.71,
                    right: screenWidth * 0.09,
                    child: Transform.rotate(
                      angle: math.pi / 3,
                      child: Image.asset(
                        'assets/icons/registration/logo_transparan.png',
                        width: screenWidth * 0.14,
                      ),
                    ),
                  ),
                  // Email icon kiri atas
                  Positioned(
                    top: bannerHeight * 0.19,
                    left: screenWidth * 0.09,
                    child: Image.asset(
                      'assets/icons/registration/email_icon.png',
                      width: screenWidth * 0.13,
                      height: screenWidth * 0.13,
                    ),
                  ),
                  // Arrow dari email ke card (putar 180°)
                  Positioned(
                    left: screenWidth * 0.19,
                    top: bannerHeight * 0.12,
                    child: Transform.rotate(
                      angle: math.pi,
                      child: SvgPicture.asset(
                        'assets/icons/registration/arrow.svg',
                        width: screenWidth * 0.13,
                        height: screenWidth * 0.13,
                        color: const Color(0xFFBDBDBD),
                      ),
                    ),
                  ),
                  // Card putih tengah (logo abc)
                  Align(
                    alignment: const Alignment(0, -0.08),
                    child: Container(
                      width: screenWidth * 0.37,
                      height: bannerHeight * 0.78,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 11,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/registration/abc_logo.png',
                          width: screenWidth * 0.23,
                          height: screenWidth * 0.23,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Profile/User card (kanan atas)
                  Positioned(
                    top: bannerHeight * 0.09,
                    right: screenWidth * 0.13,
                    child: Image.asset(
                      'assets/icons/registration/form.png',
                      width: screenWidth * 0.26,
                      height: bannerHeight * 0.21,
                    ),
                  ),
                  // Arrow dari card ke telepon (kanan bawah)
                  Positioned(
                    right: screenWidth * 0.185,
                    bottom: bannerHeight * 0.39,
                    child: Transform.rotate(
                      angle: 0.8,
                      child: SvgPicture.asset(
                        'assets/icons/registration/arrow.svg',
                        width: screenWidth * 0.13,
                        height: screenWidth * 0.13,
                        color: const Color(0xFFE2E2E2),
                      ),
                    ),
                  ),
                  // Store card kiri bawah
                  Positioned(
                    left: screenWidth * 0.11,
                    bottom: bannerHeight * 0.15,
                    child: Image.asset(
                      'assets/icons/registration/store_icon.png',
                      width: screenWidth * 0.26,
                      height: bannerHeight * 0.21,
                    ),
                  ),
                  // Telepon icon kanan bawah
                  Positioned(
                    right: screenWidth * 0.11,
                    bottom: bannerHeight * 0.29,
                    child: Image.asset(
                      'assets/icons/registration/telepon.png',
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                    ),
                  ),
                  // Pensil icon kanan bawah
                  Positioned(
                    right: screenWidth * 0.25,
                    bottom: bannerHeight * 0.14,
                    child: Image.asset(
                      'assets/icons/registration/pensil.png',
                      width: screenWidth * 0.13,
                      height: screenWidth * 0.13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 34),

            // DESCRIPTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.075),
              child: Text(
                "Untuk mendaftar sebagai penjual, mohon lengkapi informasi yang diperlukan",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
              child: SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerificationFormPage(),
                      ),
                    );
                  },
                  child: const Text("Mulai Pendaftaran"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
