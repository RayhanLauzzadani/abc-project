import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SuccessEditProductDialog extends StatelessWidget {
  final String? message;

  const SuccessEditProductDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/lottie/success_check.json',
            height: 90,
            repeat: false,
          ),
          const SizedBox(height: 12),
          Text(
            "Produk berhasil diubah!",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 7),
            Text(
              message!,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
