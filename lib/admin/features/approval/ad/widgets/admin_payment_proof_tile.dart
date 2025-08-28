import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

/// Cek file adalah gambar dari url/nama
bool isImageFile(String fileNameOrUrl) {
  final ext = p.extension(fileNameOrUrl).replaceFirst('.', '').toLowerCase();
  return ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
}

class PaymentProofTile extends StatelessWidget {
  final String? fileName;
  final String? fileSize;
  final String filePath; // url firebase, path lokal, atau asset
  final VoidCallback? onTap;

  const PaymentProofTile({
    super.key,
    required this.filePath,
    this.fileName,
    this.fileSize,
    this.onTap,
  });

  /// Get file name dari url jika parameter kosong
  String getDisplayFileName() {
    if (fileName != null && fileName!.isNotEmpty) return fileName!;
    // Coba ekstrak dari url/path
    try {
      return p.basename(Uri.decodeFull(filePath));
    } catch (_) {
      return "Bukti Pembayaran";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImagePreview = isImageFile(filePath);

    Widget thumb;
    if (isImagePreview) {
      if (filePath.startsWith('http')) {
        thumb = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            filePath,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _iconPlaceholder(),
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
            errorBuilder: (_, __, ___) => _iconPlaceholder(),
          ),
        );
      } else {
        thumb = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            filePath,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _iconPlaceholder(),
          ),
        );
      }
    } else {
      thumb = _iconPlaceholder();
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
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
                    getDisplayFileName(),
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF373E3C),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fileSize ?? '-',
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

  Widget _iconPlaceholder() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFFBBBBBB),
        size: 19,
      ),
    );
  }
}
