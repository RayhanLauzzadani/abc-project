import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:abc_e_mart/seller/data/models/ad.dart';

class AdCard extends StatelessWidget {
  final AdApplication ad;
  final VoidCallback onDetailTap;

  const AdCard({super.key, required this.ad, required this.onDetailTap});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFEAB600);
      case 'disetujui':
        return const Color(0xFF28A745);
      case 'ditolak':
        return const Color(0xFFDC3545);
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0x1AEAB600);
      case 'disetujui':
        return const Color(0x1A28A745);
      case 'ditolak':
        return const Color(0x1ADC3545);
      default:
        return Colors.grey.shade100;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return "Menunggu";
      case 'disetujui':
        return "Disetujui";
      case 'ditolak':
        return "Ditolak";
      default:
        return status;
    }
  }

  String get _periode {
    final mulai = DateFormat('d MMM yyyy', 'id').format(ad.durasiMulai);
    final selesai = DateFormat('d MMM yyyy', 'id').format(ad.durasiSelesai);
    final durasi = ad.durasiSelesai.difference(ad.durasiMulai).inDays + 1;
    return "$durasi Hari • $mulai - $selesai";
  }

  String get _createdAtText {
    final tanggal = DateFormat('dd/MM/yyyy, HH:mm').format(ad.createdAt);
    return "$tanggal WIB";
  }

  @override
  Widget build(BuildContext context) {
    final status = ad.status;
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9A9A9A), width: 1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Atas: Judul & status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Iklan : ${ad.judul}',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF373E3C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                height: 16,
                constraints: const BoxConstraints(
                  minWidth: 84.36,
                  maxWidth: 84.36,
                ),
                margin: const EdgeInsets.only(left: 8, top: 1),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: statusBg,
                  border: Border.all(color: statusColor, width: 1),
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  _statusText(status),
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: statusColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Periode
          Text(
            _periode,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: const Color(0xFF373E3C),
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 20),
          // Row: Tanggal pengajuan (kiri) & Detail (kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _createdAtText,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: const Color(0xFF9A9A9A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: onDetailTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Detail Iklan",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: const Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF777777),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
