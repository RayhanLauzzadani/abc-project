import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:abc_e_mart/seller/widgets/seller_app_bar.dart';
import 'package:abc_e_mart/seller/widgets/seller_profile_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_quick_access.dart';
import 'package:abc_e_mart/seller/widgets/seller_summary_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_transaction_section.dart';
import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';
import 'package:abc_e_mart/seller/features/products/products_page.dart';
import 'package:abc_e_mart/seller/features/profile/edit_profile_page.dart';
import 'package:abc_e_mart/seller/features/rating/store_rating_page.dart';
import 'package:abc_e_mart/seller/features/notification/notification_page_seller.dart';

class HomePageSeller extends StatelessWidget {
  const HomePageSeller({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text("User belum login"))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stores')
                    .where('ownerId', isEqualTo: uid)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Toko tidak ditemukan/Belum diapprove"),
                    );
                  }

                  // Ambil data store pertama
                  final data =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final storeId = snapshot.data!.docs.first.id;
                  final shopName = data['name'] ?? "-";
                  final description =
                      data['description'] ?? "Menjual berbagai kebutuhan";
                  final address = data['address'] ?? "-";
                  final logoUrl = data['logoUrl'] ?? "";
                  final phone = data['phone'] ?? "-";

                  // Sisa data dummy, nanti integrasi dengan Firestore juga
                  final pesananMasuk = 42;
                  final pesananDikirim = 5;
                  final pesananSelesai = 30;
                  final pesananBatal = 15;
                  final saldo = "Rp 1,25 Jt";
                  final saldoTertahan = "Rp 250.000";

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 31),
                          SellerAppBar(
                            onBack: () {
                              Navigator.pop(context);
                            },
                            onNotif: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationPageSeller(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 23),
                          SellerProfileCard(
                            storeName: shopName,
                            description: description,
                            address: address,
                            logoPath: logoUrl.isNotEmpty ? logoUrl : null,
                            onEditProfile: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditProfilePageSeller(
                                    logoPath: logoUrl,
                                    storeId: storeId,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 23),
                          SellerQuickAccess(
                            onTap: (index) {
                              switch (index) {
                                case 0: // Produk Toko
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductsPage(storeId: storeId),
                                    ),
                                  );
                                  break;
                                case 3:
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const StoreRatingPage(),
                                    ),
                                  );
                                  break;
                                // Tambahkan case lain jika ada fitur quick access lain
                              }
                            },
                          ),
                          SellerSummaryCard(
                            pesananMasuk: pesananMasuk,
                            pesananDikirim: pesananDikirim,
                            pesananSelesai: pesananSelesai,
                            pesananBatal: pesananBatal,
                            saldo: saldo,
                            saldoTertahan: saldoTertahan,
                          ),
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
                  );
                },
              ),
      ),
    );
  }
}
