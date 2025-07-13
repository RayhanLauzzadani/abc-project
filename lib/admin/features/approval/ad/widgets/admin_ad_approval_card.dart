import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminAdApprovalCard extends StatelessWidget {
  final String title;
  final String storeName;
  final String period;
  final String date;
  final VoidCallback? onDetail;

  const AdminAdApprovalCard({
    super.key,
    required this.title,
    required this.storeName,
    required this.period,
    required this.date,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // <= 10px sesuai permintaan
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 5),

            // Nama Toko (dengan icon svg)
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/store.svg',
                  width: 16, // ukuran svg biar pas (12-16px)
                  height: 16,
                  color: const Color(0xFF373E3C),
                ),
                const SizedBox(width: 5),
                Text(
                  storeName,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF373E3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Periode
            Text(
              period,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 10),

            // Footer: tanggal & Detail Iklan
            Row(
              children: [
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDetail,
                  child: Row(
                    children: [
                      Text(
                        "Detail Iklan",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF777777),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
