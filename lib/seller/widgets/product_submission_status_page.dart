import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:abc_e_mart/seller/features/products/products_page.dart';

class ProductSubmissionStatusPage extends StatelessWidget {
  final String storeId;

  const ProductSubmissionStatusPage({
    Key? key,
    required this.storeId,
  }) : super(key: key);

  static const colorPrimary = Color(0xFF1C55C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 29),
              Text(
                "Pengajuan Produk",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF373E3C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 95),
              SizedBox(
                height: 150,
                width: 150,
                child: Lottie.asset(
                  'assets/lottie/verification.json',
                  repeat: true,
                ),
              ),
              const SizedBox(height: 37),
              Text(
                "Produk Berhasil Diajukan",
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Produk kamu sedang menunggu verifikasi dari admin.",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: const Color(0xFF9A9A9A),
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 44),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ProductsPage(
                          storeId: storeId,
                          initialTab: 1,
                          fromSubmission: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Lihat Produk Menunggu Persetujuan",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
