import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../product/favorite_product_page.dart';
import '../store/favorite_store_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            // Header Favorit
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Favorit",
                    style: GoogleFonts.dmSans(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 21), // Tambah jarak dari header ke tab bar
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 30),
              child: _AnimatedTabBar(
                selectedIndex: selectedIndex,
                onTabChanged: (idx) {
                  setState(() {
                    selectedIndex = idx;
                    _tabController.animateTo(idx);
                  });
                },
              ),
            ),
            const SizedBox(height: 6), // Tambah jarak agar tab & underline lebih proporsional
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  FavoriteProductPage(),
                  FavoriteStorePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Animated Tab Bar
class _AnimatedTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  const _AnimatedTabBar({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      "Produk Favorit",
      "Toko Favorit",
    ];

    final textStyles = [
      GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
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
        final underlineLeft = selectedIndex == 0
            ? tabLefts[0]
            : tabLefts[1] - 3.0;

        final underlineWidth = textPainters[selectedIndex].width;

        return SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // Garis abu-abu transparan
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 2,
                  color: const Color(0x11B2B2B2),
                ),
              ),
              // Tab text row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(tabs.length, (i) {
                  final isActive = selectedIndex == i;
                  return GestureDetector(
                    onTap: isActive ? null : () => onTabChanged(i),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: i == 0 ? tabSpacing : 0,
                      ),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.ease,
                        style: GoogleFonts.dmSans(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 15,
                          color: isActive
                              ? const Color(0xFF202020)
                              : const Color(0xFFB2B2B2),
                        ),
                        child: Text(tabs[i]),
                      ),
                    ),
                  );
                }),
              ),
              // Underline kuning animasi tepat di bawah text
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.ease,
                left: underlineLeft,
                bottom: 0,
                child: Container(
                  width: underlineWidth,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 0),
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
