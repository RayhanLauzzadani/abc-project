import 'package:abc_e_mart/seller/data/models/ad.dart';
import 'package:abc_e_mart/seller/features/ads/add_ads.dart';
import 'package:abc_e_mart/seller/features/ads/ad_cart.dart';
import 'package:abc_e_mart/seller/features/ads/ads_detail_page.dart';
import 'package:abc_e_mart/seller/data/services/ad_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model Store sederhana
class StoreModel {
  final String id;
  final String name;
  StoreModel({required this.id, required this.name});

  factory StoreModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
}

class AdsListPage extends StatefulWidget {
  final String sellerId;
  const AdsListPage({super.key, required this.sellerId});

  @override
  State<AdsListPage> createState() => _AdsListPageState();
}

class _AdsListPageState extends State<AdsListPage> {
  int selectedStatus = 0;
  String searchQuery = "";

  final statusList = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];

  // Data backend
  List<AdApplication> _ads = [];
  bool _isLoading = true;

  // Data store
  StoreModel? _store;
  bool _loadingStore = true;

  @override
  void initState() {
    super.initState();
    _fetchStore();
    _fetchAds();
  }

  Future<void> _fetchStore() async {
    setState(() => _loadingStore = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('stores')
        .where('ownerId', isEqualTo: widget.sellerId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _store = StoreModel.fromDoc(snapshot.docs.first);
        _loadingStore = false;
      });
    } else {
      setState(() => _loadingStore = false);
    }
  }

  Future<void> _fetchAds() async {
    setState(() => _isLoading = true);
    final result = await AdService.getApplicationsBySeller(widget.sellerId);
    setState(() {
      _ads = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter ads sesuai status & search query
    List<AdApplication> filteredAds = _ads.where((ad) {
      bool matchesStatus = selectedStatus == 0 ||
          ad.status.toLowerCase() == statusList[selectedStatus].toLowerCase();
      bool matchesQuery = searchQuery.isEmpty ||
          ad.judul.toLowerCase().contains(searchQuery.toLowerCase());
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
                      onPressed: (_loadingStore || _store == null)
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddAdsPage(
                                    sellerId: widget.sellerId,
                                    storeId: _store!.id,
                                    storeName: _store!.name,
                                  ),
                                ),
                              );
                              _fetchAds();
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
                      case 'Disetujui':
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAds.isEmpty
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
                                      ad: ad, // <--- langsung pass objek AdApplication
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
