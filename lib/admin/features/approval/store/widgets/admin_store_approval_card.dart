import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Data class untuk 1 toko
class AdminStoreApprovalData {
  final String imagePath;
  final String storeName;
  final String storeAddress;
  final String submitter;
  final String date;
  const AdminStoreApprovalData({
    required this.imagePath,
    required this.storeName,
    required this.storeAddress,
    required this.submitter,
    required this.date,
  });
}

class AdminStoreApprovalCard extends StatelessWidget {
  final AdminStoreApprovalData data;
  final VoidCallback? onDetail;

  const AdminStoreApprovalCard({
    super.key,
    required this.data,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // Bukan dark mode
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Gambar + Info
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
                const SizedBox(width: 14),
                // Info toko
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama toko
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
                      // Alamat
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
                      // User
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
            // Row: date kiri, detail kanan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date
                Text(
                  data.date,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: const Color(0xFF9A9A9A),
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
