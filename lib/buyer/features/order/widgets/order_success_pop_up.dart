import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderArrivedDialog extends StatelessWidget {
  final String message;
  final String lottiePath;
  final double lottieSize;

  const OrderArrivedDialog({
    super.key,
    this.message = "Pesanan telah sampai. Selamat menikmati! 🎉",
    this.lottiePath = "assets/lottie/success_check.json",
    this.lottieSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // shadow lembut
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          // kartu isi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(30, 36, 30, 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: lottieSize,
                  height: lottieSize,
                  repeat: false,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: const Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
