import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressSection extends StatelessWidget {
  final String label;
  final String detail;
  final VoidCallback? onTap;

  const AddressSection({
    super.key,
    required this.label,
    required this.detail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Alamat Pengiriman',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: const Color(0xFF373E3C),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        // Card
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/location.svg',
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(Color(0xFF646464), BlendMode.srcIn),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 15.5,
                          color: const Color(0xFF979797),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF373E3C), size: 26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
