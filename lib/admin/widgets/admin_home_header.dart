import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomeHeader extends StatelessWidget {
  final VoidCallback? onNotif;
  final VoidCallback? onLogoutTap;
  const AdminHomeHeader({
    super.key,
    this.onNotif,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 31, left: 0, right: 0, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Beranda Admin",
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF373E3C),
            ),
          ),
          const Spacer(),
          // Icon Notifikasi
          GestureDetector(
            onTap: onNotif,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00509D),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          // Icon Logout
          GestureDetector(
            onTap: onLogoutTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDC3545),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.logout,
                  color: const Color(0xFFDC3545),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
