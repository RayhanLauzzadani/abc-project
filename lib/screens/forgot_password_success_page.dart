import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ForgotPasswordSuccessPage extends StatelessWidget {
  const ForgotPasswordSuccessPage({super.key});

  static const colorPrimary = Color(0xFF1C55C0);
  static const colorInput = Color(0xFF404040);
  static const colorPlaceholder = Color(0xFF757575);
  static const colorSuccess = Color(0xFF2DD36F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 108),
              // BadgeCheck icon
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorSuccess,
                ),
                padding: const EdgeInsets.all(28),
                child: const Icon(
                  LucideIcons.badgeCheck,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 36),
              // Title
              Text(
                "Berhasil",
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorInput,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                "Password anda telah berhasil diubah.",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: colorPlaceholder,
                ),
              ),
              const SizedBox(height: 40),
              // Button
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Kembali ke Login",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), 
            ],
          ),
        ),
      ),
    );
  }
}
