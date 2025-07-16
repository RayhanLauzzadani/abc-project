import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:abc_e_mart/data/models/category_type.dart'; // Untuk CategoryBadge
import 'package:abc_e_mart/admin/data/models/admin_product_data.dart';
import 'package:abc_e_mart/admin/widgets/admin_dual_action_buttons.dart';
import 'package:abc_e_mart/admin/widgets/success_dialog.dart';
import 'package:abc_e_mart/admin/widgets/admin_reject_reason_page.dart';

class AdminProductApprovalDetailPage extends StatelessWidget {
  final AdminProductData data;

  const AdminProductApprovalDetailPage({super.key, required this.data});

  // REJECT PRODUCT (plus push notif ke seller, not to buyer!)
  Future<void> _onReject(BuildContext context) async {
    final reason = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AdminRejectReasonPage()),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        final productDoc = FirebaseFirestore.instance
            .collection('productsApplication')
            .doc(data.docId);

        // Update status product application
        await productDoc.update({
          'status': 'Ditolak',
          'rejectionReason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
        });

        // ONLY to seller (ownerId)
        final ownerId = data.rawData['ownerId'] ?? '';
        if (ownerId != '') {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(ownerId)
              .collection('notifications')
              .add({
            'title': 'Produk Ditolak',
            'body':
                'Produk "${data.rawData['name'] ?? ''}" dari toko ${data.rawData['storeName'] ?? ''} ditolak. Alasan: $reason',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': 'product_rejected',
            'productId': data.docId,
            'reason': reason, // simpan alasan agar bisa ditampilkan
          });
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              const SuccessDialog(message: "Ajuan Produk Berhasil Ditolak"),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context, rootNavigator: true).pop();
        await Future.delayed(const Duration(milliseconds: 200));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui status: $e')));
      }
    }
  }

  // APPROVE PRODUCT (plus push notif ke seller only)
  Future<void> _onAccept(BuildContext context) async {
    try {
      final productData = data.rawData;

      // Update product application status
      await FirebaseFirestore.instance
          .collection('productsApplication')
          .doc(data.docId)
          .update({
        'status': 'Sukses',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Publish product ke collection utama
      final productId = data.docId;
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .set({
        'shopId': productData['shopId'] ?? '',
        'ownerId': productData['ownerId'] ?? '',
        'name': productData['name'] ?? '',
        'imageUrl': productData['imageUrl'] ?? '',
        'price': productData['price'] ?? 0,
        'category': productData['category'] ?? '',
        'description': productData['description'] ?? '',
        'stock': productData['stock'] ?? 0,
        'sold': 0,
        'minBuy': productData['minBuy'] ?? 1,
        'varieties': productData['varieties'] ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'storeName': productData['storeName'] ?? '-',
      });

      // ONLY to seller (ownerId)
      final ownerId = productData['ownerId'] ?? '';
      if (ownerId != '') {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(ownerId)
            .collection('notifications')
            .add({
          'title': 'Produk Disetujui',
          'body':
              'Produk "${productData['name'] ?? ''}" dari toko ${productData['storeName'] ?? ''} telah disetujui dan tayang di ABC e-Mart.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'product_approved',
          'productId': productId,
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const SuccessDialog(message: "Ajuan Produk Berhasil Diterima"),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = data.rawData;
    final List<dynamic> variations = product['varieties'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ----- MAIN CONTENT -----
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      "Tanggal Pengajuan",
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.date,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6D6D6D),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: const Color(0xFFE5E7EB),
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 22),

                    // Section Data Produk
                    Text(
                      "Data Produk",
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 17),

                    // Foto Produk
                    Text(
                      "Foto Produk",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: 89,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: (product['imageUrl'] ?? '').toString().isNotEmpty
                          ? Image.network(product['imageUrl'], fit: BoxFit.cover)
                          : const Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Nama Produk
                    Text(
                      "Nama Produk",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['name'] ?? '-',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: const Color(0xFF232323),
                      ),
                    ),
                    const SizedBox(height: 13),

                    // Deskripsi Produk
                    Text(
                      "Deskripsi Produk",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['description'] ?? '-',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: const Color(0xFF232323),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 13),

                    // Nama Toko
                    Text(
                      "Nama Toko",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['storeName'] ?? '-',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: const Color(0xFF232323),
                      ),
                    ),
                    const SizedBox(height: 13),

                    // Kategori Produk
                    Text(
                      "Kategori Produk",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    CategoryBadge(type: data.categoryType),
                    const SizedBox(height: 13),

                    // Variasi
                    Text(
                      "Variasi",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 7),
                    variations.isNotEmpty
                        ? Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: variations
                                .map((v) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFCBCBCB)),
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        v.toString(),
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13,
                                          color: const Color(0xFF373E3C),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          )
                        : Text(
                            "-",
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: const Color(0xFF666666),
                            ),
                          ),
                    const SizedBox(height: 13),

                    // Harga
                    Text(
                      "Harga",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rp ${product['price'] != null ? product['price'].toString() : '0'}",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: const Color(0xFF232323),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ----- STICKY HEADER -----
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
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
                      "Detail Ajuan",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF232323),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----- STICKY BUTTON BOTTOM -----
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -3),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: AdminDualActionButtons(
                  rejectText: "Tolak",
                  acceptText: "Terima",
                  onReject: () => _onReject(context),
                  onAccept: () => _onAccept(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
