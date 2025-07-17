import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/features/ads/ad_cart.dart';
import 'package:abc_e_mart/seller/features/ads/ads_detail_page.dart';

class AdsListPage extends StatefulWidget {
  final String sellerId;
  const AdsListPage({super.key, required this.sellerId});

  @override
  State<AdsListPage> createState() => _AdsListPageState();
}

class _AdsListPageState extends State<AdsListPage> {
  int selectedStatus = 0;
  String searchQuery = "";

  final statusList = ['Semua', 'Menunggu', 'Sukses', 'Ditolak'];

  // Dummy data
  final List<Map<String, dynamic>> dummyAds = [
    {
      'title': 'Ayam Geprek',
      'status': 'menunggu',
      'periode': '3 Hari • 21 Juli - 23 Juli 2025',
      'createdAt': DateTime(2024, 6, 30, 16, 15),
      'namaToko': 'Nippon Mart',
      'produkIklan': 'Ayam Geprek',
      'bannerImage': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?fit=crop&w=390&q=80',
      'buktiPembayaranFile': 'bukti_ayam_geprek.jpg',
      'buktiPembayaranSize': 105.2,
      'tanggalPengajuan': '30 April 2025, 16:21 PM',
      'tanggalDurasi': '21 Juli - 23 Juli 2025 (3 hari)',
    },
    {
      'title': 'Beng - Beng',
      'status': 'sukses',
      'periode': '3 Hari • 21 Juli - 23 Juli 2025',
      'createdAt': DateTime(2024, 6, 30, 16, 15),
      'namaToko': 'Toko Jaya',
      'produkIklan': 'Beng - Beng',
      'bannerImage': 'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?fit=crop&w=390&q=80',
      'buktiPembayaranFile': 'bukti_bengbeng.jpg',
      'buktiPembayaranSize': 99.5,
      'tanggalPengajuan': '30 April 2025, 16:21 PM',
      'tanggalDurasi': '21 Juli - 23 Juli 2025 (3 hari)',
    },
    {
      'title': 'Pulpen Sarasa',
      'status': 'ditolak',
      'periode': '3 Hari • 21 Juli - 23 Juli 2025',
      'createdAt': DateTime(2024, 6, 30, 16, 15),
      'namaToko': 'Alat Tulis Murah',
      'produkIklan': 'Pulpen Sarasa',
      'bannerImage': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?fit=crop&w=390&q=80',
      'buktiPembayaranFile': 'bukti_sarasa.jpg',
      'buktiPembayaranSize': 78.3,
      'tanggalPengajuan': '30 April 2025, 16:21 PM',
      'tanggalDurasi': '21 Juli - 23 Juli 2025 (3 hari)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter dummy sesuai status & search query
    List<Map<String, dynamic>> filteredAds = dummyAds.where((ad) {
      bool matchesStatus = selectedStatus == 0 ||
          ad['status'].toString().toLowerCase() == statusList[selectedStatus].toLowerCase();
      bool matchesQuery = searchQuery.isEmpty ||
          (ad['title'] ?? '').toLowerCase().contains(searchQuery.toLowerCase());
      return matchesStatus && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar Custom
            Padding(
              padding: const EdgeInsets.only(top: 22, left: 20, right: 20, bottom: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2056D3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Iklan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2056D3),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: () {
                        // TODO: Panggil page Ajukan Iklan
                      },
                      child: Text(
                        '+ Ajukan Iklan',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F3),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    Icon(Icons.search, color: Color(0xFFB2B2B2), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Color(0xFF777777),
                          fontWeight: FontWeight.w400,
                        ),
                        cursorColor: Color(0xFF777777),
                        decoration: InputDecoration(
                          hintText: "Cari iklan yang anda ajukan.....",
                          hintStyle: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: Color(0xFF777777),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) => setState(() => searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 21),
            // Status Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 33,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: statusList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final label = statusList[idx];
                    final isSelected = selectedStatus == idx;
                    Color color;
                    switch (label) {
                      case 'Menunggu':
                        color = const Color(0xFFFFD600);
                        break;
                      case 'Sukses':
                        color = const Color(0xFF12C765);
                        break;
                      case 'Ditolak':
                        color = const Color(0xFFFF5B5B);
                        break;
                      default:
                        color = const Color(0xFF2056D3);
                    }
                    double width = 77;
                    if (label == 'Menunggu') width = 100;
                    return GestureDetector(
                      onTap: () => setState(() => selectedStatus = idx),
                      child: SizedBox(
                        width: width,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(label == 'Semua' ? 1.0 : 0.10)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected ? color : const Color(0xFFB2B2B2),
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: isSelected
                                    ? (label == 'Semua' ? Colors.white : color)
                                    : const Color(0xFFB2B2B2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // === List Iklan ===
            Expanded(
              child: filteredAds.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada iklan ditemukan.',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF777777),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      itemCount: filteredAds.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, idx) {
                        final ad = filteredAds[idx];
                        return AdCard(
                          ad: ad,
                          onDetailTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdsDetailPage(
                                  status: ad['status']?.toString() ?? '',
                                  namaToko: ad['namaToko']?.toString() ?? 'Nippon Mart',
                                  judulIklan: ad['title']?.toString() ?? '-',
                                  produkIklan: ad['produkIklan']?.toString() ?? 'Ayam Geprek',
                                  tanggalPengajuan: ad['tanggalPengajuan']?.toString() ?? '30 April 2025, 4:21 PM',
                                  tanggalDurasi: ad['tanggalDurasi']?.toString() ?? '21 Juli - 23 Juli 2025 (3 hari)',
                                  bannerImage: ad['bannerImage']?.toString() ?? '',
                                  buktiPembayaranFile: ad['buktiPembayaranFile']?.toString() ?? '-',
                                  buktiPembayaranSize: (ad['buktiPembayaranSize'] != null)
                                      ? double.tryParse(ad['buktiPembayaranSize'].toString()) ?? 0
                                      : 0,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
