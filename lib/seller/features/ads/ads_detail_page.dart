import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/data/models/ad.dart';
import 'package:intl/intl.dart';

class AdsDetailPage extends StatelessWidget {
  final AdApplication ad;

  const AdsDetailPage({
    Key? key,
    required this.ad,
  }) : super(key: key);

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFEAB600);
      case 'disetujui':
        return const Color(0xFF12C765);
      case 'ditolak':
        return const Color(0xFFFF5B5B);
      default:
        return const Color(0xFFB2B2B2);
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return "Menunggu";
      case 'disetujui':
        return "Disetujui";
      case 'ditolak':
        return "Ditolak";
      default:
        return (status.isEmpty) ? "-" : status;
    }
  }

  String fixText(String? v) => (v == null || v.trim().isEmpty) ? "-" : v;

  @override
  Widget build(BuildContext context) {
    final String img = ad.bannerUrl.isNotEmpty
        ? ad.bannerUrl
        : "https://placehold.co/390x160/FAFAFA/9A9A9A?text=Banner+Iklan";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ==== MAIN BODY ====
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 78), // Padding bawah appbar custom
                  // ===== Tanggal Pengajuan =====
                  Text(
                    "Tanggal Pengajuan",
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fixText(DateFormat('yyyy-MM-dd').format(ad.createdAt)),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: const Color(0xFFF2F2F3),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    "Data Iklan",
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Status Verifikasi",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    height: 23,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: getStatusColor(ad.status), width: 1),
                        color: getStatusColor(ad.status).withOpacity(0.10),
                      ),
                      child: Text(
                        getStatusText(ad.status),
                        style: GoogleFonts.dmSans(
                          color: getStatusColor(ad.status),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Nama Toko",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fixText(ad.storeName),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Banner Iklan",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 146,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      color: Colors.grey[200],
                    ),
                    alignment: Alignment.center,
                    clipBehavior: Clip.hardEdge,
                    child: (img.isEmpty)
                        ? Text(
                            "Banner Iklan (390x160)",
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFF9A9A9A),
                              fontSize: 13,
                            ),
                          )
                        : Image.network(
                            img,
                            width: double.infinity,
                            height: 146,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                "Banner Iklan (390x160)",
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFF9A9A9A),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Judul Iklan",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fixText(ad.judul),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Produk Iklan",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fixText(ad.productName),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Durasi Iklan",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${ad.durasiMulai.day}/${ad.durasiMulai.month}/${ad.durasiMulai.year} - "
                    "${ad.durasiSelesai.day}/${ad.durasiSelesai.month}/${ad.durasiSelesai.year}",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ======= Bukti Pembayaran dengan Preview =======
                  Text(
                    "Bukti Pembayaran",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (ad.paymentProofUrl.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: InteractiveViewer(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(ad.paymentProofUrl),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 209,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 34,
                            alignment: Alignment.center,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: const Color(0xFFF5F5F5),
                              ),
                              child: Icon(Icons.image_outlined, size: 22, color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fixText(ad.paymentProofUrl),
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: const Color(0xFF373E3C),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "-",
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 9,
                                    color: const Color(0xFF9A9A9A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9A9A9A), size: 23),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            // ==== CUSTOM APPBAR ====
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4), // Hanya ke bawah
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2056D3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "Detail Iklan",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Color(0xFF373E3C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
