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
    _NavbarItemData(label: "Beranda", icon: "assets/icons/home.svg"),
    _NavbarItemData(label: "Katalog", icon: "assets/icons/catalog.svg"),
    _NavbarItemData(label: "Keranjang", icon: "assets/icons/cart.svg"),
    _NavbarItemData(label: "Obrolan", icon: "assets/icons/chat.svg"),
    _NavbarItemData(label: "Profil", icon: "assets/icons/profile.svg"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -1),
            blurRadius: 6,
          ),
        ],
      ),

      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final selected = index == currentIndex;
          final item = _items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: selected ? 1.0 : 0.0,
                end: selected ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 250),
              builder: (context, value, child) {
                final color = Color.lerp(
                  const Color(0xFFB4B4B4),
                  const Color(0xFF00509D),
                  value,
                );
                final fontWeight = selected ? FontWeight.w600 : FontWeight.w400;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      item.icon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: fontWeight,
                        color: color,
                      ),
                    ),
                  ],
                );
              },
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
