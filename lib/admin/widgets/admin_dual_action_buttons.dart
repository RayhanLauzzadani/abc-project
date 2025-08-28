import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDualActionButtons extends StatelessWidget {
  final String rejectText;
  final String acceptText;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  /// Bila true, tinggi tombol dan padding dibuat lebih ramping.
  final bool compact;

  const AdminDualActionButtons({
    super.key,
    this.rejectText = "Tolak",
    this.acceptText = "Terima",
    required this.onReject,
    required this.onAccept,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = ((screenWidth - 64) / 2).clamp(120.0, 350.0);
    final vertical = compact ? 10.0 : 14.0;
    final fontSize = compact ? 16.0 : 18.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
              padding: EdgeInsets.symmetric(vertical: vertical),
              textStyle: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
            child: Text(rejectText),
          ),
        ),
        const SizedBox(width: 20),
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
              padding: EdgeInsets.symmetric(vertical: vertical),
              textStyle: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
            child: Text(acceptText),
          ),
        ),
      ],
    );
  }
}
