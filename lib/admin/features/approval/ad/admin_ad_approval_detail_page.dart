import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminAdApprovalDetailPage extends StatelessWidget {
  final String storeName;
  final String date;
  final String bannerUrl;
  final String adTitle;
  final String adProduct;
  final String adDuration;
  final String adDurationDays;
  final String paymentProofName;
  final String paymentProofSize;
  final String? paymentProofUrl;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onBannerTap;
  final VoidCallback? onProofTap;

  const AdminAdApprovalDetailPage({
    super.key,
    required this.storeName,
    required this.date,
    required this.bannerUrl,
    required this.adTitle,
    required this.adProduct,
    required this.adDuration,
    required this.adDurationDays,
    required this.paymentProofName,
    required this.paymentProofSize,
    this.paymentProofUrl,
    this.onAccept,
    this.onReject,
    this.onBannerTap,
    this.onProofTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===== STICKY APP BAR =====
            Container(
              height: 67,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
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
            // ======= SCROLLABLE CONTENT =======
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gap setelah appbar
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
                      date,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Divider
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: const Color(0xFFF2F2F3),
                    ),
                    // ===== Data Iklan Section =====
                    const SizedBox(height: 33),
                    Text(
                      'Detail Iklan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nama Toko
                    Text(
                      'Nama Toko',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeName,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    // Banner Iklan
                    const SizedBox(height: 15),
                    Text(
                      'Banner Iklan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onBannerTap,
                      child: Container(
                        width: double.infinity,
                        height: 146,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        clipBehavior: Clip.hardEdge,
                        alignment: Alignment.center,
                        child: bannerUrl.isEmpty
                            ? Text(
                                'Banner Iklan (390x160)',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: const Color(0xFF9A9A9A),
                                ),
                              )
                            : Image.network(
                                bannerUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 146,
                                errorBuilder: (ctx, _, __) => Icon(Icons.broken_image, color: Colors.grey[400]),
                              ),
                      ),
                    ),
                    // Judul Iklan
                    const SizedBox(height: 20),
                    Text(
                      'Judul Iklan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adTitle,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    // Produk Iklan
                    const SizedBox(height: 15),
                    Text(
                      'Produk Iklan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adProduct,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    // Durasi Iklan
                    const SizedBox(height: 15),
                    Text(
                      'Durasi Iklan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          adDuration,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: const Color(0xFF373E3C),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '($adDurationDays hari)',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF373E3C),
                          ),
                        ),
                      ],
                    ),
                    // Bukti Pembayaran
                    const SizedBox(height: 24),
                    Text(
                      'Bukti Pembayaran',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onProofTap,
                      child: Container(
                        width: 209,
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (paymentProofUrl != null && paymentProofUrl!.isNotEmpty)
                                    ? Image.network(
                                        paymentProofUrl!,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, __) => SvgPicture.asset(
                                          'assets/icons/image-placeholder.svg',
                                          width: 30,
                                          height: 30,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        'assets/icons/image-placeholder.svg',
                                        width: 30,
                                        height: 30,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    paymentProofName,
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: const Color(0xFF373E3C),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    paymentProofSize,
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 8,
                                      color: const Color(0xFF9A9A9A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9A9A9A),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // ====== SINGLE BUTTON DI BAWAH ======
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 59,
                child: ElevatedButton(
                  onPressed: onAccept ?? () {}, // Pasti active, warnanya biru!
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    "Setujui",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFFFAFAFA),
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
