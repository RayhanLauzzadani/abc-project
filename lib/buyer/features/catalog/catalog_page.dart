import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/data/dummy/dummy_data.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/features/product/product_card.dart';
import 'package:abc_e_mart/widgets/category_selector.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abc_e_mart/buyer/features/product/product_detail_page.dart';

const colorPlaceholder = Color(0xFF757575);

final List<CategoryType> categoryList = [
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

class CatalogPage extends StatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  int selectedCategory = 0;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // mapping String (dummyProducts) ke CategoryType
  CategoryType? stringToCategoryType(String value) {
    switch (value.trim().toLowerCase()) {
      case "merchandise": return CategoryType.merchandise;
      case "alat tulis kantor (atk)":
      case "alat tulis": return CategoryType.alatTulis;
      case "perlengkapan lab":
      case "alat lab": return CategoryType.alatLab;
      case "recycling product":
      case "produk daur ulang": return CategoryType.produkDaurUlang;
      case "produk kesehatan": return CategoryType.produkKesehatan;
      case "makanan": return CategoryType.makanan;
      case "minuman": return CategoryType.minuman;
      case "snacks": return CategoryType.snacks;
      case "lainnya": return CategoryType.lainnya;
      default: return null;
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    // 0 = Semua
    if (selectedCategory == 0) {
      return dummyProducts.where((prod) =>
        prod["name"].toString().toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    final CategoryType selected = categoryList[selectedCategory - 1];
    return dummyProducts.where((prod) {
      final catType = stringToCategoryType(prod["category"] ?? "");
      final matchCategory = catType == selected;
      final matchQuery = prod["name"].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Text(
              "Katalog Produk",
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: custom_widgets.SearchBar(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Chips kategori (pakai widget global)
          CategorySelector(
            categories: categoryList,
            selectedIndex: selectedCategory,
            onSelected: (i) => setState(() => selectedCategory = i),
          ),
          const SizedBox(height: 6),
          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.packageSearch,
                          size: 105,
                          color: Colors.grey[300],
                        ),
                        
                        const SizedBox(height: 28),
                        Text(
                          "Tidak ada produk yang ditemukan",
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          "Mohon cek katalog lainnya atau kata kunci yang berbeda.",
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (context, idx) => const SizedBox(height: 2),
                    itemBuilder: (context, idx) {
                      final product = filteredProducts[idx];
                      return ProductCard(
                        imagePath: product['image'] ?? '',
                        name: product['name'] ?? '',
                        price: product['price'] ?? 0,
                        rating: (product['rating'] as num?)?.toDouble() ?? 0,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(product: product),
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
