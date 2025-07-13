import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/widgets/store_product_card.dart';
import 'package:abc_e_mart/buyer/features/product/product_detail_page.dart';
import 'package:abc_e_mart/buyer/data/dummy/dummy_data.dart';
import 'package:abc_e_mart/buyer/widgets/store_rating_review.dart';
import 'package:abc_e_mart/widgets/category_selector.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:lucide_icons/lucide_icons.dart';

const colorPrimary = Color(0xFF1C55C0);
const colorInput = Color(0xFF404040);
const colorPlaceholder = Color(0xFF757575);

// === Pakai global ===
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

class StoreDetailPage extends StatefulWidget {
  final Map<String, dynamic> store;
  const StoreDetailPage({super.key, required this.store});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int selectedCategory = 0;
  int tabIndex = 0;
  late TabController _tabController;
  late List<Map<String, dynamic>> allProducts;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    allProducts = dummyProducts
        .where((prod) => prod['storeId'] == widget.store['id'])
        .toList();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          tabIndex = _tabController.index;
        });
      }
    });
  }

  // Mapping string dari dummy ke enum CategoryType
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
      return allProducts.where((prod) =>
        prod["name"].toString().toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    final CategoryType selected = categoryList[selectedCategory - 1];
    return allProducts.where((prod) {
      final catType = stringToCategoryType(prod["category"] ?? "");
      final matchCategory = catType == selected;
      final matchQuery = prod["name"].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();
  }

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BACK + LOGO
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        widget.store['image'] ?? 'assets/images/logo.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 16,
                    child: SafeArea(
                      bottom: false,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: colorPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- Info Toko
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.store['name'] ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.store['distance']} • ${widget.store['duration']}",
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      color: colorPlaceholder,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 17),
                      const SizedBox(width: 2),
                      Text(
                        "${widget.store['rating']} ",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        "(435 Ratings)",
                        style: GoogleFonts.dmSans(
                          color: Colors.orange[700],
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // --- Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: custom_widgets.SearchBar(
                controller: _searchController,
                onChanged: _handleSearch,
              ),
            ),
            const SizedBox(height: 14),

            // --- Tab Bar Custom
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 30),
              child: _StoreTabBar(
                tabIndex: tabIndex,
                onTabChanged: (i) {
                  setState(() {
                    tabIndex = i;
                    _tabController.animateTo(i);
                  });
                },
              ),
            ),
            const SizedBox(height: 4),

            // --- Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // TAB 1: Katalog
                  _KatalogTabGlobalCategory(
                    selectedCategory: selectedCategory,
                    onCategorySelected: (i) {
                      setState(() => selectedCategory = i);
                    },
                    filteredProducts: filteredProducts,
                    onProductTap: (product) {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                  ),
                  // TAB 2: Rating & Ulasan
                  const StoreRatingReview(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreTabBar extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  const _StoreTabBar({
    required this.tabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["Katalog", "Rating & Ulasan"];
    final textStyles = [
      GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 15),
      GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 15),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainters = List.generate(tabs.length, (i) {
          final tp = TextPainter(
            text: TextSpan(text: tabs[i], style: textStyles[i]),
            textDirection: TextDirection.ltr,
          )..layout();
          return tp;
        });

        final tabSpacing = 32.0;
        final tabLefts = <double>[];
        double left = 0;
        for (int i = 0; i < tabs.length; i++) {
          tabLefts.add(left);
          left += textPainters[i].width + tabSpacing;
        }
        final underlineLeft = tabIndex == 0 ? tabLefts[0] : tabLefts[1] - 3.0;
        final underlineWidth = textPainters[tabIndex].width;

        return SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 2,
                  color: const Color(0x11B2B2B2),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(tabs.length, (i) {
                  final isActive = tabIndex == i;
                  return GestureDetector(
                    onTap: () => onTabChanged(i),
                    child: Container(
                      margin: EdgeInsets.only(right: i == 0 ? tabSpacing : 0),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.ease,
                        style: GoogleFonts.dmSans(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 15,
                          color: isActive ? const Color(0xFF202020) : const Color(0xFFB2B2B2),
                        ),
                        child: Text(tabs[i]),
                      ),
                    ),
                  );
                }),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.ease,
                left: underlineLeft,
                bottom: 0,
                child: Container(
                  width: underlineWidth,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Tab Katalog Pakai CategorySelector global! ---
class _KatalogTabGlobalCategory extends StatelessWidget {
  final int selectedCategory;
  final ValueChanged<int> onCategorySelected;
  final List<Map<String, dynamic>> filteredProducts;
  final void Function(Map<String, dynamic> product) onProductTap;

  const _KatalogTabGlobalCategory({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.filteredProducts,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gunakan widget CategorySelector global
        Padding(
          padding: const EdgeInsets.only(top: 14, left: 4, bottom: 8, right: 0),
          child: CategorySelector(
            categories: categoryList,
            selectedIndex: selectedCategory,
            onSelected: onCategorySelected,
          ),
        ),
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
                        "Mohon cek katalog lainnya.",
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6, top: 0),
                  child: GridView.builder(
                    itemCount: filteredProducts.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return StoreProductCard(
                        name: product["name"] ?? "",
                        price: "Rp ${product["price"].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                        imagePath: product["image"] ?? "",
                        onTap: () => onProductTap(product),
                      );
                    },
                  ),
                ),
        )
      ],
    );
  }
}
