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
// detail invoice
import 'package:abc_e_mart/seller/features/transaction/transaction_detail_page.dart';

class HomePageSeller extends StatefulWidget {
  const HomePageSeller({super.key});

  @override
  State<HomePageSeller> createState() => _HomePageSellerState();
}

class _HomePageSellerState extends State<HomePageSeller> {
  String? _storeId;
  Map<String, dynamic>? _storeData; // ⬅️ simpan data toko agar bisa dipakai di transaksi

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
    _setOnlineStatus(false, updateLastLogin: true);

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

                  final doc = snapshot.data!.docs.first;
                  final data = doc.data() as Map<String, dynamic>;
                  final storeId = doc.id;

                  // simpan data toko untuk dipakai di detail transaksi
                  _storeData = {
                    'name': data['name'] ?? '-',
                    'address': data['address'] ?? '-',
                    'phone': data['phone'] ?? '-',
                  };

                  if (_storeId != storeId) {
                    _storeId = storeId;
                    _setOnlineStatus(true);
                  }

                  final shopName = data['name'] ?? "-";
                  final description = data['description'] ?? "Menjual berbagai kebutuhan";
                  final address = data['address'] ?? "-";
                  final logoUrl = data['logoUrl'] ?? "";
                  final phone = data['phone'] ?? "-";

                  // dummy summary
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
                            onBack: () => Navigator.pop(context),
                            onNotif: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationPageSeller(),
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

