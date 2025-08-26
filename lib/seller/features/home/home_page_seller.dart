import 'package:abc_e_mart/seller/features/ads/ads_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/seller/widgets/seller_app_bar.dart';
import 'package:abc_e_mart/seller/widgets/seller_profile_card.dart';
import 'package:abc_e_mart/widgets/abc_payment_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_quick_access.dart';
import 'package:abc_e_mart/seller/widgets/seller_summary_card.dart';
import 'package:abc_e_mart/seller/widgets/seller_transaction_section.dart';
import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';
import 'package:abc_e_mart/seller/features/products/products_page.dart';
import 'package:abc_e_mart/seller/features/profile/edit_profile_page.dart';
import 'package:abc_e_mart/seller/features/rating/store_rating_page.dart';
import 'package:abc_e_mart/seller/features/notification/notification_page_seller.dart';
import 'package:abc_e_mart/seller/features/chat/chat_list_page.dart';
import 'package:abc_e_mart/seller/features/order/order_page.dart';
import 'package:abc_e_mart/seller/features/transaction/transaction_page.dart';
import 'package:abc_e_mart/seller/features/wallet/withdraw_payment_page.dart';
import 'package:abc_e_mart/seller/features/wallet/withdraw_history_page.dart';

class HomePageSeller extends StatefulWidget {
  const HomePageSeller({super.key});

  @override
  State<HomePageSeller> createState() => _HomePageSellerState();
}

class _HomePageSellerState extends State<HomePageSeller> {
  String? _storeId;

  Future<void> _setOnlineStatus(
    bool isOnline, {
    bool updateLastLogin = false,
  }) async {
    if (_storeId != null) {
      final updateData = <String, dynamic>{'isOnline': isOnline};
      if (updateLastLogin) {
        updateData['lastLogin'] = FieldValue.serverTimestamp();
      }
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(_storeId)
          .set(updateData, SetOptions(merge: true));
    }
  }

  @override
  void dispose() {
    // Update store: set offline & lastLogin
    _setOnlineStatus(false, updateLastLogin: true);

    // Update user: set isOnline true (balik ke buyer)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isOnline': true,
      }, SetOptions(merge: true));
    }

    super.dispose();
  }

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
                  final doc = snapshot.data!.docs.first;
                  final data = doc.data() as Map<String, dynamic>;
                  final storeId = doc.id;

                  // Simpan storeId agar bisa update status di dispose
                  if (_storeId != storeId) {
                    _storeId = storeId;
                    // Saat masuk halaman seller: set isOnline=true
                    _setOnlineStatus(true);
                  }

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
                          const SizedBox(height: 16),

                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(
                                  uid,
                                ) // uid seller yang login (sudah dideklarasikan di atas)
                                .snapshots(),
                            builder: (context, snap) {
                              int available = 0; // default saat loading/null

                              if (snap.hasData) {
                                final data = snap.data!.data();
                                final wallet =
                                    (data?['wallet']
                                        as Map<String, dynamic>?) ??
                                    {};
                                if (wallet['available'] is num) {
                                  available = (wallet['available'] as num)
                                      .toInt();
                                }
                              }

                              return ABCPaymentCard(
                                margin: EdgeInsets.zero,
                                balance: available, // saldo live dari Firestore
                                primaryLabel: 'Tarik Saldo',
                                primaryIconWidget: SvgPicture.asset(
                                  'assets/icons/banknote-arrow-down.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onPrimary: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => WithdrawPaymentPage(
                                        currentBalance:
                                            available, // kirim saldo real
                                        adminFee: 1000,
                                        minWithdraw: 15000,
                                      ),
                                    ),
                                  );
                                },
                                onHistory: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const WithdrawHistoryPageSeller(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),

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
                                case 1: // Pesanan
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SellerOrderPage(),
                                    ),
                                  );
                                  break;
                                case 2: // Obrolan/Chat
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SellerChatListPage(),
                                    ),
                                  );
                                  break;
                                case 3:
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => StoreRatingPage(
                                        storeId: storeId,
                                        storeName: shopName,
                                      ),
                                    ),
                                  );
                                  break;
                                case 4:
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TransactionPage(),
                                    ),
                                  );
                                  break;
                                case 5:
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AdsListPage(
                                        // Kirim storeId atau sellerId sesuai page mu
                                        sellerId: uid,
                                      ),
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
                            onSeeAll: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TransactionPage(),
                                ),
                              );
                            },
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
