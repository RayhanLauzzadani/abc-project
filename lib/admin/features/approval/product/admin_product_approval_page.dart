import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/product_approval_card.dart';
import 'widgets/admin_product_approval_detail_page.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:abc_e_mart/admin/data/models/admin_product_data.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';

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

  final List<AdminProductData> products = [
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Kaos ABC Emart",
      categoryType: CategoryType.merchandise,
      storeName: "Toko ABC",
      date: "01/07/2025, 10:30 AM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Buku Tulis",
      categoryType: CategoryType.alatTulis,
      storeName: "Nippon Mart",
      date: "02/07/2025, 09:15 AM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Tabung Erlenmeyer",
      categoryType: CategoryType.alatLab,
      storeName: "Lab Jaya",
      date: "03/07/2025, 11:11 AM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Tas Daur Ulang",
      categoryType: CategoryType.produkDaurUlang,
      storeName: "EcoStore",
      date: "04/07/2025, 14:02 PM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Masker Kesehatan",
      categoryType: CategoryType.produkKesehatan,
      storeName: "Sehat Sentosa",
      date: "05/07/2025, 08:44 AM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Ayam Betutu",
      categoryType: CategoryType.makanan,
      storeName: "Nippon Mart",
      date: "06/07/2025, 12:00 PM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Teh Botol",
      categoryType: CategoryType.minuman,
      storeName: "Toko Minum",
      date: "07/07/2025, 13:05 PM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Keripik Kentang",
      categoryType: CategoryType.snacks,
      storeName: "Snack Corner",
      date: "08/07/2025, 16:22 PM",
    ),
    AdminProductData(
      imagePath: 'assets/images/nihonmart.png',
      productName: "Lain-lain",
      categoryType: CategoryType.lainnya,
      storeName: "Toko Random",
      date: "09/07/2025, 17:30 PM",
    ),
  ];

  int _selectedCategory = 0; // 0 = Semua
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Filtering produk berdasarkan kategori dan search (jika perlu)
    List<AdminProductData> filteredProducts = products
        .where((p) {
          final matchCategory = _selectedCategory == 0
              ? true
              : p.categoryType == categories[_selectedCategory - 1];
          final matchSearch = _searchText.isEmpty
              ? true
              : p.productName.toLowerCase().contains(_searchText.toLowerCase()) ||
                p.storeName.toLowerCase().contains(_searchText.toLowerCase());
          return matchCategory && matchSearch;
        })
        .toList();

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

        /// === REPLACE SEARCH BAR HERE ===
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

        // KATEGORI HORIZONTAL (LABEL PALING KANAN MUNCUL FULL)
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            itemCount: categories.length + 1,
            itemBuilder: (context, idx) {
              if (idx == 0) {
                final isSelected = _selectedCategory == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = 0),
                    child: Container(
                      height: 30, // <-- Fixed height
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2066CF)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2066CF)
                              : const Color(0xFF9A9A9A),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Semua',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF9A9A9A),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final realIdx = idx - 1;
              final type = categories[realIdx];
              final isSelected = _selectedCategory == (realIdx + 1);
              return Padding(
                padding: EdgeInsets.only(
                  right: realIdx == categories.length - 1
                      ? 0
                      : 10, // gap 10px antar label
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = realIdx + 1),
                  child: Container(
                    height: 30, // <-- Fixed height
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2066CF)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2066CF)
                            : const Color(0xFF9A9A9A),
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      categoryLabels[type]!,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9A9A9A),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 21),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredProducts.length,
            itemBuilder: (context, idx) {
              final p = filteredProducts[idx];
              return ProductApprovalCard(
                data: p,
                onDetail: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminProductApprovalDetailPage(
                        data: p,
                        description:
                            "Produk ${p.productName} adalah produk berkualitas tinggi yang bisa kamu pilih untuk berbagai kebutuhan. Tersedia di ${p.storeName}.",
                        variations: ["Standar", "Jumbo", "Paket Lengkap"],
                        price: "25.000",
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 20),
          ),
        ),
      ],
    );
  }
}
