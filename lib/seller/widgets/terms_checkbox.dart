import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTapLink;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTapLink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: Color(0xFF373E3C), width: 1.5),
          activeColor: const Color(0xFF1C55C0),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(
                color: const Color(0xFF373E3C),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: "Saya Menyetujui "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: onTapLink,
                    child: Text(
                      "Syarat & Ketentuan.",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF1C55C0),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
