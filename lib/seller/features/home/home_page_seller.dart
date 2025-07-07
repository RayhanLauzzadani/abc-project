import 'package:flutter/material.dart';
import 'package:abc_e_mart/seller/widgets/seller_app_bar.dart';
import 'package:abc_e_mart/seller/widgets/seller_profile_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_quick_access.dart';
import 'package:abc_e_mart/seller/widgets/seller_summary_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_transaction_section.dart';
import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';

class HomePageSeller extends StatelessWidget {
  const HomePageSeller({super.key});

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
                ),
                const SizedBox(height: 23),
                SellerQuickAccess(
                  onTap: (index) {
                    // Handle click index (0-5)
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
