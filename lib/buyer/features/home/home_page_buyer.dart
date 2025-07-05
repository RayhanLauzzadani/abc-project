import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/banner/promo_banner_carousel.dart'; // Cukup carousel saja

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Icon Row
              Padding(
                padding: const EdgeInsets.only(top: 31, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alamat
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Alamat Anda",
                            style: GoogleFonts.dmSans(
                              color: Color(0xFF9B9B9B),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Jakarta, Indonesia",
                                style: GoogleFonts.dmSans(
                                  color: Color(0xFF212121),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF212121),
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
      ),
    );
  }
}
