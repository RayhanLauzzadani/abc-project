import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/registration_app_bar.dart';

class KtpInstructionPage extends StatelessWidget {
  const KtpInstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(79),
        child: RegistrationAppBar(
          title: 'Instruksi',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        children: [
          const SizedBox(height: 16),
          // KTP image
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icons/registration/ktp.png',
                width: 320,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Judul instruksi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Foto Bagian Depan KTP",
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF373E3C),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List instruksi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InstructionPoint(
                  number: "1.",
                  text: "Foto harus landscape.",
                ),
                _InstructionPoint(
                  number: "2.",
                  text: "Pastikan seluruh KTP berada di dalam bingkai foto dan tidak ada bagian yang terpotong.",
                ),
                _InstructionPoint(
                  number: "3.",
                  text: "Foto harus terlihat jelas, tidak buram, atau terdapat pantulan cahaya.",
                ),
                _InstructionPoint(
                  number: "4.",
                  text: "Foto harus asli, bukan fotokopi, dan tidak diedit.",
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: const Color(0xFFE4E8EE),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget point instruksi
class _InstructionPoint extends StatelessWidget {
  final String number;
  final String text;
  const _InstructionPoint({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9A9A9A),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9A9A9A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
