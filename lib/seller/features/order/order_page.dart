import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'order_tab_incoming.dart';
import 'order_tab_delivered.dart';
import 'order_tab_history.dart';

class SellerOrderPage extends StatefulWidget {
  const SellerOrderPage({super.key});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  const SizedBox(width: 15),
                  Text(
                    "Pesanan",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AnimatedSellerOrderTabBar(
                selectedIndex: selectedIndex,
                onTabChanged: (idx) {
                  setState(() {
                    selectedIndex = idx;
                    _tabController.animateTo(idx);
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  SellerOrderTabIncoming(),
                  SellerOrderTabDelivered(),
                  SellerOrderTabHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Tab Bar Seller
class _AnimatedSellerOrderTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _AnimatedSellerOrderTabBar({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      "Pesanan Masuk",
      "Pesanan Dikirim",
      "Riwayat",
    ];

    final textStyles = List.generate(
      tabs.length,
      (_) => GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
    );

    final tabSpacing = 14.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainters = List.generate(tabs.length, (i) {
          final tp = TextPainter(
            text: TextSpan(text: tabs[i], style: textStyles[i]),
            textDirection: TextDirection.ltr,
          )..layout();
          return tp;
        });

        final tabLefts = <double>[];
        double left = 0;
        for (int i = 0; i < tabs.length; i++) {
          tabLefts.add(left);
          left += textPainters[i].width + tabSpacing;
        }

        double underlineLeft;
        if (selectedIndex == 0) {
          underlineLeft = tabLefts[0];
        } else if (selectedIndex == 1) {
          underlineLeft = tabLefts[1] - 4.5;
        } else {
          underlineLeft = tabLefts[2] - 8;
        }
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
                      margin: EdgeInsets.only(right: i < tabs.length - 1 ? tabSpacing : 0),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.ease,
                        style: GoogleFonts.dmSans(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                          color: isActive
                              ? const Color(0xFF202020)
                              : const Color(0xFFB2B2B2),
                        ),
                        child: Text(tabs[i], overflow: TextOverflow.ellipsis),
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