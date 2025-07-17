import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showEditChatDialog({
  required BuildContext context,
  required String currentText,
  int maxLength = 400,
}) {
  final controller = TextEditingController(text: currentText);
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (c) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Pesan",
                style: GoogleFonts.dmSans(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF232323),
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: maxLength,
                minLines: 1,
                maxLines: 4,
                style: GoogleFonts.dmSans(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Edit pesan...",
                  hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 15),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  counterText: "",
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(c),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F2F2),
                        foregroundColor: const Color(0xFF232323),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(
                        "Batal",
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Navigator.pop(c, controller.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2056D3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(0, 44),
                        elevation: 0,
                      ),
                      child: Text(
                        "Simpan",
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}