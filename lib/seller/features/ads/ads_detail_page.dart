import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdsDetailPage extends StatelessWidget {
  final String status;
  final String namaToko;
  final String judulIklan;
  final String produkIklan;
  final String tanggalPengajuan;
  final String tanggalDurasi;
  final String bannerImage;
  final String buktiPembayaranFile;
  final double buktiPembayaranSize;

  const AdsDetailPage({
    Key? key,
    required this.status,
    required this.namaToko,
    required this.judulIklan,
    required this.produkIklan,
    required this.tanggalPengajuan,
    required this.tanggalDurasi,
    required this.bannerImage,
    required this.buktiPembayaranFile,
    required this.buktiPembayaranSize,
  }) : super(key: key);

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFEAB600);
      case 'sukses':
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
      case 'sukses':
        return "Sukses";
      case 'ditolak':
        return "Ditolak";
      default:
        return (status.isEmpty) ? "-" : status;
    }
  }

  String fixText(String? v) => (v == null || v.trim().isEmpty) ? "-" : v;
  String fixFileSize(double? v) =>
      (v == null || v <= 0) ? "-" : "${v.toStringAsFixed(2)} KB";

  @override
  Widget build(BuildContext context) {
    final String img = bannerImage.isNotEmpty
        ? bannerImage
        : "https://placehold.co/390x160/FAFAFA/9A9A9A?text=Banner+Iklan";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2056D3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Detail Iklan",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tanggal Pengajuan
              Text(
                "Tanggal Pengajuan",
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                fixText(tanggalPengajuan),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                  height: 24 / 14,
                ),
              ),
              const SizedBox(height: 14),

              // Garis
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFFF2F2F3),
              ),
              const SizedBox(height: 18),

              // Data Iklan
              Text(
                "Data Iklan",
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 14),

              // Status Verifikasi (label lalu badge di bawahnya)
              Text(
                "Status Verifikasi",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 120,
                height: 23,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: getStatusColor(status), width: 1),
                    color: getStatusColor(status).withOpacity(0.10),
                  ),
                  child: Text(
                    getStatusText(status),
                    style: GoogleFonts.dmSans(
                      color: getStatusColor(status),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nama Toko
              Text(
                "Nama Toko",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fixText(namaToko),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                  height: 24 / 14,
                ),
              ),
              const SizedBox(height: 14),

              // Banner Iklan
              Text(
                "Banner Iklan",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFF9A9A9A), width: 0.5),
                  color: Colors.white,
                ),
                child: (img.isEmpty)
                    ? Center(
                        child: Text(
                          "Banner Iklan",
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF9A9A9A),
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          img,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              "Banner Iklan",
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF9A9A9A),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Judul Iklan
              Text(
                "Judul Iklan",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fixText(judulIklan),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                  height: 24 / 14,
                ),
              ),
              const SizedBox(height: 14),

              // Produk Iklan
              Text(
                "Produk Iklan",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fixText(produkIklan),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                  height: 24 / 14,
                ),
              ),
              const SizedBox(height: 14),

              // Durasi Iklan
              Text(
                "Durasi Iklan",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fixText(tanggalDurasi),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                  height: 24 / 14,
                ),
              ),
              const SizedBox(height: 14),

              // Bukti Pembayaran
              Text(
                "Bukti Pembayaran",
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 7),

              // ===== BOX BUKTI PEMBAYARAN ala Figma =====
              Container(
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
                    // ICON GAMBAR (atau pdf/file lain)
                    Container(
                      width: 34, // agar sedikit center
                      alignment: Alignment.center,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: const Color(0xFFF5F5F5),
                        ),
                        child: Icon(Icons.image_outlined, size: 22, color: Colors.grey.shade400),
                        // Ganti icon sesuai jenis file jika ingin dinamis
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Nama file dan size
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fixText(buktiPembayaranFile),
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
                            fixFileSize(buktiPembayaranSize),
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 9,
                              color: const Color(0xFF9A9A9A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow kanan
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF9A9A9A), size: 23),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
