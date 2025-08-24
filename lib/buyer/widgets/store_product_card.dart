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

    // Kunci text-scale supaya ukuran font stabil dan tidak bikin overflow
    final media = MediaQuery.of(context);

    return MediaQuery(
      data: media.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
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
              // Gambar 1:1 seragam
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: isNetwork && imagePath.isNotEmpty
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        )
                      : Image.asset(
                          "assets/images/image-placeholder.png",
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(height: 4), // dirapatkan

              // Nama produk (maks 2 baris) dengan tinggi tetap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 32, // cukup untuk 2 baris kecil
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF404040),
                      height: 1.15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Harga (1 baris) dengan tinggi tetap
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                child: SizedBox(
                  height: 16,
                  child: Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF1C55C0),
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
