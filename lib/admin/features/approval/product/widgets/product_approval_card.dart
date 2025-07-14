import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:abc_e_mart/admin/data/models/admin_product_data.dart';

class ProductApprovalCard extends StatelessWidget {
  final AdminProductData data;
  final VoidCallback? onDetail;

  const ProductApprovalCard({super.key, required this.data, this.onDetail});

  @override
  Widget build(BuildContext context) {
    final product = data.rawData;
    final type = data.categoryType;

    Widget imageWidget;
    final imageUrl = product['imageUrl'] ?? '';
    if (imageUrl.toString().isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
        width: 89,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 89,
          height: 76,
          color: const Color(0xFFF3F3F3),
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      );
    } else {
      imageWidget = Container(
        width: 89,
        height: 76,
        color: const Color(0xFFF3F3F3),
        child: const Icon(Icons.image, color: Colors.grey),
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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar + Info Produk
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama produk
                      Text(
                        product['name'] ?? '-',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Badge kategori (dengan border!)
                      IntrinsicWidth(
                        child: Container(
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: getCategoryBgColor(type),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: getCategoryColor(type),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              categoryLabels[type]!,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: getCategoryColor(type),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/store.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF373E3C),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              product['storeName'] ?? '-',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(0xFF373E3C),
                                fontWeight: FontWeight.w400,
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
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: const Color(0xFF9A9A9A),
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
                          color: const Color(0xFF1C55C0),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF2066CF),
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
