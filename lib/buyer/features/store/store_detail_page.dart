import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/widgets/store_product_card.dart';
import 'package:abc_e_mart/buyer/features/product/product_detail_page.dart';
import 'package:abc_e_mart/buyer/data/dummy/dummy_data.dart';

import 'package:abc_e_mart/buyer/widgets/store_rating_review.dart';

const colorPrimary = Color(0xFF1C55C0);
const colorInput = Color(0xFF404040);
const colorPlaceholder = Color(0xFF757575);

class StoreDetailPage extends StatefulWidget {
  final Map<String, dynamic> store;
  const StoreDetailPage({super.key, required this.store});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    "Semua",
    "Makanan",
    "Minuman",
    "Snacks",
    "Lainnya",
  ];
  int selectedCategory = 0;

  int tabIndex = 0;
  late TabController _tabController;

  late List<Map<String, dynamic>> allProducts;

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

  String searchQuery = '';

  List<Map<String, dynamic>> get filteredProducts {
    final activeCategory = categories[selectedCategory];
    return allProducts.where((prod) {
      final matchCategory = (activeCategory == "Semua") || (prod["category"] == activeCategory);
      final matchQuery = prod["name"].toLowerCase().contains(searchQuery.toLowerCase());
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
            // --- BACK + LOGO in Stack
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  // LOGO TOKO - diturunkan sedikit biar gak mentok ke atas
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

                  // BACK BUTTON - responsif terhadap notch
                  Positioned(
                    top: 8, // JANGAN terlalu besar
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

            // --- Info Toko, Rating, Chat, Favorit (semua rata kiri)
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
            const SizedBox(height: 10),

            // --- Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // TAB 1: Katalog
                  _KatalogTab(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onCategorySelected: (i) {
                      setState(() => selectedCategory = i);
                    },
                    filteredProducts: filteredProducts,
                    onProductTap: (product) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product),
                        ),
                      );
                    },
                    onSearch: _handleSearch,
                  ),
                  // TAB 2: Rating & Ulasan
                  // Langsung pakai widgets dari folder widgets
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

// --- Tab Bar & Katalog (Tidak perlu diubah) ---

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

class _KatalogTab extends StatelessWidget {
  final List<String> categories;
  final int selectedCategory;
  final ValueChanged<int> onCategorySelected;
  final List<Map<String, dynamic>> filteredProducts;
  final void Function(Map<String, dynamic> product) onProductTap;
  final ValueChanged<String> onSearch;

  const _KatalogTab({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.filteredProducts,
    required this.onProductTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 14),
          child: SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: categories.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 6,
                  right: i == categories.length - 1 ? 0 : 6,
                ),
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Text(
                    categories[i],
                    style: GoogleFonts.dmSans(
                      color: selectedCategory == i ? Colors.white : colorPlaceholder,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  selected: selectedCategory == i,
                  onSelected: (_) => onCategorySelected(i),
                  selectedColor: colorPrimary,
                  backgroundColor: const Color(0xFFF2F2F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
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
        ),
      ],
    );
  }
}
