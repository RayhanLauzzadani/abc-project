import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/admin/widgets/admin_home_header.dart';
import 'package:abc_e_mart/admin/widgets/admin_summary_card.dart';
import 'package:abc_e_mart/admin/widgets/admin_store_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_product_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_bottom_navbar.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_page.dart';
import 'package:abc_e_mart/admin/features/approval/product/admin_product_approval_page.dart';
import 'package:abc_e_mart/admin/widgets/admin_ad_submission_section.dart';
import 'package:abc_e_mart/admin/features/approval/ad/admin_ad_approval_page.dart';
import 'package:abc_e_mart/buyer/features/auth/login_page.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _currentIndex = 0;

  // Fungsi logout: signOut dari Firebase Auth lalu arahkan ke LoginPage
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainBody;

    // Tabs lain: pakai page full (app bar sudah di page terkait)
    if (_currentIndex == 1) {
      mainBody = const AdminStoreApprovalPage();
    } else if (_currentIndex == 2) {
      mainBody = const AdminProductApprovalPage();
    } else if (_currentIndex == 3) {
      mainBody = const AdminAdApprovalPage();
    } else {
      // Dashboard utama: App Bar sticky di atas
      mainBody = Column(
        children: [
          // ====== APP BAR ADMIN TANPA SHADOW (sticky) ======
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 0),
            // Tidak ada boxShadow di sini!
            child: AdminHomeHeader(
              onNotif: () {},
              onLogoutTap: _logout,
            ),
          ),
          const SizedBox(height: 15), // Jarak 15px ke bawah
          // ====== SCROLLABLE CONTENT ======
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0), // padding di section masing2
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminSummaryCard(
                      tokoBaru: 42,
                      tokoTerdaftar: 187,
                      produkBaru: 5,
                      iklanBaru: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminStoreSubmissionSection(
                      submissions: [
                        AdminStoreSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          storeName: 'Nippon Mart',
                          storeAddress: 'Jl. Ikan Hiu 24, Surabaya',
                          submitter: 'Rayhan Kautsar',
                          date: '30/04/2025, 4:21 PM',
                        ),
                        AdminStoreSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          storeName: 'Nippon Mart',
                          storeAddress: 'Jl. Ikan Hiu 24, Surabaya',
                          submitter: 'Rayhan Kautsar',
                          date: '30/04/2025, 4:21 PM',
                        ),
                      ],
                      onSeeAll: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      onDetail: (submission) {},
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminProductSubmissionSection(
                      submissions: [
                        AdminProductSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          productName: 'Ayam Betutu',
                          category: 'Makanan',
                          categoryType: CategoryType.makanan,
                          storeName: 'Nippon Mart',
                          date: '30/04/2025, 4:21 PM',
                        ),
                        AdminProductSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          productName: 'Ayam Betutu',
                          category: 'Minuman',
                          categoryType: CategoryType.minuman,
                          storeName: 'Nippon Mart',
                          date: '30/04/2025, 4:21 PM',
                        ),
                        AdminProductSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          productName: 'Ayam Betutu',
                          category: 'Snacks',
                          categoryType: CategoryType.snacks,
                          storeName: 'Nippon Mart',
                          date: '30/04/2025, 4:21 PM',
                        ),
                        AdminProductSubmissionData(
                          imagePath: 'assets/images/nihonmart.png',
                          productName: 'Ayam Betutu',
                          category: 'Merchandise',
                          categoryType: CategoryType.merchandise,
                          storeName: 'Nippon Mart',
                          date: '30/04/2025, 4:21 PM',
                        ),
                      ],
                      onSeeAll: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                      onDetail: (submission) {},
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdminAdSubmissionSection(
                      submissions: [
                        AdminAdSubmissionData(
                          title: 'Iklan : Ayam Geprek',
                          detailPeriod: '3 Hari • 21 Juli – 23 Juli 2025',
                          date: '30/06/2024, 4:15 PM',
                        ),
                        AdminAdSubmissionData(
                          title: 'Iklan : Ayam Geprek',
                          detailPeriod: '3 Hari • 21 Juli – 23 Juli 2025',
                          date: '30/06/2024, 4:15 PM',
                        ),
                      ],
                      onSeeAll: () {
                        setState(() {
                          _currentIndex = 3;
                        });
                      },
                      onDetail: (submission) {},
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: mainBody),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
