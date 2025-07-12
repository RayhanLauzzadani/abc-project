import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/admin/widgets/admin_dual_action_buttons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminStoreApprovalDetailPage extends StatelessWidget {
  const AdminStoreApprovalDetailPage({super.key});

  void _onReject(BuildContext context) {
    // Tambahkan logic penolakan (misal update status di Firestore)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Ajuan toko ditolak!")));
  }

  void _onAccept(BuildContext context) {
    // Tambahkan logic persetujuan (misal update status di Firestore)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Ajuan toko diterima!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back & Title
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 37,
                          height: 37,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Detail Ajuan",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF232323),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Tanggal Pengajuan
                  Text(
                    "Tanggal Pengajuan",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "30 April 2025, 4:21 PM",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6D6D6D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: const Color(0xFFE5E7EB),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 22),

                  // Data Diri Pemilik Toko
                  Text(
                    "Data Diri Pemilik Toko",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 17),

                  // Foto KTP
                  Text(
                    "Foto KTP",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFFDADADA),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Foto KTP.jpg",
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: const Color(0xFF373E3C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "100.96 KB",
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: const Color(0xFF9B9B9B),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFBDBDBD),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  // Nama
                  Text(
                    "Nama",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rayhan Kautsar",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // NIK
                  Text(
                    "NIK",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "1233452718391373198391",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Nama Bank
                  Text(
                    "Nama Bank",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ABC Bank",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Nomor Rekening
                  Text(
                    "Nomor Rekening",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "1427316938636492343",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(
                    color: const Color(0xFFE5E7EB),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 18),

                  // Data Toko
                  Text(
                    "Data Toko",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 17),
                  // Logo toko
                  Text(
                    "Logo Toko",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFDADADA)),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/store.svg',
                        width: 36,
                        height: 36,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFDADADA),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Nama Toko
                  Text(
                    "Nama Toko",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Nippon Mart",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Deskripsi Singkat Toko
                  Text(
                    "Deskripsi Singkat Toko",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Toko yang menjual segala kebutuhan mahasiswa",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Alamat Lengkap Toko
                  Text(
                    "Alamat Lengkap Toko",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Jl. Ikan Hiu 24, Surabaya",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Nomor HP
                  Text(
                    "Nomor HP",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "082573420394810",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            // Sticky Button Area
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -3),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: AdminDualActionButtons(
                  onReject: () => _onReject(context),
                  onAccept: () => _onAccept(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
