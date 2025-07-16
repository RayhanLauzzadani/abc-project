import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrisWaitingPage extends StatefulWidget {
  final int total; // in Rupiah
  final String orderId;
  final String qrData; // data string untuk QRIS
  final Duration countdown; // misal: Duration(minutes: 8)
  final VoidCallback? onBack;

  const QrisWaitingPage({
    super.key,
    required this.total,
    required this.orderId,
    required this.qrData,
    this.countdown = const Duration(minutes: 8),
    this.onBack,
  });

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

  String get minutes => _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
  String get seconds => _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
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
            const SizedBox(height: 23),
            Center(
              child: Column(
                children: [
                  Text(
                    "Selesaikan Pembayaran dengan\nQRIS sebelum waktu habis",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _QrisCountdownCircle(
                    minutes: minutes,
                    seconds: seconds,
                    percent: _remaining.inSeconds / widget.countdown.inSeconds,
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            // Rincian Pesanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rincian Pesanan",
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF232323),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Rp${widget.total.toString().replaceAllMapped(
                                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]}.',
                              )}",
                          style: GoogleFonts.dmSans(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Show detail pesanan (optional)
                      },
                      child: Text(
                        "Detail",
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF2563EB),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
                        // Ganti asset ke qris jika ada!
                        Image.asset('assets/images/qris.png', height: 20),
                        const SizedBox(width: 7),
                        const Text("Powered by QRIS",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF232323))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Instruksi Pembayaran QRIS (Accordion)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                      child: Row(
                        children: [
                          Text(
                            "Cara pembayaran QRIS",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              color: const Color(0xFF232323),
                            ),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 24,
                              color: Color(0xFF232323),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FB),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(13),
                        ),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _QrisInstructionItem(
                            "1. Pindai/screenshot/unduh kode QR yang muncul di layar dengan aplikasi BCA Mobile, IMkas, Gopay, OVO, DANA, Shopeepay, LinkAja, atau aplikasi pembayaran lain yang mendukung QRIS.",
                          ),
                          _QrisInstructionItem(
                            "2. Periksa detail transaksi Anda di aplikasi, lalu klik tombol Bayar.",
                          ),
                          _QrisInstructionItem(
                            "3. Masukkan PIN Anda.",
                          ),
                          _QrisInstructionItem(
                            "4. Setelah transaksi selesai, kembali ke halaman ini.",
                          ),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox(height: 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Widget untuk countdown timer bulat dengan label menit
class _QrisCountdownCircle extends StatelessWidget {
  final String minutes;
  final String seconds;
  final double percent; // 0.0 - 1.0

  const _QrisCountdownCircle({
    required this.minutes,
    required this.seconds,
    required this.percent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 82,
          height: 82,
          child: CircularProgressIndicator(
            value: percent,
            strokeWidth: 6,
            backgroundColor: const Color(0xFFE5EAF3),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$minutes:$seconds",
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2563EB),
              ),
            ),
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
      ],
    );
  }
}

class _QrisInstructionItem extends StatelessWidget {
  final String text;
  const _QrisInstructionItem(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 13.5,
          color: const Color(0xFF373E3C),
        ),
      ),
    );
  }
}
