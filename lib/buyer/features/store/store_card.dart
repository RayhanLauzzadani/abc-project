import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoreCard extends StatelessWidget {
  final String imagePath;
  final String storeName;
  final String distance;
  final String duration;
  final double rating;
  final VoidCallback? onTap;

  const StoreCard({
    super.key,
    required this.imagePath,
    required this.storeName,
    required this.distance,
    required this.duration,
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
            // Store Image
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

            // Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      color: Color(0xFF373E3C),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$distance • $duration",
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
              mainAxisSize: MainAxisSize.min,
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
