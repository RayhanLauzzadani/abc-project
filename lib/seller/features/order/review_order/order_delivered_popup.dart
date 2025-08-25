import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OrderDeliveredPopup extends StatefulWidget {
  final String message;
  final String lottiePath;
  final double lottieSize;
  final Duration autoCloseDuration;

  const OrderDeliveredPopup({
    super.key,
    this.message = "Pesanan Berhasil Dikirim!",
    this.lottiePath = "assets/lottie/deliverysuccess.json",
    this.lottieSize = 160,
    this.autoCloseDuration = const Duration(seconds: 2),
  });

  @override
  State<OrderDeliveredPopup> createState() => _OrderDeliveredPopupState();
}

class _OrderDeliveredPopupState extends State<OrderDeliveredPopup> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.autoCloseDuration, () {
      if (mounted) Navigator.of(context).pop(); // auto-close
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
            const SizedBox(height: 18),
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