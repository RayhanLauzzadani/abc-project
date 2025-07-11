import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminStoreSubmissionSection extends StatelessWidget {
  final List<AdminStoreSubmissionData> submissions;
  final VoidCallback? onSeeAll;
  final void Function(AdminStoreSubmissionData)? onDetail;
  final String? title;
  final bool showSeeAll;

  const AdminStoreSubmissionSection({
    super.key,
    required this.submissions,
    this.onSeeAll,
    this.onDetail,
    this.title,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title dan Lainnya
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Ajuan Toko Terbaru",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ),
                if (showSeeAll && onSeeAll != null) // <-- Gunakan showSeeAll
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Row(
                      children: [
                        Text(
                          "Lainnya",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFFBDBDBD),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFFBDBDBD),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Lihat transaksi baru saja terjadi di tokomu di sini!",
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 18),
            // List Ajuan
            ...submissions.map(
              (submission) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AdminStoreSubmissionCard(
                  data: submission,
                  onDetail: () => onDetail?.call(submission),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStoreSubmissionCard extends StatelessWidget {
  final AdminStoreSubmissionData data;
  final VoidCallback? onDetail;
  const _AdminStoreSubmissionCard({required this.data, this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ROW 1: Gambar & Info toko
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    data.imagePath,
                    width: 89,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                // Info toko
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.storeName,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.storeAddress,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/user.svg',
                            width: 14,
                            height: 14,
                            color: const Color(0xFFBDBDBD),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data.submitter,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: const Color(0xFFBDBDBD),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ROW 2: Date (kiri bawah) & Detail Ajuan (kanan bawah)
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date
                Text(
                  data.date,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
                // Detail Ajuan
                GestureDetector(
                  onTap: onDetail,
                  child: Row(
                    children: [
                      Text(
                        "Detail Ajuan",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: const Color(0xFF1867C2),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF1C55C0),
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

// Data class
class AdminStoreSubmissionData {
  final String imagePath;
  final String storeName;
  final String storeAddress;
  final String submitter;
  final String date;

  const AdminStoreSubmissionData({
    required this.imagePath,
    required this.storeName,
    required this.storeAddress,
    required this.submitter,
    required this.date,
  });
}
