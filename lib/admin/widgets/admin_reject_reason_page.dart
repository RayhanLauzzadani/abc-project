import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/admin/widgets/success_dialog.dart';

class AdminRejectReasonPage extends StatefulWidget {
  final Function(String reason)? onConfirmed;
  const AdminRejectReasonPage({super.key, this.onConfirmed});

  @override
  State<AdminRejectReasonPage> createState() => _AdminRejectReasonPageState();
}

class _AdminRejectReasonPageState extends State<AdminRejectReasonPage> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty && _controller.text.length <= 255;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ======= CUSTOM APP BAR =======
            Container(
              height: 67,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2066CF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Penolakan Ajuan',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 33),
                    // Judul "Alasan Penolakan"
                    Text(
                      'Alasan Penolakan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card/Box Alasan Penolakan
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 243),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFDFE3E6),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row Atas: Label + Counter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Alasan Penolakan',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        color: const Color(0xFF373E3C),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Text(
                                      '*',
                                      style: TextStyle(
                                        color: Color(
                                          0xFFD32F2F,
                                        ), // Red asterisk
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Counter
                                Text(
                                  '${_controller.text.length}/255',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: const Color(0xFF9A9A9A),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // TextField multiline tanpa border
                            TextField(
                              controller: _controller,
                              maxLength: 255,
                              maxLines: null,
                              minLines: 5,
                              cursorColor: const Color(0xFF373E3C),
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF373E3C),
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                counterText: "", // Biar ga dobel counter
                                hintText:
                                    'Tuliskan alasan penolakan anda......',
                                hintStyle: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  color: const Color(0xFF9A9A9A),
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                setState(() {}); // untuk update counter
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ===== BUTTON KONFIRM =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 29, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 59,
                child: ElevatedButton(
                  onPressed: _canSubmit
                      ? () async {
                          if (_controller.text.trim().isEmpty) {
                            setState(() => _errorText = "Wajib diisi");
                            return;
                          }
                          // 1. Munculkan dialog sukses!
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const SuccessDialog(
                              message: "Ajuan Toko Berhasil Ditolak",
                            ),
                          );
                          await Future.delayed(
                            const Duration(milliseconds: 1800),
                          );
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(); // tutup dialog
                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );
                          Navigator.of(context).pop(
                            _controller.text.trim(),
                          ); // pop page + return alasan ke parent
                        }
                      : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit
                        ? const Color(0xFF1C55C0)
                        : const Color(0xFFF5F6FA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.zero, // Padding diatur oleh parent
                  ),
                  child: Text(
                    "Konfirmasi Penolakan",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _canSubmit
                          ? const Color(0xFFFAFAFA)
                          : const Color(0xFF9A9A9A),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
