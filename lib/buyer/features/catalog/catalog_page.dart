import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/features/product/product_card.dart';
import 'package:abc_e_mart/widgets/category_selector.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abc_e_mart/buyer/features/product/product_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          // Product List Realtime dari Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyCatalog();
                }

                // --- Filter Data dari Firestore ---
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                // Filter kategori
                if (selectedCategory > 0) {
                  final catStr = categoryLabels[categoryList[selectedCategory - 1]]!;
                  docs = docs.where((doc) {
                    final c = doc['category'] ?? '';
                    return c.toString().toLowerCase().contains(catStr.toLowerCase());
                  }).toList();
                }
                // Filter search
                if (searchQuery.isNotEmpty) {
                  docs = docs.where((doc) =>
                      doc['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())
                  ).toList();
                }

                if (docs.isEmpty) {
                  return _emptyCatalog();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  itemCount: docs.length,
                  separatorBuilder: (context, idx) => const SizedBox(height: 2),
                  itemBuilder: (context, idx) {
                    final product = docs[idx].data() as Map<String, dynamic>;
                    product['id'] = docs[idx].id;
                    return _ProductCardWithStorageImage(product: product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCatalog() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageSearch, size: 105, color: Colors.grey[300]),
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
    );
  }
}

// --- Product Card langsung dari Firestore, tidak perlu FutureBuilder
class _ProductCardWithStorageImage extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCardWithStorageImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      imageUrl: product['imageUrl'] ?? '', // Ambil langsung dari Firestore
      name: product['name'] ?? '',
      price: product['price'] ?? 0,
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: {
              ...product,
            }),
          ),
        );
      },
    );
  }
}
