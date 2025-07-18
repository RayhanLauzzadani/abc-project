import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavbarItemData> _items = [
    _NavbarItemData(label: "Beranda", icon: "assets/icons/home.svg"),
    _NavbarItemData(label: "Toko", icon: "assets/icons/store.svg"),
    _NavbarItemData(label: "Produk", icon: "assets/icons/box.svg"),
    _NavbarItemData(label: "Iklan", icon: "assets/icons/megaphone.svg"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -1),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40), // <-- HERE
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (index) {
          final selected = index == currentIndex;
          final item = _items[index];
          final color = selected
              ? const Color(0xFF1C55C0)
              : const Color(0xFFB4B4B4);

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 58, // Agak kecil supaya muat dengan padding 40px
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    item.icon,
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                      letterSpacing: 0.1,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavbarItemData {
  final String label;
  final String icon;

  const _NavbarItemData({required this.label, required this.icon});
}
