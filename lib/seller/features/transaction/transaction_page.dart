import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:abc_e_mart/seller/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/seller/widgets/status_selector.dart';

import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';
import 'package:abc_e_mart/seller/widgets/seller_transaction_card.dart';

import 'transaction_detail_page.dart';

/// Status filter UI
enum TxStatus { semua, sukses, tertahan, gagal }

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _searchC = TextEditingController();
  int _selectedIndex = 0; // 0 Semua, 1 Sukses, 2 Tertahan, 3 Gagal

  final List<String> _statusLabels = const ['Semua', 'Sukses', 'Tertahan', 'Gagal'];

  // ⬇️ meta toko (fallback untuk PDF/Detail jika dokumen order belum menyimpan info toko)
  Map<String, String> _storeMeta = const {
    'name': '-',
    'phone': '-',
    'address': '-',
  };

  @override
  void initState() {
    super.initState();
    _loadStoreMeta();
  }

  Future<void> _loadStoreMeta() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final qs = await FirebaseFirestore.instance
          .collection('stores')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();

      if (qs.docs.isNotEmpty) {
        final d = qs.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _storeMeta = {
            'name': (d['name'] ?? '-') as String,
            'phone': (d['phone'] ?? '-') as String,
            'address': (d['address'] ?? '-') as String,
          };
        });
      }
    } catch (_) {
      // biarkan default '-'
    }
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('User belum login'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Transaksi',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: const Color(0xFF373E3C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: custom_widgets.SearchBar(
                      hintText: "Cari transaksi",
                      controller: _searchC,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter status
                  StatusSelector(
                    labels: _statusLabels,
                    selectedIndex: _selectedIndex,
                    onSelected: (idx) => setState(() => _selectedIndex = idx),
                    height: 20,
                    gap: 10,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                  ),

                  const SizedBox(height: 12),

                  // List transaksi (live Firestore)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _buildQuery(uid),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = snap.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('Belum ada transaksi.'));
                        }

                        // Map -> kartu + filter text (client-side)
                        final cards = docs.map((d) {
                          final od = d.data();
                          return _mapOrderDocToCard(
                            docId: d.id,
                            data: od,
                            onDetail: () => _openTransactionDetail(orderId: d.id, data: od),
                          );
                        }).toList();

                        final q = _searchC.text.trim().toLowerCase();
                        final filtered = q.isEmpty
                            ? cards
                            : cards.where((c) {
                                final inInvoice = c.invoiceId.toLowerCase().contains(q);
                                final inItems = c.items.any((it) =>
                                    it.name.toLowerCase().contains(q) ||
                                    it.note.toLowerCase().contains(q));
                                return inInvoice || inItems;
                              }).toList();

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final data = filtered[i];
                            return SellerTransactionCard(
                              data: data,
                              onDetail: data.onDetail, // sudah berisi _openTransactionDetail
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// ================= Query & Mapping =================

  /// Bangun query Firestore sesuai filter status.
  Stream<QuerySnapshot<Map<String, dynamic>>> _buildQuery(String uid) {
    final base = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: uid);

    // Peta filter status ke nilai Firestore
    List<String>? statuses;
    switch (_selectedIndex) {
      case 1: // Sukses
        statuses = ['COMPLETED', 'SUCCESS', 'SETTLED', 'DELIVERED'];
        break;
      case 2: // Tertahan (belum final atau on-hold)
        statuses = ['PENDING', 'ON_HOLD', 'PROCESSING']; // sesuaikan bila kamu pakai status lain
        break;
      case 3: // Gagal
        statuses = ['CANCELLED', 'CANCELED', 'REJECTED', 'FAILED'];
        break;
      default:
        statuses = null; // Semua
    }

    Query<Map<String, dynamic>> q = base;
    if (statuses != null) {
      q = q.where('status', whereIn: statuses);
    }

    // Urutkan yang terbaru di atas
    q = q.orderBy('updatedAt', descending: true);

    // Bisa limit sesuai kebutuhan
    return q.snapshots();
  }

  /// Konversi dokumen order -> data kartu transaksi (ringkas)
  SellerTransactionCardData _mapOrderDocToCard({
    required String docId,
    required Map<String, dynamic> data,
    required VoidCallback onDetail,
  }) {
    // invoice untuk UI
    final invoice = (data['invoiceId'] as String?)?.trim();
    final displayInvoice = (invoice != null && invoice.isNotEmpty) ? invoice : docId;

    // tanggal
    final ts = data['updatedAt'] ?? data['createdAt'];
    final dt = ts is Timestamp ? ts.toDate() : null;
    final dateStr = dt != null ? _fmtDateIndo(dt) : '-';

    // status → label UI
    final statusRaw = ((data['status'] ?? '') as String).toUpperCase();
    final statusUi = _statusToUi(statusRaw);

    // ringkas items
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final itemCards = items.map((it) {
      return TransactionCardItem(
        name: (it['name'] ?? '-') as String,
        note: (it['variant'] ?? it['note'] ?? '') as String,
        qty: ((it['qty'] as num?) ?? 0).toInt(),
      );
    }).toList();

    // total
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

  /// Saat user menekan "Detail Transaksi"
  Future<void> _openTransactionDetail({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    // Pastikan buyerName ada — ambil dari dok order, atau users/{buyerId}
    String buyerName = (data['buyerName'] ?? '') as String? ?? '';
    if (buyerName.trim().isEmpty) {
      final buyerId = (data['buyerId'] ?? '') as String? ?? '';
      if (buyerId.isNotEmpty) {
        try {
          final userSnap =
              await FirebaseFirestore.instance.collection('users').doc(buyerId).get();
          buyerName = (userSnap.data()?['name'] ?? '-') as String? ?? '-';
        } catch (_) {
          buyerName = '-';
        }
      } else {
        buyerName = '-';
      }
    }

    // Siapkan payload lengkap untuk TransactionDetailPage (dengan fallback storeMeta)
    final txMap = _mapOrderToTransaction(
      orderId: orderId,
      data: data,
      buyerName: buyerName,
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(transaction: txMap),
      ),
    );
  }

  /// Map lengkap untuk halaman detail (dan PDF)
  Map<String, dynamic> _mapOrderToTransaction({
    required String orderId,
    required Map<String, dynamic> data,
    required String buyerName,
  }) {
    final statusRaw =
        ((data['status'] ?? data['shippingAddress']?['status'] ?? 'PLACED') as String)
            .toUpperCase();

    String uiStatus;
    if (statusRaw == 'COMPLETED' ||
        statusRaw == 'SUCCESS' ||
        statusRaw == 'SETTLED' ||
        statusRaw == 'DELIVERED') {
      uiStatus = 'Sukses';
    } else if (statusRaw == 'CANCELLED' ||
        statusRaw == 'CANCELED' ||
        statusRaw == 'REJECTED' ||
        statusRaw == 'FAILED') {
      uiStatus = 'Gagal';
    } else {
      uiStatus = 'Tertahan';
    }

    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
    final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
    final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
    final tax = ((amounts['tax'] as num?) ?? 0).toInt();
    final total =
        ((amounts['total'] as num?) ?? (subtotal + shipping + tax)).toInt();

    final createdAt = (data['updatedAt'] ?? data['createdAt']);
    final date = createdAt is Timestamp ? createdAt.toDate() : null;

    final ship = (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
    final addressLabel = (ship['label'] ?? '-') as String;
    final addressText =
        (ship['addressText'] ?? ship['address'] ?? '-') as String;
    final phone = (ship['phone'] ?? '-') as String;

    final method =
        ((data['payment']?['method'] ?? 'abc_payment') as String).toUpperCase();

    final inv = (data['invoiceId'] as String?)?.trim();
    final invoiceId = (inv != null && inv.isNotEmpty) ? inv : orderId;

    // ⬇️ Ambil info toko dari dok order bila ada; jika kosong, fallback ke _storeMeta (hasil load dari stores)
    final rawStoreName = ((data['storeName'] ?? '') as String).trim();
    final rawStorePhone = ((data['storePhone'] ?? '') as String).trim();
    final rawStoreAddress = ((data['storeAddress'] ?? '') as String).trim();

    final storeName = rawStoreName.isNotEmpty ? rawStoreName : (_storeMeta['name'] ?? '-');
    final storePhone = rawStorePhone.isNotEmpty ? rawStorePhone : (_storeMeta['phone'] ?? '-');
    final storeAddress = rawStoreAddress.isNotEmpty ? rawStoreAddress : (_storeMeta['address'] ?? '-');

    return {
      // identitas
      'invoiceId': invoiceId,
      'status': uiStatus,
      'date': date,

      // info toko (dipakai di PDF)
      'store': {
        'name': storeName,
        'phone': storePhone,
        'address': storeAddress,
      },

      // info pembeli & pengiriman
      'buyerName': buyerName,
      'shipping': {
        'recipient': buyerName,
        'addressLabel': addressLabel,
        'addressText': addressText,
        'phone': phone,
      },

      // pembayaran & amounts
      'paymentMethod': method,
      'amounts': {
        'subtotal': subtotal,
        'shipping': shipping,
        'tax': tax,
        'total': total,
      },

      // item rows
      'items': items
          .map((it) => {
                'name': (it['name'] ?? '-') as String,
                'qty': ((it['qty'] as num?) ?? 0).toInt(),
                'price': ((it['price'] as num?) ?? 0).toInt(),
                'variant': (it['variant'] ?? it['note'] ?? '') as String,
              })
          .toList(),
    };
  }

  /// ===== Helpers kecil =====
  String _statusToUi(String raw) {
    if (raw == 'COMPLETED' ||
        raw == 'SUCCESS' ||
        raw == 'SETTLED' ||
        raw == 'DELIVERED') {
      return 'Sukses';
    }
    if (raw == 'CANCELLED' ||
        raw == 'CANCELED' ||
        raw == 'REJECTED' ||
        raw == 'FAILED') {
      return 'Gagal';
    }
    return 'Tertahan';
  }

  String _fmtDateIndo(DateTime d) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }
}
