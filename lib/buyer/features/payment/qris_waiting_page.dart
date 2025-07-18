import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
// Import OrderDetailPage
import 'order_detail_sheet.dart';

class QrisWaitingPage extends StatefulWidget {
  final int total; // in Rupiah
  final String orderId;
  final String qrData; // data string untuk QRIS
  final Duration countdown; // misal: Duration(minutes: 8)
  final VoidCallback? onBack;

  // Tambahan, misal ingin tampilkan nama toko & jumlah pesanan
  final int jumlahPesanan;
  final String namaToko;

  const QrisWaitingPage({
    Key? key,
    required this.total,
    required this.orderId,
    required this.qrData,
    this.countdown = const Duration(minutes: 8),
    this.onBack,
    required this.jumlahPesanan,
    required this.namaToko,
  }) : super(key: key);

  @override
  State<QrisWaitingPage> createState() => _QrisWaitingPageState();
}

class _QrisWaitingPageState extends State<QrisWaitingPage> {
  late Duration _remaining;
  Timer? _timer;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _remaining = widget.countdown;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining = _remaining - const Duration(seconds: 1));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get minutes =>
      _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
  String get seconds =>
      _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.only(bottom: 13, top: 13, left: 10),
          child: SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onBack ?? () => Navigator.pop(context),
                  child: Container(
                    width: 37,
                    height: 37,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Menunggu Pembayaran',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: const Color(0xFF232323),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        children: [
          // Instruksi atas
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              child: Text(
                "Selesaikan Pembayaran dengan\nQRIS sebelum waktu habis",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
              ),
            ),
          ),
          // Countdown timer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "$minutes:$seconds",
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Menit",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // CARD: Rincian Pesanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Teks Rincian dan Harga
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rincian Pesanan",
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF373E3C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Rp${widget.total.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C55C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Link "Detail" - bukan button!
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        builder: (context) => OrderDetailSheet(
                          orderId: widget.orderId,
                          total: widget.total,
                          jumlahPesanan: widget.jumlahPesanan,
                          namaToko: widget.namaToko,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text(
                        "Detail",
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF1C55C0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // QRIS QR Code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E5E5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
              child: Column(
                children: [
                  QrImageView(
                    data: widget.qrData,
                    size: 180,
                    backgroundColor: Colors.white,
                    errorStateBuilder: (cxt, err) => Center(
                      child: Text(
                        'QR tidak valid',
                        style: GoogleFonts.dmSans(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/qris.png', height: 20),
                      const SizedBox(width: 7),
                      const Text(
                        "Powered by QRIS",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF232323),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Instruksi Pembayaran QRIS (Accordion)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: _QrisCustomAccordion(
              expanded: _expanded,
              onToggle: () => setState(() => _expanded = !_expanded),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// Widget Custom Accordion
class _QrisCustomAccordion extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _QrisCustomAccordion({
    required this.expanded,
    required this.onToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 7, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Cara pembayaran QRIS",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 32,
                      color: Color(0xFF232323),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QrisInstructionText(
                      "1. Pindai/screenshot/unduh kode QR yang muncul di layar dengan membuka aplikasi BCA Mobile, IMkas, Gopay, OVO, DANA, Shopeepay, LinkAja, atau aplikasi pembayaran lain yang mendukung QRIS.",
                    ),
                    const SizedBox(height: 9),
                    _QrisInstructionText(
                      "2. Periksa detail transaksi Anda di aplikasi, lalu klik tombol Bayar.",
                    ),
                    const SizedBox(height: 9),
                    _QrisInstructionText("3. Masukkan PIN Anda."),
                    const SizedBox(height: 9),
                    _QrisInstructionText(
                      "4. Setelah transaksi selesai, kembali ke halaman ini.",
                    ),
                  ],
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Widget Instruksi QRIS
class _QrisInstructionText extends StatelessWidget {
  final String text;
  const _QrisInstructionText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        color: const Color(0xFF373E3C),
        height: 1.5,
      ),
    );
  }
}
