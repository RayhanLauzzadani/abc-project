import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/registration_app_bar.dart';

class LogoInstructionPage extends StatelessWidget {
  const LogoInstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(79),
        child: RegistrationAppBar(title: "Instruksi"),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 20), // Tambahkan ini!
          // Card abu & logo sample
          Container(
            width: double.infinity,
            color: const Color(0xFFF2F2F3),
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFD6D6D6),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "LOGO",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Instruksi Logo Toko",
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF373E3C),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LogoInstructionItem(
                  index: 1,
                  text: "Gunakan gambar berukuran minimum 500 x 500 piksel.",
                ),
                _LogoInstructionItem(
                  index: 2,
                  text: "Format JPG, PNG, atau JPEG.",
                ),
                _LogoInstructionItem(
                  index: 3,
                  text: "Pastikan logo jelas, tidak buram, dan tidak mengandung unsur yang melanggar kebijakan.",
                ),
                _LogoInstructionItem(
                  index: 4,
                  text: "Maksimum ukuran file 2 MB.",
                  withDivider: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoInstructionItem extends StatelessWidget {
  final int index;
  final String text;
  final bool withDivider;
  const _LogoInstructionItem({
    required this.index,
    required this.text,
    this.withDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$index. ",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF9A9A9A),
                fontWeight: FontWeight.w400,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF9A9A9A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        if (withDivider) ...[
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.only(left: 0, right: 0),
            width: double.infinity,
            height: 1,
            color: const Color(0xFFDFE4EA),
          ),
        ] else ...[
          const SizedBox(height: 10),
        ]
      ],
    );
  }
}
