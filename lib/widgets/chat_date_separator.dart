import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatDateSeparator extends StatelessWidget {
  final DateTime date;

  const ChatDateSeparator({Key? key, required this.date}) : super(key: key);

  String _getLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return "Hari ini";
    if (diff == 1) return "Kemarin";
    // Format: 19 Juli 2025
    return "${d.day} ${_monthName(d.month)} ${d.year}";
  }

  String _monthName(int m) {
    const months = [
      '', // dummy, biar index 1=Januari
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 13),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          _getLabel(date),
          style: GoogleFonts.dmSans(
            color: const Color(0xFF6C6C6C),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
