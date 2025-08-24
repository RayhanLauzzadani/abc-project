import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/seller/features/wallet/detail_wallet_seller_succes_page.dart';
import 'package:abc_e_mart/seller/features/wallet/verification_withdrawal_page.dart';
import 'package:abc_e_mart/seller/features/wallet/failed_withdrawal_page.dart';
// opsional, jika ingin langsung arahkan ke form pengajuan ulang:
import 'package:abc_e_mart/seller/features/wallet/withdraw_payment_page.dart';

/// ===== Model sederhana (mock data) =====
enum _SellerTxnType { income, withdraw }
enum _SellerTxnStatus { success, pending, failed }

class _SellerTxn {
  final String id;
  final _SellerTxnType type;   // income / withdraw
  final String title;          // "Pemasukan" / "Penarikan Saldo"
  final String subtitle;       // contoh: "Pesanan #WPN001" / "Ke Rekening BCA ***2341"
  final int amount;            // nominal positif; render +/- sesuai type
  final DateTime createdAt;
  final _SellerTxnStatus status;

  const _SellerTxn({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.createdAt,
    required this.status,
  });
}

class WithdrawHistoryPageSeller extends StatefulWidget {
  const WithdrawHistoryPageSeller({super.key});

  @override
  State<WithdrawHistoryPageSeller> createState() => _WithdrawHistoryPageSellerState();
}

class _WithdrawHistoryPageSellerState extends State<WithdrawHistoryPageSeller> {
  final _search = TextEditingController();
  String _query = '';
  int _filterIndex = 0; // 0=Semua, 1=Pemasukan, 2=Penarikan Saldo

  // Mock data; nanti tinggal ganti ke Firestore.
  final List<_SellerTxn> _all = [
    _SellerTxn(
      id: 's1',
      type: _SellerTxnType.income,
      title: 'Pemasukan',
      subtitle: 'Pesanan #WPN001',
      amount: 24750,
      createdAt: DateTime(2025, 4, 30, 16, 21),
      status: _SellerTxnStatus.success,
    ),
    _SellerTxn(
      id: 's2',
      type: _SellerTxnType.withdraw,
      title: 'Penarikan Saldo',
      subtitle: 'Ke Rekening BCA ***2341',
      amount: 20000,
      createdAt: DateTime(2025, 4, 30, 16, 21),
      status: _SellerTxnStatus.success,
    ),
    _SellerTxn(
      id: 's3',
      type: _SellerTxnType.withdraw,
      title: 'Penarikan Saldo',
      subtitle: 'Ke Rekening BCA ***2341',
      amount: 15000,
      createdAt: DateTime(2025, 4, 30, 16, 21),
      status: _SellerTxnStatus.pending,
    ),
    _SellerTxn(
      id: 's4',
      type: _SellerTxnType.withdraw,
      title: 'Penarikan Saldo',
      subtitle: 'Ke Rekening BCA ***2341',
      amount: 15000,
      createdAt: DateTime(2025, 4, 30, 16, 21),
      status: _SellerTxnStatus.failed,
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _rp(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      b.write(s[s.length - 1 - i]);
      if ((i + 1) % 3 == 0 && i != s.length - 1) b.write('.');
    }
    return 'Rp ${b.toString().split('').reversed.join()}';
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}';
  }

