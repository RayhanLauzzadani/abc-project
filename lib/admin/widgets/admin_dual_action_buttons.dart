import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDualActionButtons extends StatelessWidget {
  final String rejectText;
  final String acceptText;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  const AdminDualActionButtons({
    super.key,
    this.rejectText = "Tolak",
    this.acceptText = "Terima",
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive: 2 tombol sama lebar dengan clamp supaya tetap bagus di semua device
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = ((screenWidth - 64) / 2).clamp(120.0, 350.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button Tolak
        SizedBox(
          width: buttonWidth,
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE57373)),
              backgroundColor: const Color(0xFFFCE9EA),
              foregroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            child: Text(rejectText),
          ),
        ),
        const SizedBox(width: 20),
        // Button Terima
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2066CF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            child: Text(acceptText),
          ),
        ),
      ],
    );
  }
}
