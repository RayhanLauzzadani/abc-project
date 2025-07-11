import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_tab_mine.dart';
import 'cart_tab_inprogress.dart';
import 'cart_tab_history.dart';
import '../../widgets/bottom_navbar.dart';
import 'package:abc_e_mart/buyer/features/home/home_page_buyer.dart';
import 'package:abc_e_mart/buyer/features/profile/profile_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late TabController _tabController;
  Map<String, bool> storeChecked = {};

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

  void onStoreCheckedChanged(String storeId, bool checked) {
    setState(() {
      storeChecked[storeId] = checked;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text(
                "Keranjang Anda",
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AnimatedCartTabBar(
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CartTabMine(
                    storeChecked: storeChecked,
                    onStoreCheckedChanged: onStoreCheckedChanged,
                  ),
                  CartTabInProgress(),
                  CartTabHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) {
                  if (index == 0) return const HomePage();
                  if (index == 1) return const HomePage();
                  if (index == 3) return const HomePage();
                  if (index == 4) return const ProfilePage();
                  return const HomePage();
                },
              ),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

// Custom Tab Bar
class _AnimatedCartTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _AnimatedCartTabBar({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      "Keranjang Saya",
      "Dalam Proses",
      "Riwayat",
    ];

    final textStyles = List.generate(
      tabs.length,
      (_) => GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 15),
    );

    final tabSpacing = 18.0;

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

        // Offset supaya sejajar
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
                          fontSize: 15,
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
