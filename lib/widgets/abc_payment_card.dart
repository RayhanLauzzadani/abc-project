import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ABCPaymentCard extends StatelessWidget {
  final int balance;
  final String title;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onHistory;
  final String logoAsset;
  final EdgeInsetsGeometry margin;

  final IconData primaryIcon;
  final IconData historyIcon;
  final Color actionColor;

  // ukuran & gaya yang bisa di-tweak
  final double logoOuterSize;        // diameter lingkaran logo
  final double logoInnerPadding;     // padding di dalam lingkaran
  final double actionBoxSize;        // sisi kotak aksi
  final double actionIconSize;       // ukuran ikon aksi
  final double actionGap;            // jarak antar aksi
  final double cardBorderWidth;      // ketebalan border kartu
  final Color cardBorderColor;

  const ABCPaymentCard({
    super.key,
    required this.balance,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onHistory,
    this.title = 'ABC Payment',
    this.logoAsset = 'assets/images/paymentlogo.png',
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.primaryIcon = Icons.add,
    this.historyIcon = Icons.history,
    this.actionColor = const Color(0xFF2056D3),

    this.logoOuterSize = 48,        
    this.logoInnerPadding = 8,
    this.actionBoxSize = 28,         
    this.actionIconSize = 20,    
    this.actionGap = 22,          
    this.cardBorderWidth = 1.2,
    this.cardBorderColor = const Color(0xFFEDEFF5),
  });

  String _formatRupiah(int nominal) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return f.format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul di luar kartu
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),

          // Kartu saldo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: cardBorderColor, width: cardBorderWidth),
            ),
            child: Row(
              children: [
                // ===== Logo bulat tanpa border (ujung clean/transparan) =====
                Container(
                  width: logoOuterSize,
                  height: logoOuterSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF4F6FF), // latar soft tanpa garis tepi
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(logoInnerPadding),
                    child: Image.asset(logoAsset, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),

                // Saldo
                Expanded(
                  child: Text(
                    _formatRupiah(balance),
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),

                // Aksi kanan
                Row(
                  children: [
                    _SquareAction(
                      label: primaryLabel,
                      icon: primaryIcon,
                      boxSize: actionBoxSize,
                      iconSize: actionIconSize,
                      color: actionColor,
                      onTap: onPrimary,
                    ),
                    SizedBox(width: actionGap),
                    _SquareAction(
                      label: 'Riwayat',
                      icon: historyIcon,
                      boxSize: actionBoxSize,
                      iconSize: actionIconSize,
                      color: actionColor,
                      onTap: onHistory,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final double boxSize;
  final double iconSize;
  final Color color;
  final VoidCallback onTap;

  const _SquareAction({
    required this.label,
    required this.icon,
    required this.boxSize,
    required this.iconSize,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: boxSize,
              height: boxSize,
              child: Center(
                child: Icon(icon, size: iconSize, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}