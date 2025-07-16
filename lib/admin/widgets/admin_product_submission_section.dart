import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:abc_e_mart/admin/data/models/admin_product_data.dart';
import 'package:abc_e_mart/admin/features/approval/product/admin_product_approval_detail_page.dart';

// Data model produk tampilan list
class AdminProductSubmissionData {
  final String id;
  final String imagePath;
  final String productName;
  final CategoryType categoryType;
  final String storeName;
  final String date;

  const AdminProductSubmissionData({
    required this.id,
    required this.imagePath,
    required this.productName,
    required this.categoryType,
    required this.storeName,
    required this.date,
  });
}

// Format tanggal Firestore
String _formatDate(DateTime dt) {
  return "${dt.day.toString().padLeft(2, '0')}/"
      "${dt.month.toString().padLeft(2, '0')}/"
      "${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
}

// Widget Section Produk Baru (Ajuan)
class AdminProductSubmissionSection extends StatelessWidget {
  final List<AdminProductSubmissionData>? submissions;
  final VoidCallback? onSeeAll;

  const AdminProductSubmissionSection({
    super.key,
    this.submissions,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (submissions != null) {
      return _SectionContent(
        submissions: submissions!,
        onSeeAll: onSeeAll,
      );
    } else {
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
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
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
            final categoryType = mapCategoryType(data['category']);
            String date = "-";
            final createdAt = data['createdAt'];
            if (createdAt != null) {
              final dt = createdAt is Timestamp
                  ? createdAt.toDate()
                  : DateTime.tryParse(createdAt.toString());
              if (dt != null) {
                date = _formatDate(dt);
              }
            }
            return AdminProductSubmissionData(
              id: doc.id,
              imagePath: data['imageUrl'] ?? '',
              productName: data['name'] ?? '-',
              categoryType: categoryType,
              storeName: data['storeName'] ?? '-',
              date: date,
            );
          }).toList();

          return _SectionContent(
            submissions: submissions,
            onSeeAll: onSeeAll,
          );
        },
      );
    }
  }
}

// Widget isi section
class _SectionContent extends StatelessWidget {
  final List<AdminProductSubmissionData> submissions;
  final VoidCallback? onSeeAll;

  const _SectionContent({
    required this.submissions,
    this.onSeeAll,
  });

  Future<void> _openDetail(BuildContext context, String docId) async {
    // Ambil data lengkap dari Firestore
    final doc = await FirebaseFirestore.instance
        .collection('productsApplication')
        .doc(docId)
        .get();

    if (!doc.exists) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Produk tidak ditemukan"),
            content: const Text("Data produk ini sudah dihapus."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
      return;
    }

    final data = doc.data() as Map<String, dynamic>;
    // Map data ke model seperti di AdminProductApprovalPage
    final categoryType = mapCategoryType(data['category']);
    String date = "-";
    final createdAt = data['createdAt'];
    if (createdAt != null) {
      final dt = createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt.toString());
      if (dt != null) {
        date = _formatDate(dt);
      }
    }

    final adminProductData = AdminProductData(
      docId: doc.id,
      imagePath: data['imageUrl'] ?? '',
      productName: data['name'] ?? '-',
      categoryType: categoryType,
      storeName: data['storeName'] ?? '',
      date: date,
      status: data['status'] ?? 'Menunggu',
      description: data['description'] ?? '-',
      price: (data['price'] is int)
          ? data['price']
          : int.tryParse('${data['price'] ?? 0}') ?? 0,
      stock: (data['stock'] is int)
          ? data['stock']
          : int.tryParse('${data['stock'] ?? 0}') ?? 0,
      shopId: data['shopId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      rawData: data,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminProductApprovalDetailPage(data: adminProductData),
        ),
      );
    }
  }

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
                    onDetail: () => _openDetail(context, submission.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Badge Kategori
class CategoryBadge extends StatelessWidget {
  final CategoryType type;
  const CategoryBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color borderColor = getCategoryColor(type);
    Color textColor = getCategoryColor(type);
    Color bgColor = getCategoryBgColor(type);
    final label = categoryLabels[type] ?? "Lainnya";

    return Container(
      width: 120,
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

// Kartu Produk Ajuan
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
        img.isEmpty ? "assets/images/placeholder.png" : img,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
                const SizedBox(width: 10),
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
                      CategoryBadge(type: data.categoryType),
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
