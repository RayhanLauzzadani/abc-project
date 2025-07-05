import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final int price;
  final double rating;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // Info Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF373E3C),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                    style: const TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Rating
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/star.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF373E3C),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
