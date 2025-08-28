import 'package:abc_e_mart/buyer/features/wallet/top_up_wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/features/wallet/detail_wallet_success_page.dart';
import 'package:abc_e_mart/buyer/features/wallet/verification_top_up_page.dart';
import 'package:abc_e_mart/buyer/features/wallet/failed_top_up_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ===== Model =====
enum WalletTxnType { topup, payment }
enum WalletTxnStatus { success, pending, failed }

class WalletTxn {
  final String id;
  final WalletTxnType type;
  final String title;     // "Isi Saldo" / "Pembayaran"
  final String subtitle;  // "Dari ABC Payment" / nama toko
  final int amount;       // topup: SALDO DIPILIH; payment: total bayar
  final DateTime createdAt;
  final WalletTxnStatus status;

  // ekstra untuk detail
  final int? adminFee;   // topup
  final int? totalPaid;  // topup (amount + adminFee)
  final String? reason;  // topup rejection reason
  final List<LineItem>? items; // payment -> detail
  final int? shipping;   // payment
  final int? tax;

  WalletTxn({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.createdAt,
    required this.status,
    this.adminFee,
    this.totalPaid,
    this.reason,
    this.items,
    this.shipping,
    this.tax,
  });
}

class HistoryWalletPage extends StatefulWidget {
  const HistoryWalletPage({super.key});

  @override
  State<HistoryWalletPage> createState() => _HistoryWalletPageState();
}

class _HistoryWalletPageState extends State<HistoryWalletPage> {
  final _search = TextEditingController();
  String _query = '';
  int _filterIndex = 0; // 0=Semua, 1=Isi Saldo, 2=Pembayaran

  bool _loading = true;
  String? _error;
  final List<WalletTxn> _items = [];

