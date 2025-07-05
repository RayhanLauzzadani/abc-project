import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;

  const StoreProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6), // Memberi ruang antar card
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Gambar fleksibel dan tidak fixed aspect ratio → tidak bikin overflow
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ✅ Nama produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF404040),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ✅ Harga produk
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Text(
              price,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF1C55C0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
