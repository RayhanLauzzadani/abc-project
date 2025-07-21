import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String logoPath;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isAsset;

  const PromoBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.logoPath,
    required this.buttonText,
    required this.onPressed,
    this.isAsset = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        return Container(
          width: cardWidth,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // TEXT & BUTTON
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 24 / 18,
                              color: const Color(0xFF232323),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              height: 28 / 16,
                              color: const Color(0xFFB4B4B4),
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C55C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 0,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          onPressed: onPressed,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              buttonText,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // IMAGE & LOGO
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: SizedBox(
                  width: 205,
                  height: 160,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: isAsset
                            ? Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator(strokeWidth: 1.5));
                                },
                                errorBuilder: (c, o, s) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: _buildLogo(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    if (isAsset) {
      return Image.asset(
        logoPath.isNotEmpty ? logoPath : 'assets/images/logo.png',
        fit: BoxFit.contain,
      );
    }
    // If url
    if (logoPath.startsWith('http')) {
      return Image.network(
        logoPath,
        fit: BoxFit.contain,
        errorBuilder: (c, o, s) => const Icon(Icons.store),
      );
    }
    // fallback to asset logo
    return Image.asset(
      logoPath.isNotEmpty ? logoPath : 'assets/images/logo.png',
      fit: BoxFit.contain,
    );
  }
}
