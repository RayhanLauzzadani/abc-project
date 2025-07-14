import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Hanya image
bool isImage(String fileName) {
  final ext = fileName.toLowerCase().split('.').last;
  return ['jpg', 'jpeg', 'png'].contains(ext);
}

class PaymentProofTile extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String filePath; // asset path, file path, atau url
  final VoidCallback? onTap;

  const PaymentProofTile({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan image provider dari asset/local/network
    Widget thumb;
    if (filePath.startsWith('http')) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          filePath,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      );
    } else if (filePath.startsWith('/')) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(filePath),
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // fallback asset
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          filePath,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 209,
          minHeight: 50,
          maxHeight: 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            thumb,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fileSize,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: const Color(0xFF9A9A9A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9A9A9A)),
          ],
        ),
      ),
    );
  }
}
