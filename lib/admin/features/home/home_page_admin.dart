import 'package:flutter/material.dart';
import 'package:abc_e_mart/admin/widgets/admin_home_header.dart';
import 'package:abc_e_mart/admin/widgets/admin_summary_card.dart';
import 'package:abc_e_mart/admin/widgets/admin_store_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_product_submission_section.dart';
import 'package:abc_e_mart/admin/widgets/admin_bottom_navbar.dart';
import 'package:abc_e_mart/admin/features/approval/admin_store_approval_page.dart';
import 'package:abc_e_mart/admin/widgets/admin_ad_approval_page.dart'; // pastikan file ini ada

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget mainBody;

    if (_currentIndex == 1) {
      // "Toko" tab, langsung show halaman Persetujuan Toko
      mainBody = const AdminStoreApprovalPage();
    } else {
      // Halaman utama admin
      mainBody = SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminHomeHeader(),
            const SizedBox(height: 0),
            AdminSummaryCard(
              tokoBaru: 42,
              tokoTerdaftar: 187,
              produkBaru: 5,
              iklanBaru: 30,
            ),
            const SizedBox(height: 20),
            AdminStoreSubmissionSection(
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
              onDetail: (submission) {
                // Implementasi ke detail submission kalau perlu
              },
            ),
            const SizedBox(height: 20),
            AdminProductSubmissionSection(
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
              onSeeAll: () {},
              onDetail: (submission) {},
            ),
            const SizedBox(height: 20),
            // Pastikan widget Section Iklan sudah ada di widgets!
            AdminAdSubmissionSection(
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
              onSeeAll: () {},
              onDetail: (submission) {},
            ),
            const SizedBox(height: 30),
          ],
        ),
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
