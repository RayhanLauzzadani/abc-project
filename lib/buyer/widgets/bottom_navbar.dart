import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavbarItemData> _items = [
    _NavbarItemData(
      label: "Beranda",
      icon: "assets/icons/home.svg",
    ),
    _NavbarItemData(
      label: "Katalog",
      icon: "assets/icons/catalog.svg",
    ),
    _NavbarItemData(
      label: "Keranjang",
      icon: "assets/icons/cart.svg",
    ),
    _NavbarItemData(
      label: "Obrolan",
      icon: "assets/iconsv/chat.svg",
    ),
    _NavbarItemData(
      label: "Profil",
      icon: "assets/icons/profile.svg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F7F7), // warna background (bisa diganti)
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final selected = index == currentIndex;
          final item = _items[index];
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.translucent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  item.icon,
                  width: 23,
                  height: 23,
                  color: selected ? const Color(0xFF00509D) : const Color(0xFFB4B4B4),
                ),
                const SizedBox(height: 9),
                Text(
                  item.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: selected ? const Color(0xFF00509D) : const Color(0xFFB4B4B4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
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
  const _NavbarItemData({
    required this.label,
    required this.icon,
  });
}
