import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:abc_e_mart/seller/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/seller/widgets/status_selector.dart';

import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';
import 'package:abc_e_mart/seller/widgets/seller_transaction_card.dart';

import 'transaction_detail_page.dart'; // Import halaman detail transaksi

/// ===== Model & enums (UI demo; ganti ke Firestore nanti) =====
enum TxStatus { semua, sukses, tertahan, gagal }

class TxItem {
  final String invoiceId;
  final DateTime date;
  final TxStatus status;
  final List<String> items;
  final int total;

  TxItem({
    required this.invoiceId,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
  });
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _searchC = TextEditingController();
  int _selectedIndex = 0; // 0 Semua, 1 Sukses, 2 Tertahan, 3 Gagal

  final List<String> _statusLabels = const ['Semua', 'Sukses', 'Tertahan', 'Gagal'];

  // Demo data – ganti dengan data Firestore
  final List<TxItem> _all = [
    TxItem(
      invoiceId: "NPN001",
      date: DateTime(2025, 7, 5, 9, 41),
      status: TxStatus.sukses,
      items: ["Ayam Geprek|Pedas", "Ayam Geprek|Sedang", "Ayam Geprek|"],
      total: 75000,
    ),
    TxItem(
      invoiceId: "NPN002",
      date: DateTime(2025, 7, 5, 9, 41),
      status: TxStatus.tertahan,
      items: ["Ayam Geprek|Sedang", "Ayam Geprek|Pedas"],
      total: 75000,
    ),
    TxItem(
      invoiceId: "NPN003",
      date: DateTime(2025, 7, 5, 9, 41),
      status: TxStatus.gagal,
      items: ["Ayam Geprek|Pedas", "Ayam Geprek|", "Ayam Geprek|Pedas"],
      total: 75000,
    ),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered(_all, _selectedIndex, _searchC.text);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header (match ProductsPage)
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

            /// GAP: header → search = 12
            const SizedBox(height: 12),

            /// Search bar (reusable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: custom_widgets.SearchBar(
                hintText: "Cari transaksi",
                onChanged: (val) => setState(() {}),
              ),
            ),

            const SizedBox(height: 20),

            /// Status selector (size/style sama CategorySelector)
            StatusSelector(
              labels: _statusLabels,
              selectedIndex: _selectedIndex,
              onSelected: (idx) => setState(() => _selectedIndex = idx),
              height: 20,
              gap: 10,
              padding: const EdgeInsets.only(left: 20, right: 20),
            ),

            /// GAP: selector → list = 12
            const SizedBox(height: 12),

            /// List kartu transaksi (reuse SellerTransactionCard)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final tx = filtered[i];
                  final data = _toSellerCardData(tx);
                  return SellerTransactionCard(
                    data: data,
                    onDetail: () {
                      // Navigasi ke halaman detail transaksi
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailPage(
                            transaction: {
                              'invoiceId': tx.invoiceId,
                              'status': data.status,
                              'total': tx.total,
                              'items': tx.items.map((item) {
                                final parts = item.split('|');
                                return {
                                  'name': parts[0],
                                  'note': parts.length > 1 ? parts[1] : '',
                                  'qty': 1,
                                };
                              }).toList(),
                            },
                          ),
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
    );
  }

  /// ===== Helpers =====
  TxStatus _statusFromIndex(int idx) {
    switch (idx) {
      case 1: return TxStatus.sukses;
      case 2: return TxStatus.tertahan;
      case 3: return TxStatus.gagal;
      default: return TxStatus.semua;
    }
  }

  List<TxItem> _filtered(List<TxItem> src, int idx, String q) {
    final sel = _statusFromIndex(idx);
    Iterable<TxItem> it = src;

    if (sel != TxStatus.semua) it = it.where((e) => e.status == sel);
    if (q.trim().isNotEmpty) {
      final qq = q.toLowerCase();
      it = it.where((e) =>
          e.invoiceId.toLowerCase().contains(qq) ||
          e.items.any((s) => s.toLowerCase().contains(qq)));
    }
    return it.toList();
  }

  /// Konversi TxItem -> SellerTransactionCardData (UI 100% sama dengan Home)
  SellerTransactionCardData _toSellerCardData(TxItem t) {
    final statusLabel = () {
      switch (t.status) {
        case TxStatus.sukses:   return "Sukses";
        case TxStatus.tertahan: return "Tertahan";
        case TxStatus.gagal:    return "Gagal";
        case TxStatus.semua:    return "";
      }
    }();

    final items = t.items.map((raw) {
      final parts = raw.split('|');
      final name = parts.isNotEmpty ? parts[0] : '';
      final note = parts.length > 1 ? parts[1] : '';
      return TransactionCardItem(name: name, note: note, qty: 1);
    }).toList();

    return SellerTransactionCardData(
      invoiceId: t.invoiceId,
      date: _formatDate(t.date),
      status: statusLabel,
      items: items,
      total: t.total,
      onDetail: () {
        // This will be handled by the onDetail callback passed to the SellerTransactionCard
      },
    );
  }

  String _formatDate(DateTime d) {
    const bulan = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }
}
