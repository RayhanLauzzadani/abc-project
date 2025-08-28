import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abc_e_mart/admin/data/models/admin_store_data.dart';

class AdminStoreApprovalCard extends StatelessWidget {
  final AdminStoreApprovalData data;
  final VoidCallback? onDetail;
  final bool isNetworkImage;
  const AdminStoreApprovalCard({
  super.key,
    required this.data,
    this.onDetail,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (isNetworkImage && data.imagePath.isNotEmpty) {
      imageWidget = Image.network(
        data.imagePath,
        width: 89,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 89,
          height: 76,
          color: const Color(0xFFF3F3F3),
          child: const Icon(Icons.store, color: Colors.grey),
        ),
      );
    } else if (data.imagePath.isNotEmpty) {
      imageWidget = Image.asset(
        data.imagePath,
        width: 89,
        height: 76,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.storeName,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.storeAddress,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/user.svg',
                            width: 14,
                            height: 14,
                            color: const Color(0xFF9A9A9A),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              data.submitter,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: const Color(0xFF9A9A9A),
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
                      const SizedBox(width: 3),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFF1C55C0)),
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
