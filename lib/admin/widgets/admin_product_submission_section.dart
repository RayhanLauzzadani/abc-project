import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Data model
class AdminProductSubmissionData {
  final String imagePath;
  final String productName;
  final String category;
  final CategoryType categoryType;
  final String storeName;
  final String date;

  const AdminProductSubmissionData({
    required this.imagePath,
    required this.productName,
    required this.category,
    required this.categoryType,
    required this.storeName,
    required this.date,
  });
}

// Enum untuk warna badge kategori
enum CategoryType { makanan, minuman, snacks, merchandise }

Color getCategoryColor(CategoryType type) {
  switch (type) {
    case CategoryType.makanan: return const Color(0xFFDC3545);
    case CategoryType.minuman: return const Color(0xFF884C1E);
    case CategoryType.snacks: return const Color(0xFFFFC107);
    case CategoryType.merchandise: return const Color(0xFFB280D4);
  }
}

Color getCategoryBgColor(CategoryType type) {
  switch (type) {
    case CategoryType.makanan: return const Color(0x1ADC3545); // 10% red
    case CategoryType.minuman: return const Color(0x1A884C1E); // 10% brown
    case CategoryType.snacks: return const Color(0x1AFFC107); // 10% yellow
    case CategoryType.merchandise: return const Color(0x1AB280D4); // 10% purple
  }
}

class AdminProductSubmissionSection extends StatelessWidget {
  final List<AdminProductSubmissionData> submissions;
  final VoidCallback? onSeeAll;
  final void Function(AdminProductSubmissionData)? onDetail;

  const AdminProductSubmissionSection({
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
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Ajuan Produk Terbaru",
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
                child: _AdminProductSubmissionCard(
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

// Badge Widget
class CategoryBadge extends StatelessWidget {
  final String label;
  final CategoryType type;

  const CategoryBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    // Konfigurasi warna per kategori
    Color borderColor, textColor, bgColor;
    switch (type) {
      case CategoryType.makanan:
        borderColor = const Color(0xFFDC3545);
        textColor = const Color(0xFFDC3545);
        bgColor = const Color(0x1ADC3545); // 10% merah
        break;
      case CategoryType.minuman:
        borderColor = const Color(0xFF884C1E);
        textColor = const Color(0xFF884C1E);
        bgColor = const Color(0x1A884C1E);
        break;
      case CategoryType.snacks:
        borderColor = const Color(0xFFFFC107);
        textColor = const Color(0xFFFFC107);
        bgColor = const Color(0x1AFFC107);
        break;
      case CategoryType.merchandise:
        borderColor = const Color(0xFFB280D4);
        textColor = const Color(0xFFB280D4);
        bgColor = const Color(0x1AB280D4);
        break;
    }

    return Container(
      width: 92,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}


class _AdminProductSubmissionCard extends StatelessWidget {
  final AdminProductSubmissionData data;
  final VoidCallback? onDetail;
  const _AdminProductSubmissionCard({required this.data, this.onDetail});

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
        padding: const EdgeInsets.only(
          left: 20, right: 20, top: 18, bottom: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row gambar dan info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // Info produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.productName,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      CategoryBadge(
                        label: data.category,
                        type: data.categoryType,
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/store.svg',
                            width: 16,
                            height: 16,
                            color: const Color(0xFF373E3C),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            data.storeName,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: const Color(0xFF373E3C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Row bawah: date dan detail ajuan
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
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFF1867C2)),
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
