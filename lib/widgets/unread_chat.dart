import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnreadChatDivider extends StatelessWidget {
  final String text;
  const UnreadChatDivider({super.key, this.text = "Pesan terakhir dibaca"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6EDFF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              color: const Color(0xFF2056D3),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
