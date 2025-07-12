import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';

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
    // Filter ads berdasarkan search text (judul/storeName)
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
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AdminSearchBar(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchText = val),
          ),
        ),
        const SizedBox(height: 18),
        // Daftar Iklan
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredAds.length,
            itemBuilder: (context, idx) {
              final ad = filteredAds[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon toko
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.store,
                          color: Color(0xFF7A7A7A),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Info Iklan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF232323),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ad.storeName,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xFF232323),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ad.period,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xFF232323),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  ad.date,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: Color(0xFF7A7A7A),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Navigasi ke detail iklan (if any)
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "Detail Iklan",
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: const Color(0xFF1C55C0),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                        color: Color(0xFF2066CF),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
