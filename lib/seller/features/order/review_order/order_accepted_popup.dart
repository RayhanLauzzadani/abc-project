import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OrderAcceptedPopup extends StatefulWidget {
  final String message;
  final String lottiePath;
  final double lottieSize;
  final Duration autoCloseDuration;

  const OrderAcceptedPopup({
    super.key,
    this.message = "Pesanan Diterima!",
    this.lottiePath = "assets/lottie/order_success.json",
    this.lottieSize = 160, // Ukuran lebih besar
    this.autoCloseDuration = const Duration(seconds: 3),
  });

  @override
  State<OrderAcceptedPopup> createState() => _OrderAcceptedPopupState();
}

class _OrderAcceptedPopupState extends State<OrderAcceptedPopup> {
  @override
  void initState() {
    super.initState();
    // Tutup otomatis setelah 3 detik
    Future.delayed(widget.autoCloseDuration, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              widget.lottiePath,
              width: widget.lottieSize,
              height: widget.lottieSize,
              repeat: false,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
