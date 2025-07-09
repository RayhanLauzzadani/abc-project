import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormTextField extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final int maxLength;
  final String? initialValue;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // <-- Tambahkan validator

  const FormTextField({
    super.key,
    required this.label,
    this.requiredMark = false,
    this.maxLength = 40,
    this.initialValue,
    this.hintText = "Masukkan",
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator, // <-- Tambahkan validator
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F7F8),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF373E3C),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (requiredMark) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Color(0xFFFF4D4D),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
                const Spacer(),
                // Count karakter
                Text(
                  '${controller?.text.length ?? 0}/$maxLength',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF9A9A9A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // TextField
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
            child: TextFormField(
              controller: controller,
              initialValue: controller == null ? initialValue : null,
              keyboardType: keyboardType,
              maxLength: maxLength,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF373E3C),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.dmSans(
                  color: const Color(0xFF9A9A9A),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
                errorStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.red),
              ),
              onChanged: onChanged,
              validator: validator, // <-- Tambahkan di sini
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ],
      ),
    );
  }
}
