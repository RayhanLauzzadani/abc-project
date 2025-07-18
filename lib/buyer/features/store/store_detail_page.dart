import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/widgets/store_product_card.dart';
import 'package:abc_e_mart/buyer/features/product/product_detail_page.dart';
import 'package:abc_e_mart/buyer/features/chat/chat_detail_page.dart';
import 'package:abc_e_mart/buyer/widgets/store_rating_review.dart';
import 'package:abc_e_mart/widgets/category_selector.dart';
import 'package:abc_e_mart/data/models/category_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

const colorPrimary = Color(0xFF1C55C0);
const colorPlaceholder = Color(0xFF757575);
const colorDivider = Color(0xFFE5E5E5);

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

String formatRating(num rating) {
  double rounded = (rating * 10).round() / 10.0;
  return rounded.toStringAsFixed(1);
}


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
  String searchQuery = '';

  bool isFavoritedStore = false;
  bool favLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          tabIndex = _tabController.index;
        });
      }
    });
    _currentUser = FirebaseAuth.instance.currentUser;
    _checkIsFavoritedStore();
  }

  Future<void> _checkIsFavoritedStore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final favDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteStores')
        .doc(widget.store['id'])
        .get();
    setState(() {
      isFavoritedStore = favDoc.exists;
    });
  }

  Future<void> _toggleFavoriteStore() async {
    setState(() => favLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteStores')
        .doc(widget.store['id']);

    if (isFavoritedStore) {
      await docRef.delete();
    } else {
      await docRef.set({
        'id': widget.store['id'],
        'name': widget.store['name'],
        'logoUrl': widget.store['logoUrl'] ?? '',
        'rating': widget.store['rating'] ?? 0,
        'ownerId': widget.store['ownerId'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    setState(() {
      isFavoritedStore = !isFavoritedStore;
      favLoading = false;
    });
  }

  void _handleSearch(String value) => setState(() => searchQuery = value);

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Bagian utama
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final isSelfStore = _currentUser?.uid == (store['ownerId'] ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOGO, BACK, dan tombol Chat/Favorite
            Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 210,
                  child: (store['logoUrl'] != null && store['logoUrl'].toString().isNotEmpty)
                    ? Image.network(
                        store['logoUrl'],
                        width: MediaQuery.of(context).size.width,
                        height: 210,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (ctx, _, __) => Container(
                          color: Color(0xFFF5F5F5),
                          child: const Icon(Icons.store, size: 100, color: colorPrimary),
                        ),
                      )
                    : Container(
                        color: Color(0xFFF5F5F5),
                        child: const Icon(Icons.store, size: 100, color: colorPrimary),
                      ),
                ),
                // Tombol back
                Positioned(
                  top: 18,
                  left: 18,
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
              ],
            ),
            const SizedBox(height: 10),

            // Info Toko
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 16, top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama toko dan info rating (kiri)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['name'] ?? '',
                          style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        if (store['distance'] != null && store['duration'] != null)
                          Text(
                            "${store['distance']} • ${store['duration']}",
                            style: GoogleFonts.dmSans(fontSize: 13.5, color: colorPlaceholder),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 17),
                            const SizedBox(width: 2),
                            Text(
                              (store['rating'] != null)
                                  ? "${formatRating((store['rating'] as num))} "
                                  : "- ",
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              "(${store['ratingCount'] ?? '0'} Ratings)",
                              style: GoogleFonts.dmSans(
                                color: Colors.orange[700],
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tombol chat & fav (kanan)
                  Row(
                    children: [
                      if (!isSelfStore)
                        _circleIcon(
                          icon: Icons.chat_bubble_outline,
                          onTap: () => _goToChatDetail(context, store),
                        ),
                      if (!isSelfStore) const SizedBox(width: 10),
                      _circleIcon(
                        icon: isFavoritedStore ? Icons.favorite : Icons.favorite_border,
                        iconColor: isFavoritedStore ? Colors.red : colorPrimary,
                        onTap: favLoading ? null : _toggleFavoriteStore,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: custom_widgets.SearchBar(
                controller: _searchController,
                onChanged: _handleSearch,
              ),
            ),
            const SizedBox(height: 14),

            // Tab Bar
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

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _FirestoreProductList(
                    shopId: store['id'],
                    selectedCategory: selectedCategory,
                    onCategorySelected: (i) => setState(() => selectedCategory = i),
                    searchQuery: searchQuery,
                  ),
                  StoreRatingReview(
                    storeId: store['id'] ?? '',
                    storeName: store['name'] ?? '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget circle icon (chat/fav)
  Widget _circleIcon({
    required IconData icon,
    required VoidCallback? onTap,
    Color? iconColor,
    double size = 44,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? colorPrimary, size: 22),
      ),
    );
  }

  // Navigasi ke halaman chat detail (buat chat jika belum ada, pastikan tidak self-chat)
  Future<void> _goToChatDetail(BuildContext context, Map<String, dynamic> store) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anda belum login!")));
      return;
    }
    // Cek self chat (user adalah owner toko)
    if (user.uid == (store['ownerId'] ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak bisa chat ke toko sendiri!")));
      return;
    }

    // Cari apakah chat sudah ada
    final chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('buyerId', isEqualTo: user.uid)
        .where('shopId', isEqualTo: store['id'])
        .limit(1)
        .get();

    String chatId;
    if (chatQuery.docs.isNotEmpty) {
      // Sudah ada chat
      chatId = chatQuery.docs.first.id;
    } else {
      // Buat chat baru (chat dibuat setelah kirim pesan pertama, namun di sini boleh dibuat dummy entry)
      final newChat = await FirebaseFirestore.instance.collection('chats').add({
        'buyerId': user.uid,
        'buyerName': user.displayName ?? '',
        'shopId': store['id'],
        'shopName': store['name'],
        'shopAvatar': store['logoUrl'] ?? '',
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
      chatId = newChat.id;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          chatId: chatId,
          shopId: store['id'],
          shopName: store['name'],
        ),
      ),
    );
  }
}

class _StoreTabBar extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  const _StoreTabBar({required this.tabIndex, required this.onTabChanged});

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

// ---------- Product List Realtime (Firestore) ----------
class _FirestoreProductList extends StatelessWidget {
  final String shopId;
  final int selectedCategory;
  final ValueChanged<int> onCategorySelected;
  final String searchQuery;
  const _FirestoreProductList({
    required this.shopId,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CategorySelector global
        Padding(
          padding: const EdgeInsets.only(top: 14, left: 4, bottom: 8, right: 0),
          child: CategorySelector(
            categories: categoryList,
            selectedIndex: selectedCategory,
            onSelected: onCategorySelected,
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('shopId', isEqualTo: shopId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text("Gagal memuat data produk"));
              }
              
              // --- Filter Category & Search
              List<DocumentSnapshot> docs = snapshot.data!.docs;
              if (selectedCategory > 0) {
                final catStr = categoryLabels[categoryList[selectedCategory - 1]]!;
                docs = docs.where((doc) {
                  final c = doc['category'] ?? '';
                  return c.toString().toLowerCase().contains(catStr.toLowerCase());
                }).toList();
              }
              if (searchQuery.isNotEmpty) {
                docs = docs.where((doc) =>
                    doc['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())
                ).toList();
              }

              // --- Jika tidak ada produk setelah filter, tampilkan pesan UX
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.packageSearch, size: 85, color: Colors.grey[300]),
                      const SizedBox(height: 18),
                      Text(
                        "Produk tidak ditemukan",
                        style: GoogleFonts.dmSans(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Coba pilih kategori lain,\natau cari dengan kata kunci berbeda.",
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

              // --- Jika ada produk, tampilkan Grid
              return Padding(
                padding: const EdgeInsets.only(left: 6, right: 6, top: 0),
                child: GridView.builder(
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final product = docs[index].data() as Map<String, dynamic>;
                    product['id'] = docs[index].id;
                    return StoreProductCard(
                      name: product["name"] ?? "",
                      price: "Rp ${product["price"].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                      imagePath: product['imageUrl'] ?? '',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: {...product}),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