  // spacing UI
  static const double _bottomRowTopGap = 16;
  static const double _detailChevronGap = 6;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });

    try {
      final fs = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Belum login');

      // ---------- TOPUP ----------
      final topupSnap = await fs
          .collection('paymentApplications')
          .where('type', isEqualTo: 'topup')
          .where('buyerId', isEqualTo: uid)
          .orderBy('submittedAt', descending: true)
          .limit(100)
          .get();

      final topups = topupSnap.docs.map((d) {
        final data = d.data();

        final ts = data['submittedAt'] as Timestamp?;
        final created = ts?.toDate() ?? DateTime.now();

        final statusStr = (data['status'] as String? ?? 'pending').toLowerCase();
        final status = switch (statusStr) {
          'approved' => WalletTxnStatus.success,
          'rejected' => WalletTxnStatus.failed,
          _          => WalletTxnStatus.pending,
        };

        final amount    = (data['amount'] as num?)?.toInt() ?? 0;  // SALDO DIPILIH
        final adminFee  = (data['fee'] as num?)?.toInt();
        final totalPaid = (data['totalPaid'] as num?)?.toInt();
        final reason    = data['rejectionReason'] as String?;
        final methodLbl = data['method'] as String?;

        return WalletTxn(
          id: d.id,
          type: WalletTxnType.topup,
          title: 'Isi Saldo',
          subtitle: methodLbl == null ? 'Dari ABC Payment' : 'Dari $methodLbl',
          amount: amount,              // << tampilkan + sesuai saldo dipilih
          createdAt: created,
          status: status,
          adminFee: adminFee,
          totalPaid: totalPaid,
          reason: reason,
        );
      }).toList();

      // ---------- PAYMENT ----------
      final orderSnap = await fs
          .collection('orders')
          .where('buyerId', isEqualTo: uid)
          .where('status', whereIn: ['COMPLETED', 'SUCCESS'])
          .orderBy('updatedAt', descending: true)
          .limit(100)
          .get();

      final payments = orderSnap.docs.map((d) {
        final data = d.data();

        final ts = (data['updatedAt'] as Timestamp?) ?? (data['createdAt'] as Timestamp?);
        final created = ts?.toDate() ?? DateTime.now();

        final storeName = (data['storeName'] as String?) ?? 'Toko';

        final amounts = (data['amounts'] as Map<String, dynamic>?) ?? const {};
        final total    = ((amounts['total'] as num?)    ?? (data['total'] as num?)    ?? 0).toInt();
        final shipping = ((amounts['shipping'] as num?) ?? (data['shipping'] as num?) ?? 0).toInt();
        final tax      = ((amounts['tax'] as num?)      ?? (data['tax'] as num?)      ?? 0).toInt();

        final rawItems = List<Map<String, dynamic>>.from((data['items'] as List?) ?? const []);
        final items = rawItems.map((m) => LineItem(
          (m['name'] as String?) ?? 'Item',
          ((m['qty'] as num?) ?? 1).toInt(),
          ((m['price'] as num?) ?? 0).toInt(),
        )).toList();

        return WalletTxn(
          id: d.id,
          type: WalletTxnType.payment,
          title: 'Pembayaran',
          subtitle: storeName,
          amount: total,
          createdAt: created,
          status: WalletTxnStatus.success,
          items: items,
          shipping: shipping,
          tax: tax,                     // <<< TAMBAHKAN KE MODEL
        );
      }).toList();

      final merged = <WalletTxn>[...topups, ...payments]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _items..clear()..addAll(merged);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _formatRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[s.length - 1 - i]);
      if ((i + 1) % 3 == 0 && i != s.length - 1) buf.write('.');
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}';
  }

  List<WalletTxn> get _filtered {
    var items = _items;
    if (_filterIndex == 1) {
      items = items.where((e) => e.type == WalletTxnType.topup).toList();
    } else if (_filterIndex == 2) {
      items = items.where((e) => e.type == WalletTxnType.payment).toList();
    }

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) =>
        e.title.toLowerCase().contains(q) || e.subtitle.toLowerCase().contains(q)
      ).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 13, top: 13, left: 16),
          child: SafeArea(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Riwayat Transaksi',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 19, color: const Color(0xFF232323))),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // search
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: custom_widgets.SearchBar(
              controller: _search,
              hintText: 'Cari transaksi',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // filter chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TypeSelector(
              labels: const ['Semua', 'Isi Saldo', 'Pembayaran'],
              selectedIndex: _filterIndex,
              onSelected: (i) => setState(() => _filterIndex = i),
              height: 20,
              gap: 10,
            ),
          ),
          const SizedBox(height: 14),

          // list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(_error!, textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(color: Colors.red)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: _filtered.isEmpty
                            ? const _EmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemCount: _filtered.length,
                                itemBuilder: (context, i) {
                                  final e = _filtered[i];
                                  final isTopup = e.type == WalletTxnType.topup;
                                  final isSuccess = e.status == WalletTxnStatus.success;

                                  final sign = isTopup
                                      ? (isSuccess ? '+' : '')
                                      : '-';
                                  final amountText = '$sign${_formatRupiah(e.amount)}';

                                  final amountColor = (isTopup && isSuccess)
                                      ? const Color(0xFF18A558)
                                      : const Color(0xFF373E3C);

                                  // onTap
                                  VoidCallback? onTapCard;
                                  if (!isSuccess && isTopup && e.status == WalletTxnStatus.pending) {
                                    onTapCard = () {
                                      Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const VerificationTopUpPage()));
                                    };
                                  } else if (!isSuccess && isTopup && e.status == WalletTxnStatus.failed) {
                                    onTapCard = () {
                                      Navigator.push(context,
                                        MaterialPageRoute(
                                          builder: (_) => FailedTopUpPage(
                                            reason: e.reason ?? 'Pengajuan isi saldo ditolak.',
                                            onRetry: () {
                                              Navigator.push(context,
                                                MaterialPageRoute(builder: (_) => const TopUpWalletPage()));
                                            },
                                          ),
                                        ),
                                      );
                                    };
                                  }

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: onTapCard, // null untuk success
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFFE6E6E6)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(.03),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 44, height: 44,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF1C55C0), shape: BoxShape.circle),
                                                  alignment: Alignment.center,
                                                  child: isTopup
                                                      ? SvgPicture.asset(
                                                          'assets/icons/banknote-arrow-down.svg',
                                                          width: 22, height: 22, color: Colors.white)
                                                      : Icon(LucideIcons.creditCard, size: 22, color: Colors.white),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(e.title,
                                                                  style: GoogleFonts.dmSans(
                                                                    fontSize: 15.5, fontWeight: FontWeight.w700,
                                                                    color: const Color(0xFF232323))),
                                                                const SizedBox(height: 2),
                                                                Text(e.subtitle,
                                                                  style: GoogleFonts.dmSans(
                                                                      fontSize: 12.5, color: const Color(0xFF5B5F62))),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Text(amountText,
                                                                style: GoogleFonts.dmSans(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: amountColor,
                                                                ),
                                                              ),
                                                              if (isSuccess) ...[
                                                                const SizedBox(height: 6),
                                                                const _StatusBadge(), // compact
                                                              ],
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: _bottomRowTopGap),

                                            Row(
                                              children: [
                                                Text(_formatDate(e.createdAt),
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 12.5, color: const Color(0xFF9AA0A6))),
                                                const Spacer(),
                                                if (isSuccess)
                                                  InkWell(
                                                    onTap: () {
                                                      if (isTopup) {
                                                        // >>> TOP-UP
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) => DetailWalletSuccessPage(
                                                              isTopup: true,
                                                              counterpartyName: e.subtitle,
                                                              amount: e.amount,
                                                              createdAt: e.createdAt,
                                                              adminFee: e.adminFee ?? 0,
                                                              totalTopup: e.totalPaid ?? (e.amount + (e.adminFee ?? 0)),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        // >>> PEMBAYARAN
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) => DetailWalletSuccessPage(
                                                              isTopup: false,
                                                              counterpartyName: e.subtitle,
                                                              amount: e.amount,
                                                              createdAt: e.createdAt,
                                                              items: e.items,
                                                              shippingFeeOverride: e.shipping,
                                                              tax: e.tax,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text('Lihat Detail',
                                                          style: GoogleFonts.dmSans(
                                                            fontSize: 12.5,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF6B7280),
                                                          ),
                                                        ),
                                                        const SizedBox(width: _detailChevronGap),
                                                        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF6B7280)),
                                                      ],
                                                    ),
                                                  )
                                                else
                                                  _StatusBadge(status: e.status),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

