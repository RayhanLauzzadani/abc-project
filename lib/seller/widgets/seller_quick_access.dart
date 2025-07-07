import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerQuickAccess extends StatelessWidget {
  final void Function(int)? onTap;
  final double iconSize; // Tambahan agar size icon bisa diubah dari luar

  const SellerQuickAccess({
    super.key,
    this.onTap,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle
            Text(
              'Akses Cepat',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gunakan fitur ini agar mengatur toko makin sat-set!',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 28),
            _QuickAccessGrid(onTap: onTap, iconSize: iconSize),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  final void Function(int)? onTap;
  final double iconSize;
  const _QuickAccessGrid({this.onTap, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    // Bisa tambahkan iconSize tiap fitur, misal: 'iconSize': 32,
    final features = [
      {'icon': 'assets/icons/box.svg', 'label': 'Produk Toko'},
      {'icon': 'assets/icons/order.svg', 'label': 'Pesanan'},
      {'icon': 'assets/icons/chat.svg', 'label': 'Obrolan'},
      {'icon': 'assets/icons/star.svg', 'label': 'Rating Toko'},
      {'icon': 'assets/icons/transaction.svg', 'label': 'Transaksi'},
      {'icon': 'assets/icons/megaphone.svg', 'label': 'Iklan'},
    ];

    Widget buildRow(int start) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (i) {
          int idx = start + i;
          final feat = features[idx];
          return _QuickAccessItem(
            iconPath: feat['icon']!,
            label: feat['label']!,
            onTap: () => onTap?.call(idx),
            iconSize: iconSize, // bisa diubah dari luar
          );
        }),
      );
    }

    return Column(
      children: [
        buildRow(0),
        const SizedBox(height: 18),
        buildRow(3),
      ],
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;
  final double iconSize;

  const _QuickAccessItem({
    required this.iconPath,
    required this.label,
    this.onTap,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0x33FFC90D), // 20% Opacity
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                colorFilter: const ColorFilter.mode(Color(0xFFFFC90D), BlendMode.srcIn),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.bold, // <-- BOLD!
              color: const Color(0xFF373E3C),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
