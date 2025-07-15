import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final VoidCallback? onTap;

  const StoreProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imagePath.startsWith('http');
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: isNetwork && imagePath.isNotEmpty
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    )
                  : Image.asset(
                      "assets/images/image-placeholder.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
              ),
            ),

            const SizedBox(height: 8),

            //  Nama produk
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

            //  Harga produk
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
      ),
    );
  }
}
