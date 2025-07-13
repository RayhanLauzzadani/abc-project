import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';
import 'package:abc_e_mart/admin/features/approval/ad/admin_ad_approval_detail_page.dart';

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

class _AdApprovalData {
  final String title;
  final String storeName;
  final String period;
  final String date;

  _AdApprovalData({
    required this.title,
    required this.storeName,
    required this.period,
    required this.date,
  });
}

class _AdminAdApprovalPageState extends State<AdminAdApprovalPage> {
  final List<_AdApprovalData> ads = [
    _AdApprovalData(
      title: "Iklan : Ayam Geprek",
      storeName: "Nippon Mart",
      period: "3 Hari • 21 Juli – 23 Juli 2025",
      date: "30/06/2024, 4:15 PM",
    ),
    _AdApprovalData(
      title: "Iklan : Ayam Geprek",
      storeName: "Nippon Mart",
      period: "3 Hari • 21 Juli – 23 Juli 2025",
      date: "30/06/2024, 4:15 PM",
    ),
    _AdApprovalData(
      title: "Iklan : Ayam Geprek",
      storeName: "Nippon Mart",
      period: "3 Hari • 21 Juli – 23 Juli 2025",
      date: "30/06/2024, 4:15 PM",
    ),
    _AdApprovalData(
      title: "Iklan : Ayam Geprek",
      storeName: "Nippon Mart",
      period: "3 Hari • 21 Juli – 23 Juli 2025",
      date: "30/06/2024, 4:15 PM",
    ),
  ];

  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Filter ads by search text (title/storeName)
    final filteredAds = ads.where((ad) {
      final search = _searchText.trim().toLowerCase();
      return search.isEmpty ||
          ad.title.toLowerCase().contains(search) ||
          ad.storeName.toLowerCase().contains(search);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 31),
          child: Text(
            "Persetujuan Iklan",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 23),
        // === Search Bar (use widget global) ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AdminSearchBar(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchText = val),
          ),
        ),
        const SizedBox(height: 18),
        // === Card List ===
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filteredAds.length,
            itemBuilder: (context, idx) {
              final ad = filteredAds[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AdminAdApprovalCard(
                  title: ad.title,
                  storeName: ad.storeName,
                  period: ad.period,
                  date: ad.date,
                  onDetail: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminAdApprovalDetailPage(
                          storeName: ad.storeName,
                          date: ad.date,
                          bannerUrl: '', // Isi asset/url gambar banner jika ada
                          adTitle: ad.title,
                          adProduct: "Ayam Geprek", // Data produk terkait
                          adDuration: "21 Juli – 23 Juli 2025",
                          adDurationDays: "3",
                          paymentProofName: "Bukti Bayar.jpg",
                          paymentProofSize: "100.96 KB",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
