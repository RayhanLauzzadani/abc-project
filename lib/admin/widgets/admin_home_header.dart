import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomeHeader extends StatelessWidget {
  final VoidCallback? onNotif;
  final VoidCallback? onLogoutTap;
  const AdminHomeHeader({super.key, this.onNotif, this.onLogoutTap});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[600]),
            const SizedBox(width: 8),
            Text(
              "Keluar Akun",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Text(
            "Apakah Anda yakin ingin keluar dari akun?",
            style: GoogleFonts.dmSans(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center, // Center the actions!
        actionsPadding: const EdgeInsets.only(bottom: 18, top: 8),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button "Batal"
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[400]!),
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 12,
                  ),
                  textStyle: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                child: const Text("Batal"),
              ),
              const SizedBox(width: 20),
              // Button "Keluar"
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onLogoutTap != null) onLogoutTap!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF2066CF,
                  ), // Sesuai biru di gambar
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 12,
                  ),
                  textStyle: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                child: const Text("Keluar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          // Icon Logout (tetap pakai Icons.logout, lebih modern)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showLogoutDialog(context),
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
                    Icons.logout, // Tetap icon logout
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
