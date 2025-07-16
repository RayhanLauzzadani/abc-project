import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/product_approval_card.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:abc_e_mart/admin/data/models/admin_product_data.dart';
import 'package:abc_e_mart/admin/features/approval/product/admin_product_approval_detail_page.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';
import 'package:abc_e_mart/widgets/category_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminProductApprovalPage extends StatefulWidget {
  const AdminProductApprovalPage({super.key});

  @override
  State<AdminProductApprovalPage> createState() =>
      _AdminProductApprovalPageState();
}

class _AdminProductApprovalPageState extends State<AdminProductApprovalPage> {
  final List<CategoryType> categories = [
    CategoryType.merchandise,
    CategoryType.alatTulis,
    CategoryType.alatLab,
    CategoryType.produkDaurUlang,
    CategoryType.produkKesehatan,
    CategoryType.makanan,
    CategoryType.minuman,
    CategoryType.snacks,
    CategoryType.lainnya,
  ];

  int _selectedCategory = 0; // 0 = Semua
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 31, left: 20, right: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Persetujuan Produk",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: const Color(0xFF373E3C),
              ),
            ),
          ),
        ),
        const SizedBox(height: 23),
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AdminSearchBar(
            controller: _searchController,
            onChanged: (val) => setState(() {
              _searchText = val;
            }),
          ),
        ),
        const SizedBox(height: 21),
        // KATEGORI
        CategorySelector(
          categories: categories,
          selectedIndex: _selectedCategory,
          onSelected: (i) => setState(() => _selectedCategory = i),
        ),
        const SizedBox(height: 21),

        // === LIST FIRESTORE ===
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('productsApplication')
                .where(
                  'status',
                  isEqualTo: 'Menunggu',
                ) // sesuai struktur Firestore kamu!
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Terjadi error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              // Mapping ke model sederhana
              List<AdminProductData> products = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                // mapping kategori string ke CategoryType (opsional, jika ingin filter kategori)
                final categoryLabel = (data['category'] ?? '').toString();
                CategoryType categoryType = categories.firstWhere(
                  (cat) => categoryLabels[cat] == categoryLabel,
                  orElse: () => CategoryType.lainnya,
                );
                // Tanggal
                String date = "-";
                final createdAt = data['createdAt'];
                if (createdAt != null) {
                  final dt = createdAt is Timestamp
                      ? createdAt.toDate()
                      : DateTime.tryParse(createdAt.toString());
                  if (dt != null) {
                    date =
                        "${dt.day.toString().padLeft(2, '0')}/"
                        "${dt.month.toString().padLeft(2, '0')}/"
                        "${dt.year}, "
                        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                  }
                }
                return AdminProductData(
                  docId: doc.id,
                  imagePath: data['imageUrl'] ?? '',
                  productName: data['name'] ?? '-',
                  categoryType: categoryType,
                  storeName: data['storeName'] ?? '',
                  date: date,
                  status: data['status'] ?? 'Menunggu',
                  description: data['description'] ?? '-',
                  price: (data['price'] is int)
                      ? data['price']
                      : int.tryParse('${data['price'] ?? 0}') ?? 0,
                  stock: (data['stock'] is int)
                      ? data['stock']
                      : int.tryParse('${data['stock'] ?? 0}') ?? 0,
                  shopId: data['shopId'] ?? '',
                  ownerId: data['ownerId'] ?? '',
                  rawData: data, // agar nanti detail mudah
                );
              }).toList();

              // --- FILTERING
              List<AdminProductData> filteredProducts = products.where((p) {
                final matchCategory = _selectedCategory == 0
                    ? true
                    : p.categoryType == categories[_selectedCategory - 1];
                final matchSearch = _searchText.isEmpty
                    ? true
                    : p.productName.toLowerCase().contains(
                            _searchText.toLowerCase(),
                          ) ||
                          p.storeName.toLowerCase().contains(
                            _searchText.toLowerCase(),
                          );
                return matchCategory && matchSearch;
              }).toList();

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 54,
                          color: const Color(0xFFE2E7EF),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada pengajuan produk",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF373E3C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Semua pengajuan produk akan tampil di sini\njika ada produk baru dari penjual.",
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

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: filteredProducts.length,
                itemBuilder: (context, idx) {
                  final p = filteredProducts[idx];
                  return ProductApprovalCard(
                    data: p,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminProductApprovalDetailPage(data: p),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 20),
              );
            },
          ),
        ),
      ],
    );
  }
}
