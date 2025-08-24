// lib/seller/features/wallet/success_withdrawal_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SuccessWithdrawalPage extends StatelessWidget {
  /// Arahkan ke homepage seller
  final VoidCallback? onGoHome;

  /// Arahkan ke halaman riwayat penarikan/riwayat transaksi
  final VoidCallback? onViewHistory;

  const SuccessWithdrawalPage({
    super.key,
    this.onGoHome,
    this.onViewHistory,
  });

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
          'Penarikan Saldo',
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
              // Lottie centang
              Lottie.asset(
                'assets/lottie/success_check.json',
                width: 140,
                height: 140,
                repeat: false,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),

              // Judul
              Text(
                'Penarikan Saldo Diverifikasi',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),

              // Deskripsi
              Text(
                'Permintaan penarikan saldo Anda telah dikirim dan sedang menunggu verifikasi dari tim admin. '
                'Kami akan mengirim notifikasi setelah dana berhasil ditransfer ke rekening tujuan Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 18),

              // Tombol utama
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (onGoHome != null) {
                      onGoHome!.call();
                    } else {
                      // default: kembali ke halaman root (homepage seller)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Link sekunder
              TextButton(
                onPressed: () {
                  if (onViewHistory != null) {
                    onViewHistory!.call();
                  } else {
                    // default: kembali ke halaman sebelumnya
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Lihat Status Penarikan',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF2056D3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
