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
              child: const Center(
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          // Icon Logout (trigger parent dialog!)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onLogoutTap, // <----- INI DOANG! PENTING
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDC3545), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.09),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout,
                    color: Color(0xFFDC3545),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