                          // Saldo
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .snapshots(),
                            builder: (context, snap) {
                              int available = 0;
                              if (snap.hasData) {
                                final u = snap.data!.data();
                                final wallet = (u?['wallet'] as Map<String, dynamic>?) ?? {};
                                if (wallet['available'] is num) {
                                  available = (wallet['available'] as num).toInt();
                                }
                              }

                              return ABCPaymentCard(
                                margin: EdgeInsets.zero,
                                balance: available,
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
                                        currentBalance: available,
                                        adminFee: 1000,
                                        minWithdraw: 15000,
                                      ),
                                    ),
                                  );
                                },
                                onHistory: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const WithdrawHistoryPageSeller(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Quick Access
                          SellerQuickAccess(
                            onTap: (index) {
                              switch (index) {
                                case 0:
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => ProductsPage(storeId: storeId),
                                  ));
                                  break;
                                case 1:
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const SellerOrderPage(),
                                  ));
                                  break;
                                case 2:
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const SellerChatListPage(),
                                  ));
                                  break;
                                case 3:
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => StoreRatingPage(
                                      storeId: storeId,
                                      storeName: shopName,
                                    ),
                                  ));
                                  break;
                                case 4:
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const TransactionPage(),
                                  ));
                                  break;
                                case 5:
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdsListPage(
                                      sellerId: uid,
                                    ),
                                  ));
                                  break;
                              }
                            },
                          ),

                          // Summary
                          SellerSummaryCard(
                            pesananMasuk: pesananMasuk,
                            pesananDikirim: pesananDikirim,
                            pesananSelesai: pesananSelesai,
                            pesananBatal: pesananBatal,
                            saldo: saldo,
                            saldoTertahan: saldoTertahan,
                          ),

                          // Transaction Section
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('orders')
                                .where('sellerId', isEqualTo: uid)
                                .where('status', whereIn: [
                                  'COMPLETED', 'SUCCESS', 'SETTLED', 'DELIVERED',
                                  'CANCELLED', 'CANCELED', 'REJECTED', 'FAILED',
                                ])
                                .orderBy('updatedAt', descending: true)
                                .limit(5)
                                .snapshots(),
                            builder: (context, txSnap) {
                              if (txSnap.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final docs = txSnap.data?.docs ?? [];
                              if (docs.isEmpty) {
                                return SellerTransactionSection(
                                  transactions: const [],
                                  onSeeAll: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const TransactionPage()),
                                    );
                                  },
                                );
                              }

                              final cardsData = docs.map((d) {
                                final od = d.data();
                                return _mapOrderDocToCard(
                                  docId: d.id,
                                  data: od,
                                  onDetail: () => _openTransactionDetail(orderId: d.id, data: od),
                                );
                              }).toList();

                              return SellerTransactionSection(
                                transactions: cardsData,
                                onSeeAll: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const TransactionPage()),
                                  );
                                },
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

  // buka detail transaksi
  Future<void> _openTransactionDetail({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    String buyerName = (data['buyerName'] ?? '') as String? ?? '';
    if (buyerName.trim().isEmpty) {
      final buyerId = (data['buyerId'] ?? '') as String? ?? '';
      if (buyerId.isNotEmpty) {
        try {
          final snap = await FirebaseFirestore.instance.collection('users').doc(buyerId).get();
          buyerName = (snap.data()?['name'] ?? '-') as String? ?? '-';
        } catch (_) {
          buyerName = '-';
        }
      } else {
        buyerName = '-';
      }
    }

    final txMap = _mapOrderToTransaction(orderId: orderId, data: data, buyerName: buyerName);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: txMap)),
    );
  }

  SellerTransactionCardData _mapOrderDocToCard({
    required String docId,
    required Map<String, dynamic> data,
    required VoidCallback onDetail,
  }) {
    final invoice = (data['invoiceId'] as String?)?.trim();
    final displayInvoice = (invoice != null && invoice.isNotEmpty) ? invoice : docId;

    final ts = data['updatedAt'] ?? data['createdAt'];
    final dt = ts is Timestamp ? ts.toDate() : null;
    final dateStr = dt != null ? _fmtDateIndo(dt) : '-';

    final statusRaw = ((data['status'] ?? '') as String).toUpperCase();
    final statusUi = _statusToUi(statusRaw);

    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final itemCards = items.map((it) {
      return TransactionCardItem(
        name: (it['name'] ?? '-') as String,
        note: (it['variant'] ?? it['note'] ?? '') as String,
        qty: ((it['qty'] as num?) ?? 0).toInt(),
      );
    }).toList();

    final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
    final total = ((amounts['total'] as num?) ?? 0).toInt();

    return SellerTransactionCardData(
      invoiceId: displayInvoice,
      date: dateStr,
      status: statusUi,
      items: itemCards,
      total: total,
      onDetail: onDetail,
    );
  }

  Map<String, dynamic> _mapOrderToTransaction({
    required String orderId,
    required Map<String, dynamic> data,
    required String buyerName,
  }) {
    final statusRaw =
        ((data['status'] ?? data['shippingAddress']?['status'] ?? 'PLACED') as String).toUpperCase();

    String uiStatus;
    if (['COMPLETED', 'SUCCESS', 'SETTLED', 'DELIVERED'].contains(statusRaw)) {
      uiStatus = 'Sukses';
    } else if (['CANCELLED', 'CANCELED', 'REJECTED', 'FAILED'].contains(statusRaw)) {
      uiStatus = 'Gagal';
    } else {
      uiStatus = 'Tertahan';
    }

    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
    final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
    final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
    final tax = ((amounts['tax'] as num?) ?? 0).toInt();
    final total = ((amounts['total'] as num?) ?? (subtotal + shipping + tax)).toInt();

    final createdAt = (data['updatedAt'] ?? data['createdAt']);
    final date = createdAt is Timestamp ? createdAt.toDate() : null;

    final ship = (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
    final addressLabel = (ship['label'] ?? '-') as String;
    final addressText = (ship['addressText'] ?? ship['address'] ?? '-') as String;
    final phone = (ship['phone'] ?? '-') as String;

    final method = ((data['payment']?['method'] ?? 'abc_payment') as String).toUpperCase();

    final inv = (data['invoiceId'] as String?)?.trim();
    final invoiceId = (inv != null && inv.isNotEmpty) ? inv : orderId;

    return {
      'invoiceId': invoiceId,
      'status': uiStatus,
      'date': date,

      // ⬇️ Info toko ikut dikirim (supaya muncul di PDF)
      'store': {
        'name': _storeData?['name'] ?? '-',
        'phone': _storeData?['phone'] ?? '-',
        'address': _storeData?['address'] ?? '-',
      },

      'buyerName': buyerName,
      'shipping': {
        'recipient': buyerName,
        'addressLabel': addressLabel,
        'addressText': addressText,
        'phone': phone,
      },
      'paymentMethod': method,
      'items': items
          .map((it) => {
                'name': (it['name'] ?? '-') as String,
                'qty': ((it['qty'] as num?) ?? 0).toInt(),
                'price': ((it['price'] as num?) ?? 0).toInt(),
                'variant': (it['variant'] ?? it['note'] ?? '') as String,
              })
          .toList(),
      'amounts': {
        'subtotal': subtotal,
        'shipping': shipping,
        'tax': tax,
        'total': total,
      },
    };
  }

  String _statusToUi(String raw) {
    if (['COMPLETED', 'SUCCESS', 'SETTLED', 'DELIVERED'].contains(raw)) return 'Sukses';
    if (['CANCELLED', 'CANCELED', 'REJECTED', 'FAILED'].contains(raw)) return 'Gagal';
    return 'Tertahan';
  }

  String _fmtDateIndo(DateTime d) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }
}