/// ===== Selector chip
class _TypeSelector extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;
  final double gap;

  const _TypeSelector({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 20,
    this.gap = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 10,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: gap),
        itemBuilder: (context, i) {
          final active = selectedIndex == i;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              height: height,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2066CF) : Colors.white,
                border: Border.all(
                  color: active ? const Color(0xFF2066CF) : const Color(0xFF9A9A9A),
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: active ? Colors.white : const Color(0xFF9A9A9A),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ===== Badge status (kompak seperti seller)
class _StatusBadge extends StatelessWidget {
  final WalletTxnStatus? status; // null => default Berhasil
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final s = status ?? WalletTxnStatus.success;

    late Color text, bg, border;
    late String label;

    switch (s) {
      case WalletTxnStatus.success:
        label  = 'Berhasil';
        text   = const Color(0xFF28A745);
        bg     = const Color(0xFFF1FFF6);
        border = const Color(0xFF28A745);
        break;
      case WalletTxnStatus.pending:
        label  = 'Pending';
        text   = const Color(0xFFEAB600);
        bg     = const Color(0xFFFFFBF1);
        border = const Color(0xFFEAB600);
        break;
      case WalletTxnStatus.failed:
        label  = 'Gagal';
        text   = const Color(0xFFDC3545);
        bg     = const Color(0xFFFFF1F3);
        border = const Color(0xFFDC3545);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(color: text, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: text,
              letterSpacing: 0.02,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== Empty state
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.receipt, size: 90, color: Colors.grey[300]),
            const SizedBox(height: 18),
            Text(
              'Belum ada transaksi',
              style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              'Transaksi ABC Payment kamu akan muncul di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}