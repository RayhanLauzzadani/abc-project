import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool?> showDeleteChatDialog({
  required BuildContext context,
  String? messageText,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (c) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0x1AFF5B5B),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5B5B), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Hapus Pesan ?',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: const Color(0xFF232323),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(c, false),
            child: const Icon(Icons.close_rounded, color: Color(0xFFB7B7B7)),
          )
        ],
      ),
      content: Text(
        messageText != null && messageText.isNotEmpty
            ? 'Anda yakin ingin menghapus pesan berikut?\n\n"$messageText"'
            : "Anda yakin ingin menghapus pesan ini?",
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: const Color(0xFF494949),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(c, false),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF232323),
                  backgroundColor: const Color(0xFFF2F2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(0, 42),
                ),
                child: Text(
                  "Tidak",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(c, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B5B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(0, 42),
                  elevation: 0,
                ),
                child: Text(
                  "Iya",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
