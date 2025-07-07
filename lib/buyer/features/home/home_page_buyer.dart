import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/banner/promo_banner_carousel.dart';
import 'package:abc_e_mart/buyer/features/home/widgets/category_section.dart';
import '../../widgets/bottom_navbar.dart';
import 'package:abc_e_mart/buyer/features/store/store_card.dart';
import 'package:abc_e_mart/buyer/features/product/product_card.dart';
import 'package:abc_e_mart/buyer/features/store/store_detail_page.dart';
import 'package:abc_e_mart/buyer/features/favorite/favorite_page.dart';
import 'package:abc_e_mart/buyer/data/dummy/dummy_data.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeMainContent(),
    const Center(child: Text("Katalog")),
    const Center(child: Text("Keranjang")),
    const Center(child: Text("Obrolan")),
    const ProfilePage(), // Ini!
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _HomeMainContent extends StatelessWidget {
  const _HomeMainContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header, Search, Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 31),
              _buildHeader(context),
              const SizedBox(height: 31),
              custom.SearchBar(),
              const SizedBox(height: 24),
              const PromoBannerCarousel(),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Kategori (tanpa padding kiri, diganti margin di dalam widget)
        const CategorySection(),
        const SizedBox(height: 32),

        // Toko
        Padding(
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
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: dummyStores.map((store) {
              return StoreCard(
                imagePath: store['image'],
                storeName: store['name'],
                distance: store['distance'],
                duration: store['duration'],
                rating: store['rating'],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoreDetailPage(store: store),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),

        // Produk
        Padding(
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
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: dummyProducts.map((product) {
              return ProductCard(
                imagePath: product['image'],
                name: product['name'],
                price: product['price'],
                rating: product['rating'].toDouble(),
                onTap: () {},
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
                    "Jakarta, Indonesia",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF212121),
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF212121)),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: Color(0xFFFF455B), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            iconSize: 22,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
            splashRadius: 24,
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: Color(0xFF2056D3), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            iconSize: 22,
            onPressed: () {},
            splashRadius: 24,
          ),
        ),
      ],
    );
  }
}