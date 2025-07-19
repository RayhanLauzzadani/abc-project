import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/banner/promo_banner_carousel.dart';
import 'package:abc_e_mart/buyer/features/home/widgets/category_section.dart';
import '../../widgets/bottom_navbar.dart';
import 'package:abc_e_mart/buyer/features/store/store_card.dart';
import 'package:abc_e_mart/buyer/features/product/product_card.dart';
import 'package:abc_e_mart/buyer/features/store/store_detail_page.dart';
import 'package:abc_e_mart/buyer/features/favorite/favorite_page.dart';
import 'package:abc_e_mart/buyer/features/notification/notification_page.dart';
import '../profile/profile_page.dart';
import 'package:abc_e_mart/buyer/features/cart/cart_page.dart';
import 'package:abc_e_mart/buyer/features/catalog/catalog_page.dart';
import 'package:abc_e_mart/buyer/features/product/product_detail_page.dart';
import 'package:abc_e_mart/buyer/features/chat/chat_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/buyer/features/profile/address_list_page.dart';
import 'package:abc_e_mart/buyer/data/services/address_service.dart';
import 'package:abc_e_mart/buyer/data/models/address.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isOnline': true,
      }, SetOptions(merge: true));
    }
    _selectedIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isOnline': false,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    super.dispose();
  }

  List<Widget> get _pages => [
    _HomeMainContent(
      onCategorySelected: (int categoryIdx) {
        setState(() {
          selectedCategory = categoryIdx;
          _selectedIndex = 1;
        });
      },
    ),
    CatalogPage(selectedCategory: selectedCategory),
    const CartPage(),
    const ChatListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}

class _HomeMainContent extends StatelessWidget {
  final Function(int selectedCategory) onCategorySelected;
  const _HomeMainContent({Key? key, required this.onCategorySelected})
    : super(key: key);

  static const double headerHeight = 110;
  static const double spaceBawah = 0;
  static const double searchBarHeight = 48;
  static const double totalStickyHeight =
      headerHeight + spaceBawah + searchBarHeight;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';

    return CustomScrollView(
      slivers: [
        // Sticky: Header + SearchBar
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderWithSearchBarDelegate(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 31,
                bottom: spaceBawah,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeAddressHeader(),
                  const SizedBox(height: 20),
                  const SizedBox(
                    height: searchBarHeight,
                    child: custom.SearchBar(),
                  ),
                ],
              ),
            ),
            height: totalStickyHeight,
          ),
        ),
        // Banner Promo
        SliverToBoxAdapter(child: const SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PromoBannerCarousel(
              onBannerTap: (bannerData) async {
                if ((bannerData['isAsset'] ?? true) == false &&
                    bannerData['productId'] != null &&
                    bannerData['productId'].toString().isNotEmpty) {
                  // --- Ambil detail produk real-time dari Firestore agar tidak error ---
                  final doc = await FirebaseFirestore.instance
                      .collection('products')
                      .doc(bannerData['productId'])
                      .get();
                  if (doc.exists) {
                    final productData = doc.data() ?? {};
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(
                          product: {...productData, 'id': doc.id},
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Produk tidak ditemukan atau sudah dihapus.'),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        // Kategori Section: pass callback
        SliverToBoxAdapter(
          child: CategorySection(onCategorySelected: onCategorySelected),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 32)),
        // Toko
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Toko yang Tersedia",
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF212121),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('stores')
                  .limit(5)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Belum ada toko tersedia.')),
                  );
                }
                final stores = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['ownerId'] != userUid;
                }).toList();
                if (stores.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Belum ada toko tersedia.')),
                  );
                }
                return Column(
                  children: stores.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return StoreCard(
                      imageUrl: data['logoUrl'] ?? '',
                      storeName: data['name'] ?? '',
                      rating: (data['rating'] ?? 0).toDouble(),
                      ratingCount: (data['ratingCount'] ?? 0).toInt(),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StoreDetailPage(store: {...data, 'id': doc.id}),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 32)),
        // Produk
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Produk untuk Anda",
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF212121),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('products')
                  .limit(5)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Belum ada produk tersedia.')),
                  );
                }
                final products = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['ownerId'] != userUid;
                }).toList();
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Belum ada produk tersedia.')),
                  );
                }
                return Column(
                  children: products.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ProductCard(
                      imageUrl: data['imageUrl'] ?? '',
                      name: data['name'] ?? '',
                      price: (data['price'] ?? 0),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              product: {...data, 'id': doc.id},
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
      ],
    );
  }
}

class _HomeAddressHeader extends StatelessWidget {
  const _HomeAddressHeader();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: user == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alamat Anda",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF9B9B9B),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Belum login",
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : StreamBuilder<AddressModel?>(
                  stream: AddressService().getPrimaryAddress(user.uid),
                  builder: (context, snapshot) {
                    final address = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alamat Anda",
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF9B9B9B),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressListPage(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  address != null
                                      ? (address.label.isNotEmpty
                                            ? address.label
                                            : "Alamat Utama")
                                      : "Belum ada alamat",
                                  style: GoogleFonts.dmSans(
                                    color: const Color(0xFF212121),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF212121),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFFF455B),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            iconSize: 22,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FavoritePage()));
            },
            splashRadius: 24,
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF2056D3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            iconSize: 22,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
            splashRadius: 24,
          ),
        ),
      ],
    );
  }
}

class _StickyHeaderWithSearchBarDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _StickyHeaderWithSearchBarDelegate({
    required this.child,
    required this.height,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderWithSearchBarDelegate oldDelegate) => false;
}
