import 'package:flutter/material.dart';
import 'package:abc_e_mart/seller/widgets/seller_app_bar.dart';
import 'package:abc_e_mart/seller/widgets/seller_profile_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_quick_access.dart';
import 'package:abc_e_mart/seller/widgets/seller_summary_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_transaction_section.dart';
import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';
import 'package:abc_e_mart/seller/features/products/products_page.dart';
import 'package:abc_e_mart/seller/features/profile/edit_profile_page.dart';
import 'package:abc_e_mart/seller/features/rating/store_rating_page.dart';

class HomePageSeller extends StatelessWidget {
  const HomePageSeller({super.key});
  final String logoPath = "assets/images/nihonmart.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Scrollable seluruh halaman
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 31),
                SellerAppBar(
                  onBack: () {
                    // Handle back if needed
                  },
                  onNotif: () {
                    // Handle notif
                  },
                ),
                const SizedBox(height: 23), // Jarak ke bawah biar sesuai desain
                SellerProfileCard(
                  storeName: "Nihon Mart",
                  description: "Menjual segala kebutuhan mahasiswa",
                  address: "Jl. Ika Hiu No 24, Surabaya",
                  logoPath: "assets/images/nihonmart.png",
                  onEditProfile: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditProfilePageSeller(logoPath: logoPath),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 23),
                SellerQuickAccess(
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProductsPage()),
                        );
                        break;
                      // case 1:
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (_) => const SellerOrdersPage()),
                      //   );
                      //   break;
                      // case 2:
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (_) => const SellerChatPage()),
                      //   );
                      //   break;
                      case 3:
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StoreRatingPage()),
                        );
                        break;
                      case 4:
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (_) => const SellerTransactionPage()),
                      //   );
                      //   break;
                      // case 5:
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (_) => const SellerAdsPage()),
                      //   );
                      //   break;
                    }
                  },
                ),
                SellerSummaryCard(
                  pesananMasuk: 42,
                  pesananDikirim: 5,
                  pesananSelesai: 30,
                  pesananBatal: 15,
                  saldo: "Rp 1,25 Jt",
                  saldoTertahan: "Rp 250.000",
                ),
                // Tambahkan widget berikutnya di sini (section lain, dsb)
                const SizedBox(height: 23),
                SellerTransactionSection(
                  transactions: [
                    SellerTransactionCardData(
                      invoiceId: "NPN001",
                      date: "5 Juli 2025",
                      status: "Sukses",
                      items: [
                        TransactionCardItem(
                          name: "Ayam Geprek",
                          note: "Pedas",
                          qty: 1,
                        ),
                        TransactionCardItem(
                          name: "Ayam Geprek",
                          note: "Sedang",
                          qty: 1,
                        ),
                        TransactionCardItem(
                          name: "Ayam Geprek",
                          note: "",
                          qty: 1,
                        ),
                      ],
                      total: 75000,
                      onDetail: () {},
                    ),
                    SellerTransactionCardData(
                      invoiceId: "#014456",
                      date: "5 Juli 2025",
                      status: "Gagal",
                      items: [
                        TransactionCardItem(
                          name: "Ayam Geprek",
                          note: "Sedang",
                          qty: 1,
                        ),
                        TransactionCardItem(
                          name: "Ayam Geprek",
                          note: "Pedas",
                          qty: 1,
                        ),
                      ],
                      total: 75000,
                      onDetail: () {},
                    ),
                  ],
                  onSeeAll: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
