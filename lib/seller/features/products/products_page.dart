import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'products_tab_mine.dart';
import 'products_tab_status.dart';
import 'package:abc_e_mart/seller/features/products/add_product/add_products.dart';
import 'package:abc_e_mart/seller/features/home/home_page_seller.dart';

class ProductsPage extends StatefulWidget {
  final String storeId;
  final int initialTab;
  final bool fromSubmission; // <--- penting!

  const ProductsPage({
    Key? key,
    required this.storeId,
    this.initialTab = 0,
    this.fromSubmission = false,
  }) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab;
    _tabController = TabController(length: 2, vsync: this, initialIndex: selectedIndex);
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
    // Wrap seluruh Scaffold dengan WillPopScope
    return WillPopScope(
      onWillPop: () async {
        if (widget.fromSubmission) {
          Navigator.of(context).pop(); // cukup pop
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Back, Title, Tambah Produk (button kecil)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.fromSubmission) {
                          Navigator.of(context).pop(); // cukup pop saja
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2056D3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Produk Toko',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2056D3),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddProductPage()),
                          );
                          if (result == true) {
                            setState(() {});
                          }
                        },
                        child: Text(
                          '+ Tambah Produk',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AnimatedTabBar(
                  selectedIndex: selectedIndex,
                  onTabChanged: (idx) {
                    setState(() {
                      selectedIndex = idx;
                      _tabController.animateTo(idx);
                    });
                  },
                  tabs: const [
                    "Produk Saya",
                    "Menunggu Persetujuan",
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ProductsTabMine(storeId: widget.storeId),
                    ProductsTabStatus(storeId: widget.storeId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// (AnimatedTabBar tetap sama, tidak perlu diubah)
class _AnimatedTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> tabs;

  const _AnimatedTabBar({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = List.generate(
      tabs.length,
      (i) => GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );

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
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 2,
                  color: const Color(0x11B2B2B2),
                ),
              ),
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
