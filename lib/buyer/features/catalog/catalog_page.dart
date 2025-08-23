import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/features/product/product_card.dart';
import 'package:abc_e_mart/widgets/category_selector.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abc_e_mart/buyer/features/product/product_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// store list UI
import 'package:abc_e_mart/buyer/features/store/store_card.dart';
import 'package:abc_e_mart/buyer/features/store/store_detail_page.dart';

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
  final int selectedCategory;
  final ValueChanged<int>? onCategoryChanged;

  const CatalogPage({
    Key? key,
    required this.selectedCategory,
    this.onCategoryChanged,
  }) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  late int _selectedCategory;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // tabs
  int _tabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      setState(() {
        _selectedCategory = widget.selectedCategory;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Text(
              "Katalog",
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
          ),

          // Tabs ala halaman Favorit
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CatalogTabBar(
              selectedIndex: _tabIndex,
              onTabChanged: (idx) {
                setState(() {
                  _tabIndex = idx;
                  _tabController.animateTo(idx);
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar (dipakai kedua tab)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: custom_widgets.SearchBar(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              hintText: "Cari yang anda inginkan....",
            ),
          ),
          SizedBox(height: _tabIndex == 0 ? 16 : 4),

          // Category hanya untuk tab Produk
          if (_tabIndex == 0) ...[
            CategorySelector(
              categories: categoryList,
              selectedIndex: _selectedCategory,
              onSelected: (i) {
                setState(() => _selectedCategory = i);
                widget.onCategoryChanged?.call(i);
              },
            ),
            const SizedBox(height: 6),
          ],

          // Konten
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ======= Tab 0: Produk Tersedia =======
                _ProductList(
                  selectedCategory: _selectedCategory,
                  searchQuery: searchQuery,
                  userUid: userUid,
                ),

                // ======= Tab 1: Toko Tersedia =======
                _StoreList(
                  searchQuery: searchQuery,
                  userUid: userUid,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final int selectedCategory;
  final String searchQuery;
  final String userUid;
  const _ProductList({
    required this.selectedCategory,
    required this.searchQuery,
    required this.userUid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyCatalog("Tidak ada produk yang ditemukan");
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        // produk bukan milik user
        if (userUid.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['ownerId'] != userUid;
          }).toList();
        }

        // kategori
        if (selectedCategory > 0) {
          final catStr =
              categoryLabels[categoryList[selectedCategory - 1]]!;
          docs = docs.where((doc) {
            final c = (doc['category'] ?? '').toString();
            return c.toLowerCase().contains(catStr.toLowerCase());
          }).toList();
        }

        // pencarian
        if (searchQuery.trim().isNotEmpty) {
          final q = searchQuery.trim().toLowerCase();
          docs = docs.where((doc) {
            final name = (doc['name'] ?? '').toString().toLowerCase();
            return name.contains(q);
          }).toList();
        }

        if (docs.isEmpty) {
          return _emptyCatalog("Tidak ada produk yang ditemukan");
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, idx) {
            final product = docs[idx].data() as Map<String, dynamic>;
            product['id'] = docs[idx].id;
            return ProductCard(
              imageUrl: product['imageUrl'] ?? '',
              name: product['name'] ?? '',
              price: product['price'] ?? 0,
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: {...product}),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StoreList extends StatelessWidget {
  final String searchQuery;
  final String userUid;
  const _StoreList({
    required this.searchQuery,
    required this.userUid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stores').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyCatalog("Tidak ada toko yang ditemukan");
        }

        var docs = snapshot.data!.docs;

        // sembunyikan toko milik user
        if (userUid.isNotEmpty) {
          docs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['ownerId'] != userUid;
          }).toList();
        }

        // pencarian nama toko
        if (searchQuery.trim().isNotEmpty) {
          final q = searchQuery.trim().toLowerCase();
          docs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            return name.contains(q);
          }).toList();
        }

        if (docs.isEmpty) {
          return _emptyCatalog("Tidak ada toko yang ditemukan");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return StoreCard(
              imageUrl: data['logoUrl'] ?? '',
              storeName: data['name'] ?? '',
              rating: (data['rating'] as num?)?.toDouble() ?? 0,
              ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoreDetailPage(store: {...data, 'id': docs[index].id}),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget _emptyCatalog(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.packageSearch, size: 105, color: Colors.grey[300]),
        const SizedBox(height: 28),
        Text(
          message,
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 7),
        Text(
          "Coba ubah kata kunci atau cek katalog lainnya.",
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

/// Tab bar animasi (port dari halaman Favorit, label disesuaikan)
class _CatalogTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  const _CatalogTabBar({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["Produk Tersedia", "Toko Tersedia"];

    final textStyle = GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 15);

    return LayoutBuilder(
      builder: (context, constraints) {
        final paintrs = List.generate(tabs.length, (i) {
          final tp = TextPainter(
            text: TextSpan(text: tabs[i], style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();
        return tp;
        });

        const spacing = 32.0;
        final lefts = <double>[];
        double left = 0;
        for (int i = 0; i < tabs.length; i++) {
          lefts.add(left);
          left += paintrs[i].width + spacing;
        }

        final underlineLeft = selectedIndex == 0 ? lefts[0] : lefts[1] - 4.0;
        final underlineWidth = paintrs[selectedIndex].width;

        return SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(height: 2, color: const Color(0x11B2B2B2)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(tabs.length, (i) {
                  final isActive = selectedIndex == i;
                  return GestureDetector(
                    onTap: isActive ? null : () => onTabChanged(i),
                    child: Container(
                      margin: EdgeInsets.only(right: i == 0 ? spacing : 0),
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
