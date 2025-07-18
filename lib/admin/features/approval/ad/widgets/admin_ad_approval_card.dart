import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abc_e_mart/seller/data/models/ad.dart'; // Pastikan import model AdApplication
import 'package:intl/intl.dart';

class AdminAdApprovalCard extends StatelessWidget {
  final AdApplication ad;
  final VoidCallback? onDetail;

  const AdminAdApprovalCard({
    super.key,
    required this.ad,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    // Format tanggal pengajuan
    String formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(ad.createdAt);

    // Periode iklan (contoh: 3 Hari • 21 Juli – 23 Juli 2025)
    int days = ad.durasiSelesai.difference(ad.durasiMulai).inDays + 1;
    String tglMulai = DateFormat('d MMMM yyyy', 'id_ID').format(ad.durasiMulai);
    String tglSelesai = DateFormat('d MMMM yyyy', 'id_ID').format(ad.durasiSelesai);
    String period = "$days Hari • $tglMulai – $tglSelesai";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Iklan (dari ad.judul)
            Text(
              ad.judul,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 5),

            // Nama Toko
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/store.svg',
                  width: 16,
                  height: 16,
                  color: const Color(0xFF373E3C),
                ),
                const SizedBox(width: 5),
                Text(
                  ad.storeName,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF373E3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Periode Iklan
            Text(
              period,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 10),

            // Footer: tanggal & tombol detail
            Row(
              children: [
                Text(
                  formattedDate,
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
