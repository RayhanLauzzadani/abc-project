import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:abc_e_mart/admin/data/models/admin_product_data.dart';
import 'package:abc_e_mart/admin/widgets/admin_dual_action_buttons.dart';
import 'package:abc_e_mart/admin/widgets/success_dialog.dart';
import 'package:abc_e_mart/admin/widgets/admin_reject_reason_page.dart';

class AdminProductApprovalDetailPage extends StatelessWidget {
  final AdminProductData data;
  final String description;
  final List<String> variations;
  final String price;

  const AdminProductApprovalDetailPage({
    super.key,
    required this.data,
    required this.description,
    required this.variations,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Custom AppBar tetap di atas
      body: SafeArea(
        child: Column(
          children: [
            // ===== CUSTOM APP BAR STICKY =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 67, // 30px atas + 37px icon/back
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09), // soft shadow bawah
                    blurRadius: 16,
                    offset: const Offset(0, 2), // ke bawah
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
                    'Detail Ajuan',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ],
              ),
            ),

            // ========== SCROLLABLE CONTENT ==========
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// JARAK 33PX setelah appbar custom
                    const SizedBox(height: 33),

                    // Tanggal Pengajuan
                    Text(
                      'Tanggal Pengajuan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.date,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Data Produk
                    Text(
                      'Data Produk',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Foto Produk
                    Text(
                      'Foto Produk',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 89,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(data.imagePath, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 22),

                    // Nama Produk
                    Text(
                      'Nama Produk',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.productName,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Deskripsi Produk
                    Text(
                      'Deskripsi Produk',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Nama Toko
                    Text(
                      'Nama Toko',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.storeName,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Kategori Produk
                    Text(
                      'Kategori Produk',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    _CategoryBadge(type: data.categoryType),
                    const SizedBox(height: 15),

                    // VARIASI
                    Text(
                      'Variasi',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(variations.length, (i) {
                          final v = variations[i];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: i == variations.length - 1 ? 0 : 14,
                            ),
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF373E3C),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                v,
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF373E3C),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Harga
                    Text(
                      'Harga',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      price,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            // ====== BOTTOM BUTTONS STICKY ======
            Container(
              padding: const EdgeInsets.fromLTRB(20, 29, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09), // shadow soft
                    blurRadius: 16,
                    offset: const Offset(0, -2), // shadow ke atas dikit
                  ),
                ],
              ),
              child: AdminDualActionButtons(
                rejectText: "Tolak",
                acceptText: "Terima",
                onReject: () async {
                  final reason = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminRejectReasonPage(),
                    ),
                  );
                  if (reason != null && reason is String && reason.isNotEmpty) {
                    Navigator.of(
                      context,
                    ).pop();
                  }
                },
                onAccept: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const SuccessDialog(
                      message: "Ajuan Produk Berhasil Diterima",
                    ),
                  );
                  // 1.5 detik dialog tampil
                  await Future.delayed(const Duration(milliseconds: 2000));
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(); // Tutup dialog

                  // Tambah delay 250ms supaya transisi balik ke page smooth
                  await Future.delayed(const Duration(milliseconds: 250));
                  Navigator.of(context).pop(); // Tutup halaman detail
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final CategoryType type;
  const _CategoryBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = categoryLabels[type]!;
    final color = getCategoryColor(type);

    return Container(
      width: 120,
      height: 23,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getCategoryBgColor(type),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 7),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
