import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAdSubmissionSection extends StatelessWidget {
  final List<AdminAdSubmissionData> submissions;
  final VoidCallback? onSeeAll;
  final void Function(AdminAdSubmissionData)? onDetail;

  const AdminAdSubmissionSection({
    super.key,
    required this.submissions,
    this.onSeeAll,
    this.onDetail,
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
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Ajuan Iklan Terbaru",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ),
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
            // List Card
            ...submissions.map(
              (submission) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AdminAdSubmissionCard(
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

class _AdminAdSubmissionCard extends StatelessWidget {
  final AdminAdSubmissionData data;
  final VoidCallback? onDetail;
  const _AdminAdSubmissionCard({required this.data, this.onDetail});

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
        padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              data.title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 4),
            // Periode detail
            Text(
              data.detailPeriod,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 8),
            // Row bawah
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
                // Detail Iklan
                GestureDetector(
                  onTap: onDetail,
                  child: Row(
                    children: [
                      Text(
                        "Detail Iklan",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF6D6D6D),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFF6D6D6D)),
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
class AdminAdSubmissionData {
  final String title;
  final String detailPeriod;
  final String date;

  const AdminAdSubmissionData({
    required this.title,
    required this.detailPeriod,
    required this.date,
  });
}
