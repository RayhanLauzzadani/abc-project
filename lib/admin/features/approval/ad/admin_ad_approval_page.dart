import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';
import 'package:abc_e_mart/admin/features/approval/ad/admin_ad_approval_detail_page.dart';
import 'package:abc_e_mart/seller/data/models/ad.dart';
import 'package:abc_e_mart/seller/data/services/ad_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminAdApprovalCard extends StatelessWidget {
  final String title;
  final String storeName;
  final String period;
  final String date;
  final VoidCallback? onDetail;

  const AdminAdApprovalCard({
    super.key,
    required this.title,
    required this.storeName,
    required this.period,
    required this.date,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // 10px rounded
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 5),
            // Store Name with Icon
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/store.svg',
                  width: 16,
                  height: 16,
                  color: const Color(0xFF373E3C),
                ),
                const SizedBox(width: 5),
                Text(
                  storeName,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF373E3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Period
            Text(
              period,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 10),
            // Date and Detail Iklan
            Row(
              children: [
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDetail,
                  child: Row(
                    children: [
                      Text(
                        "Detail Iklan",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
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
      ),
    );
  }
}

// ==== PAGE ADMIN IKLAN ====
class AdminAdApprovalPage extends StatefulWidget {
  const AdminAdApprovalPage({super.key});

  @override
  State<AdminAdApprovalPage> createState() => _AdminAdApprovalPageState();
}

class _AdminAdApprovalPageState extends State<AdminAdApprovalPage> {
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 31),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Persetujuan Iklan",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: const Color(0xFF373E3C),
              ),
            ),
          ),
          const SizedBox(height: 23),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AdminSearchBar(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchText = val),
            ),
          ),
          const SizedBox(height: 16),

          // === LIST ===
          Expanded(
            child: StreamBuilder<List<AdApplication>>(
              stream: AdService.listenAllApplications(status: "Menunggu"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _emptyAdSubmissions(); // ⬅️ pakai empty state megaphone
                }

                final ads = snapshot.data!;
                final search = _searchText.trim().toLowerCase();
                final filteredAds = ads.where((ad) =>
                  search.isEmpty ||
                  ad.judul.toLowerCase().contains(search) ||
                  ad.storeName.toLowerCase().contains(search)
                ).toList();

                if (filteredAds.isEmpty) {
                  return _emptySearchResult();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filteredAds.length,
                  itemBuilder: (context, idx) {
                    final ad = filteredAds[idx];
                    final durasi = ad.durasiSelesai.difference(ad.durasiMulai).inDays + 1;
                    final period = "$durasi Hari • "
                        "${DateFormat('d MMMM', 'id_ID').format(ad.durasiMulai)} – "
                        "${DateFormat('d MMMM yyyy', 'id_ID').format(ad.durasiSelesai)}";
                    final tanggalAjukan = DateFormat('dd/MM/yyyy, HH:mm').format(ad.createdAt);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AdminAdApprovalCard(
                        title: ad.judul,
                        storeName: ad.storeName,
                        period: period,
                        date: tanggalAjukan,
                        onDetail: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminAdApprovalDetailPage(ad: ad),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _emptyAdSubmissions() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.megaphone, size: 54, color: const Color(0xFFE2E7EF)),
          const SizedBox(height: 16),
          Text(
            "Belum ada pengajuan iklan",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF373E3C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Semua pengajuan iklan akan tampil di sini\njika ada ajuan baru dari penjual.",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF9A9A9A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _emptySearchResult() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.search, size: 48, color: const Color(0xFFE2E7EF)),
          const SizedBox(height: 12),
          Text(
            "Tidak ada hasil sesuai pencarian.",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: const Color(0xFF9A9A9A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Coba gunakan kata kunci lain.",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFFB1B1B1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

