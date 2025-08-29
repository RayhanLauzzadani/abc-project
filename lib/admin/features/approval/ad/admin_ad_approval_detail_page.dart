import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abc_e_mart/seller/data/models/ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAdApprovalDetailPage extends StatefulWidget {
  final AdApplication ad;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const AdminAdApprovalDetailPage({
    super.key,
    required this.ad,
    this.onAccept,
    this.onReject,
  });

  @override
  State<AdminAdApprovalDetailPage> createState() => _AdminAdApprovalDetailPageState();
}

class _AdminAdApprovalDetailPageState extends State<AdminAdApprovalDetailPage> {
  bool isLoading = false;

  String fixText(String? v) => (v == null || v.trim().isEmpty) ? "-" : v;
  String formatDate(DateTime? dt) =>
      dt == null ? "-" : DateFormat('dd/MM/yyyy, HH:mm').format(dt);
  String formatPeriod(DateTime? mulai, DateTime? selesai) {
    if (mulai == null || selesai == null) return "-";
    final d1 = DateFormat('d MMMM yyyy', 'id_ID').format(mulai);
    final d2 = DateFormat('d MMMM yyyy', 'id_ID').format(selesai);
    final days = selesai.difference(mulai).inDays + 1;
    return "$days Hari • $d1 – $d2";
  }
  String fileNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return "-";
    final name = url.split('/').last.split('?').first;
    return name.length > 28 ? name.substring(0, 25) + '...' : name;
  }

  // === ACTION APPROVE LOGIC ===
  Future<void> _approveAd(BuildContext context) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      // Update status dan waktu di Firestore
      final docRef = FirebaseFirestore.instance.collection('adsApplication').doc(widget.ad.id);

      await docRef.update({
        'status': 'disetujui',
        'approvedAt': FieldValue.serverTimestamp(),
        // Pastikan field ini sudah sesuai dengan data valid:
        'durasiMulai': widget.ad.durasiMulai,
        'durasiSelesai': widget.ad.durasiSelesai,
        // Bisa tambahkan field lain kalau perlu...
      });

      // Buat notifikasi ke seller
      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.ad.sellerId)
        .collection('notifications')
        .add({
          'title': 'Iklan Disetujui',
          'body': 'Iklan "${widget.ad.judul}" sudah disetujui dan akan tampil otomatis sesuai jadwal.',
          'adId': widget.ad.id,
          'type': 'ad_approved',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Iklan telah disetujui dan penjadwalan otomatis sudah aktif.')),
      );

      // Callback jika ada
      widget.onAccept?.call();
      Navigator.pop(context, true); // balik dan reload list jika perlu
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyetujui iklan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final bannerUrl = ad.bannerUrl;
    final paymentProofUrl = ad.paymentProofUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==== CUSTOM APPBAR ====
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
            // ==== SCROLLABLE CONTENT ====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
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
                      formatDate(ad.createdAt),
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
                      fixText(ad.storeName),
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
                      onTap: () {
                        if (bannerUrl.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: InteractiveViewer(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(bannerUrl),
                                ),
                              ),
                            ),
                          );
                        }
                      },
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
                                'Banner Iklan (320x160)',
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
                      fixText(ad.judul),
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
                      fixText(ad.productName),
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
                          formatPeriod(ad.durasiMulai, ad.durasiSelesai),
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w400,
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
                      onTap: () {
                        if (paymentProofUrl.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: InteractiveViewer(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(paymentProofUrl),
                                ),
                              ),
                            ),
                          );
                        }
                      },
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
                                child: (paymentProofUrl.isNotEmpty)
                                    ? Image.network(
                                        paymentProofUrl,
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
                                    fileNameFromUrl(paymentProofUrl),
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: const Color(0xFF373E3C),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "-", // Ukuran file bisa diambil dari Firestore kalau disimpan, kalau tidak "-" saja
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
                  onPressed: isLoading ? null : () => _approveAd(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
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