  List<_SellerTxn> get _filtered {
    var items = _all;

    if (_filterIndex == 1) {
      items = items.where((e) => e.type == _SellerTxnType.income).toList();
    } else if (_filterIndex == 2) {
      items = items.where((e) => e.type == _SellerTxnType.withdraw).toList();
    }

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q)).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar – gaya sama seperti buyer
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
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Riwayat Transaksi',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    color: const Color(0xFF232323),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: custom_widgets.SearchBar(
              controller: _search,
              hintText: 'Cari transaksi',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Chips: Semua / Pemasukan / Penarikan Saldo
          _TypeSelector(
            labels: const ['Semua', 'Pemasukan', 'Penarikan Saldo'],
            selectedIndex: _filterIndex,
            onSelected: (i) => setState(() => _filterIndex = i),
            height: 20,
            gap: 10,
            // pilih salah satu padding di bawah ini:
            // padding: EdgeInsets.zero, // benar-benar mepet tepi layar
            padding: const EdgeInsets.symmetric(horizontal: 14), // match list/card
          ),
          const SizedBox(height: 14),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final e = _filtered[i];
                      final isIncome = e.type == _SellerTxnType.income;
                      final isSuccess = e.status == _SellerTxnStatus.success;

                      VoidCallback? onTapCard;
                      if (!isIncome && !isSuccess && e.status == _SellerTxnStatus.pending) {
                        onTapCard = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VerificationWithdrawalPage()),
                          );
                        };
                      } else if (!isIncome && !isSuccess && e.status == _SellerTxnStatus.failed) {
                        onTapCard = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FailedWithdrawalPage(
                                onRetry: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const WithdrawPaymentPage()),
                                  );
                                },
                              ),
                            ),
                          );
                        };
                      }

                      final sign = isIncome
                          ? (isSuccess ? '+' : '')
                          : '-';
                      final amountText = '$sign${_rp(e.amount)}';

                      final amountColor = (isIncome && isSuccess)
                          ? const Color(0xFF18A558)
                          : const Color(0xFF373E3C);

                      // Card
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: onTapCard,
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
                                // Row utama
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1C55C0),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: isIncome
                                          ? Icon(LucideIcons.creditCard,
                                              size: 22, color: Colors.white)
                                          : SvgPicture.asset(
                                              'assets/icons/banknote-arrow-down.svg',
                                              width: 22,
                                              height: 22,
                                              color: Colors.white,
                                            ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Teks kiri
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
                                                    Text(
                                                      e.title,
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: 15.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: const Color(0xFF232323),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      e.subtitle,
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: 12.5,
                                                        color: const Color(0xFF5B5F62),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    amountText,
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: amountColor,
                                                    ),
                                                  ),
                                                  if (isSuccess) ...[
                                                    const SizedBox(height: 6),
                                                    const _StatusBadge(), // default: Berhasil
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

                                const SizedBox(height: 16),

                                // Footer
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(e.createdAt),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12.5,
                                        color: const Color(0xFF9AA0A6),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSuccess)
                                      InkWell(
                                        onTap: () {
                                          final mockItems = [
                                            const LineItem('Ayam Geprek Pedas', 1, 15000),
                                            const LineItem('Beng - Beng', 1, 7500),
                                          ];
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetailWalletSellerSuccessPage(
                                                isIncome: isIncome,
                                                counterpartyName: e.subtitle,
                                                amount: e.amount,
                                                createdAt: e.createdAt,
                                                items: isIncome ? mockItems : null, // hanya pemasukan
                                                adminFee: isIncome ? null : 1000,   // hanya penarikan
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Lihat Detail',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
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
        ],
      ),
    );
  }
}

/// ===== Selector chip (sama seperti buyer) =====
class _TypeSelector extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;
  final double gap;
  final EdgeInsetsGeometry? padding; // <— baru

  const _TypeSelector({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 20,
    this.gap = 10,
    this.padding, // <— baru
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 10,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.zero, // <— pakai padding internal
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

/// ===== Badge status (berhasil/pending/gagal) =====
class _StatusBadge extends StatelessWidget {
  final _SellerTxnStatus? status; // null => Berhasil (untuk kanan-atas)
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final s = status ?? _SellerTxnStatus.success;

    late Color text, bg, border;
    late String label;

    switch (s) {
      case _SellerTxnStatus.success:
        label = 'Berhasil';
        text = const Color(0xFF28A745);
        bg = const Color(0xFFF1FFF6);
        border = const Color(0xFF28A745);
        break;
      case _SellerTxnStatus.pending:
        label = 'Pending';
        text = const Color(0xFFEAB600);
        bg = const Color(0xFFFFFBF1);
        border = const Color(0xFFEAB600);
        break;
      case _SellerTxnStatus.failed:
        label = 'Gagal';
        text = const Color(0xFFDC3545);
        bg = const Color(0xFFFFF1F3);
        border = const Color(0xFFDC3545);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

/// ===== Empty state =====
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
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Transaksi toko kamu akan muncul di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
