import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/banner/promo_banner_carousel.dart';
import 'package:abc_e_mart/buyer/features/home/widgets/category_section.dart';
import '../../widgets/bottom_navbar.dart'; // import

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of page widgets (nanti ganti sesuai kebutuhanmu)
  final List<Widget> _pages = [
    _HomeMainContent(), // Halaman beranda utama
    Center(child: Text("Katalog")), // Placeholder
    Center(child: Text("Keranjang")),
    Center(child: Text("Obrolan")),
    Center(child: Text("Profil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

// Ini isi utama HomePage (biar rapi, bisa di file terpisah juga)
class _HomeMainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header, Search, Banner: padding 20px
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 31, bottom: 8),
                child: Row(
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
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: const Color(0xFF212121),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Icon Heart
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
                        onPressed: () {},
                        splashRadius: 24,
                      ),
                    ),
                    // Icon Bell
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2056D3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        iconSize: 22,
                        onPressed: () {},
                        splashRadius: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 31),
              custom.SearchBar(),
              const SizedBox(height: 24),
              PromoBannerCarousel(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: CategorySection(),
        ),
      ],
    );
  }
}
