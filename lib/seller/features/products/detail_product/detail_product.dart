import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/data/models/category_type.dart';

class SellerProductDetailPage extends StatelessWidget {
  final String productId;
  final bool fromApplication;

  const SellerProductDetailPage({
    super.key,
    required this.productId,
    this.fromApplication = false,
  });

  @override
  Widget build(BuildContext context) {
    final collection = fromApplication ? 'productsApplication' : 'products';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(collection)
              .doc(productId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Produk tidak ditemukan."));
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List varieties = data['varieties'] ?? [];
            final CategoryType catType = mapCategoryType(data['category']);

            // Penentuan status & reason (khusus productsApplication)
            String? status;
            String? rejectionReason;
            if (fromApplication) {
              status = data['status'];
              if (status == 'Ditolak') {
                rejectionReason = data['rejectionReason'] ?? "-";
              }
            }

            final bool isSukses = !fromApplication;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 70, 16, 34),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ======= DATA PRODUK =======
                        Text(
                          "Data Produk",
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // FOTO
                        Text(
                          "Foto Produk",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF373E3C),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          width: 89,
                          height: 76,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: (data['imageUrl'] ?? '').toString().isNotEmpty
                              ? Image.network(data['imageUrl'], fit: BoxFit.cover)
                              : const Icon(
                                  Icons.image_outlined,
                                  size: 34,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(height: 20),

                        // NAMA PRODUK
                        Text("Nama Produk", style: _labelStyle()),
                        const SizedBox(height: 6),
                        Text(data['name'] ?? '-', style: _valueStyle()),
                        const SizedBox(height: 18),

                        // DESKRIPSI
                        Text("Deskripsi Produk", style: _labelStyle()),
                        const SizedBox(height: 6),
                        Text(
                          data['description'] ?? '-',
                          style: _valueStyle().copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 18),

                        // NAMA TOKO
                        Text("Nama Toko", style: _labelStyle()),
                        const SizedBox(height: 6),
                        Text(data['storeName'] ?? '-', style: _valueStyle()),
                        const SizedBox(height: 18),

                        // STATUS VERIFIKASI (Khusus productsApplication)
                        if (fromApplication && status != null) ...[
                          Text("Status Verifikasi", style: _labelStyle()),
                          const SizedBox(height: 6),
                          _StatusBadge(status: status),
                          const SizedBox(height: 18),
                          if (status == 'Ditolak' && rejectionReason != null) ...[
                            Text("Alasan Penolakan", style: _labelStyle()),
                            const SizedBox(height: 6),
                            _RejectionReason(reason: rejectionReason),
                            const SizedBox(height: 18),
                          ],
                        ],
                        // STATUS SUKSES (Khusus products)
                        if (isSukses) ...[
                          Text("Status Verifikasi", style: _labelStyle()),
                          const SizedBox(height: 6),
                          _StatusBadge(status: 'Sukses'),
                          const SizedBox(height: 18),
                        ],

                        // KATEGORI PRODUK
                        Text("Kategori Produk", style: _labelStyle()),
                        const SizedBox(height: 6),
                        CategoryBadge(type: catType),
                        const SizedBox(height: 18),

                        // VARIASI
                        Text("Variasi", style: _labelStyle()),
                        const SizedBox(height: 9),
                        varieties.isNotEmpty
                            ? Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: varieties
                                    .map((v) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFCBCBCB)),
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
                            : Text("-", style: _valueStyle().copyWith(fontSize: 13, color: const Color(0xFF666666))),
                        const SizedBox(height: 18),

                        // HARGA
                        Text("Harga", style: _labelStyle()),
                        const SizedBox(height: 6),
                        Text(
                          "Rp ${data['price'] != null ? data['price'].toString() : '0'}",
                          style: _valueStyle(),
                        ),
                        const SizedBox(height: 18),

                        // STOK
                        Text("Stok", style: _labelStyle()),
                        const SizedBox(height: 6),
                        Text(
                          "${data['stock'] ?? 0}",
                          style: _valueStyle(),
                        ),
                        const SizedBox(height: 18),

                        // MINIMUM PEMBELIAN
                        Text("Minimum Pembelian", style: _labelStyle()),
                        const SizedBox(height: 6),
                        Text(
                          "${data['minBuy'] ?? 1}",
                          style: _valueStyle(),
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
                // HEADER
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 12), // Lebar padding lebih kecil biar muat
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Detail Produk",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: const Color(0xFF232323),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Label style (Naikkan ukuran)
  TextStyle _labelStyle() => GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 16, // was 14
        color: const Color(0xFF373E3C),
      );

  // Value style (bisa dibiarkan)
  TextStyle _valueStyle() => GoogleFonts.dmSans(
        fontWeight: FontWeight.normal,
        fontSize: 15, // was 14
        color: const Color(0xFF232323),
      );
}

// Widget badge status
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color, borderColor, textColor;
    String text;
    if (status == 'Sukses') {
      color = const Color(0x1418BC5B);
      borderColor = const Color(0xFF18BC5B);
      textColor = const Color(0xFF18BC5B);
      text = "• Sukses";
    } else if (status == 'Menunggu') {
      color = const Color(0x14FFD600);
      borderColor = const Color(0xFFFFD600);
      textColor = const Color(0xFFFFB800);
      text = "• Menunggu";
    } else {
      // Ditolak atau status lain
      color = const Color(0x14FF5B5B);
      borderColor = const Color(0xFFFF5B5B);
      textColor = const Color(0xFFFF5B5B);
      text = "• Ditolak";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Widget alasan penolakan
class _RejectionReason extends StatelessWidget {
  final String reason;
  const _RejectionReason({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x14FF5B5B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF5B5B), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFF5B5B), size: 18),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              reason,
              style: GoogleFonts.dmSans(
                color: const Color(0xFFFF5B5B),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
