import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminStoreSubmissionSection extends StatelessWidget {
  final List<AdminStoreSubmissionData> submissions;
  final VoidCallback? onSeeAll;
  final void Function(AdminStoreSubmissionData)? onDetail;
  final String? title;
  final bool showSeeAll;
  final bool isNetworkImage;

  const AdminStoreSubmissionSection({
    super.key,
    required this.submissions,
    this.onSeeAll,
    this.onDetail,
    this.title,
    this.showSeeAll = true,
    this.isNetworkImage = false,
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
        padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title dan Lainnya
            Row(
              children: [
                Expanded(
                  child: Text(
                    title ?? "Ajuan Toko Terbaru",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ),
                if (showSeeAll && onSeeAll != null)
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
            if (submissions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    "Belum ada pengajuan toko yang masuk.",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9A9A9A),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...submissions.map(
                (submission) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AdminStoreSubmissionCard(
                    data: submission,
                    onDetail: () => onDetail?.call(submission),
                    isNetworkImage: isNetworkImage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Card Widget tetap sama
class _AdminStoreSubmissionCard extends StatelessWidget {
  final AdminStoreSubmissionData data;
  final VoidCallback? onDetail;
  final bool isNetworkImage;
  const _AdminStoreSubmissionCard({required this.data, this.onDetail, this.isNetworkImage = false});

  @override
  Widget build(BuildContext context) {
    Widget imgWidget;
    if (isNetworkImage && data.imagePath.isNotEmpty) {
      imgWidget = Image.network(
        data.imagePath,
        width: 89,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 89,
          height: 76,
          color: const Color(0xFFF3F3F3),
          child: const Icon(Icons.store, color: Colors.grey),
        ),
      );
    } else if (data.imagePath.isNotEmpty) {
      imgWidget = Image.asset(
        data.imagePath,
        width: 89,
        height: 76,
        fit: BoxFit.cover,
      );
    } else {
      imgWidget = Container(
        width: 89,
        height: 76,
        color: const Color(0xFFF3F3F3),
        child: const Icon(Icons.store, color: Colors.grey),
      );
    }

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imgWidget,
                ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.date,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
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

class AdminStoreSubmissionData {
  final String imagePath;
  final String storeName;
  final String storeAddress;
  final String submitter;
  final String date;
  final String docId;

  const AdminStoreSubmissionData({
    required this.imagePath,
    required this.storeName,
    required this.storeAddress,
    required this.submitter,
    required this.date,
    required this.docId,
  });
}
