import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data model
class AdminProductSubmissionData {
  final String id;
  final String imagePath;
  final String productName;
  final String category;
  final CategoryType categoryType;
  final String storeName;
  final String date;

  const AdminProductSubmissionData({
    required this.id,
    required this.imagePath,
    required this.productName,
    required this.category,
    required this.categoryType,
    required this.storeName,
    required this.date,
  });
}

// Enum kategori, tambah 'lain' supaya fallback
enum CategoryType { makanan, minuman, snacks, merchandise, lain }

// Helper mapping string Firestore ke enum
CategoryType mapCategoryType(String category) {
  final c = category.toLowerCase();
  if (c.contains("makan")) return CategoryType.makanan;
  if (c.contains("minum")) return CategoryType.minuman;
  if (c.contains("snack")) return CategoryType.snacks;
  if (c.contains("merch")) return CategoryType.merchandise;
  return CategoryType.lain;
}

// Warna kategori
Color getCategoryColor(CategoryType type) {
  switch (type) {
    case CategoryType.makanan: return const Color(0xFFDC3545);
    case CategoryType.minuman: return const Color(0xFF884C1E);
    case CategoryType.snacks: return const Color(0xFFFFC107);
    case CategoryType.merchandise: return const Color(0xFFB280D4);
    case CategoryType.lain: return const Color(0xFF818181);
  }
}

Color getCategoryBgColor(CategoryType type) {
  switch (type) {
    case CategoryType.makanan: return const Color(0x1ADC3545); // 10% merah
    case CategoryType.minuman: return const Color(0x1A884C1E);
    case CategoryType.snacks: return const Color(0x1AFFC107);
    case CategoryType.merchandise: return const Color(0x1AB280D4);
    case CategoryType.lain: return const Color(0x16818181);
  }
}

// Format tanggal Firestore
String _formatDate(DateTime dt) {
  return "${dt.day.toString().padLeft(2, '0')}/"
      "${dt.month.toString().padLeft(2, '0')}/"
      "${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
}

// BAGIAN UTAMA: Widget Section Produk Baru (Ajuan)
class AdminProductSubmissionSection extends StatelessWidget {
  final List<AdminProductSubmissionData>? submissions;
  final VoidCallback? onSeeAll;
  final void Function(AdminProductSubmissionData)? onDetail;

  const AdminProductSubmissionSection({
    super.key,
    this.submissions,
    this.onSeeAll,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    // If submissions are provided, use them. Otherwise, fallback to original StreamBuilder logic.
    if (submissions != null) {
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
                "Lihat produk baru yang diajukan seller di sini.",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 18),
              if (submissions!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Text(
                    "Belum ada ajuan produk baru.",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                ...submissions!.map(
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
    } else {
      // fallback to original StreamBuilder logic
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productsApplication')
            .where('status', isEqualTo: 'Menunggu')
            .orderBy('createdAt', descending: true)
            .limit(3)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Terjadi kesalahan: {snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final submissions = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final category = (data['category'] ?? '-') as String;
            final categoryType = mapCategoryType(category);

            return AdminProductSubmissionData(
              id: doc.id,
              imagePath: data['imageUrl'] ?? '',
              productName: data['name'] ?? '-',
              category: category,
              categoryType: categoryType,
              storeName: data['storeName'] ?? '-',
              date: (data['createdAt'] != null && data['createdAt'] is Timestamp)
                  ? _formatDate((data['createdAt'] as Timestamp).toDate())
                  : '-',
            );
          }).toList();

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
                    "Lihat produk baru yang diajukan seller di sini.",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (submissions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Text(
                        "Belum ada ajuan produk baru.",
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  else
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
        },
      );
    }
  }
}

// Badge Widget
class CategoryBadge extends StatelessWidget {
  final String label;
  final CategoryType type;

  const CategoryBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color borderColor = getCategoryColor(type);
    Color textColor = getCategoryColor(type);
    Color bgColor = getCategoryBgColor(type);

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

// Card produk satuan
class _AdminProductSubmissionCard extends StatelessWidget {
  final AdminProductSubmissionData data;
  final VoidCallback? onDetail;
  const _AdminProductSubmissionCard({required this.data, this.onDetail});

  @override
  Widget build(BuildContext context) {
    final img = data.imagePath;
    final isNetwork = img.startsWith('http');
    Widget imageWidget;
    if (isNetwork) {
      imageWidget = Image.network(
        img,
        width: 89,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 89,
          height: 76,
          color: Colors.grey[200],
          child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
        ),
      );
    } else {
      imageWidget = Image.asset(
        img.isEmpty ? "assets/images/placeholder.png" : img, // gunakan asset default jika kosong
        width: 89,
        height: 76,
        fit: BoxFit.cover,
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
                  child: imageWidget,
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
