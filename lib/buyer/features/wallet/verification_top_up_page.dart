import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class VerificationTopUpPage extends StatelessWidget {
  final VoidCallback? onViewStatus;
  const VerificationTopUpPage({super.key, this.onViewStatus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 72,
        title: Text(
          'Status Verifikasi',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            color: const Color(0xFF111111),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/verification.json',
                width: 140,
                height: 140,
                repeat: true,            // <-- loop animation
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                'Saldo Sedang Diverifikasi',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Permintaan isi saldo Anda telah diterima dan sedang menunggu verifikasi dari admin. '
                'Kami akan memberi notifikasi setelah saldo berhasil ditambahkan ke akun Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (onViewStatus != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onViewStatus,
                  child: Text(
                    'Lihat Status Saldo',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF2056D3),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
