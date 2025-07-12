import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';
import 'package:abc_e_mart/admin/features/approval/store/widgets/admin_store_approval_card.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_detail_page.dart'; // <-- Import detail page

class AdminStoreApprovalPage extends StatelessWidget {
  const AdminStoreApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // No native AppBar, pakai custom text di body saja
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Appbar" Custom Title
              const SizedBox(height: 31),
              Text(
                'Persetujuan Toko',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 23),
              // Search Bar (from widgets/admin_search_bar.dart)
              const AdminSearchBar(),
              const SizedBox(height: 16),
              // Card list scrollable
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: 6,
                  separatorBuilder: (context, index) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    return AdminStoreApprovalCard(
                      data: AdminStoreApprovalData(
                        imagePath: 'assets/images/nihonmart.png',
                        storeName: 'Nippon Mart',
                        storeAddress: 'Jl. Ikan Hiu 24, Surabaya',
                        submitter: 'Rayhan Kautsar',
                        date: '30/04/2025, 4:21 PM',
                      ),
                      onDetail: () {
                        // **Navigasi ke halaman detail**
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminStoreApprovalDetailPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
