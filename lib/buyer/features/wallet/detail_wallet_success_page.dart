import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LineItem {
  final String name;
  final int qty;
  final int price; // harga satuan
  const LineItem(this.name, this.qty, this.price);
}

class DetailWalletSuccessPage extends StatelessWidget {
  final bool isTopup;
  final String counterpartyName;
  /// PEMBAYARAN: total pembayaran
  /// TOP-UP: SALDO DIPILIH (bukan total)
  final int amount;
  final DateTime createdAt;

  // untuk pembayaran
  final List<LineItem>? items;
  final int? shippingFeeOverride;
  final int? tax;  

  // untuk top up
  final int? adminFee;
  final int? totalTopup; // amount + adminFee (opsional, fallback dihitung sendiri)

  const DetailWalletSuccessPage({
    super.key,
    required this.isTopup,
    required this.counterpartyName,
    required this.amount,
    required this.createdAt,
    this.items,
    this.shippingFeeOverride,
    this.tax,
    this.adminFee,
    this.totalTopup,
  });

  String _rp(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      b.write(s[s.length - 1 - i]);
      if ((i + 1) % 3 == 0 && i != s.length - 1) b.write('.');
    }
    return 'Rp ${b.toString().split('').reversed.join()}';
  }

  String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final sign = isTopup ? '+' : '-';
    final amountColor = isTopup ? const Color(0xFF18A558) : const Color(0xFF373E3C);

    // PEMBAYARAN
    final list = items ?? const <LineItem>[];
    final subtotal = list.fold<int>(0, (a, e) => a + e.price * e.qty);
    final taxValue = tax ?? 0;
    final shipping = shippingFeeOverride ?? (list.isEmpty ? 0 : (amount - subtotal - taxValue));

    // TOP-UP
    final admin = adminFee ?? 1000;
    final saldoDipilih = isTopup ? amount : 0; // amount = saldo dipilih
    final totalTopupValue = isTopup ? (totalTopup ?? (saldoDipilih + admin)) : 0;

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
                Text('Detail Transaksi',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700, fontSize: 19, color: const Color(0xFF232323))),
              ],
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          // Lottie success
          Center(
            child: SizedBox(
              width: 110,
              height: 110,
              child: Lottie.asset('assets/lottie/success_check.json', repeat: false),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '$sign${_rp(amount)}', // TOP-UP: tampilkan saldo dipilih
              style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w800, color: amountColor),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _date(createdAt),
              style: GoogleFonts.dmSans(fontSize: 12.5, color: const Color(0xFF9AA0A6)),
            ),
          ),

          const SizedBox(height: 18),

          _sectionTitle(isTopup ? 'Sumber Dana' : 'Bayar Ke'),
          const SizedBox(height: 8),
          _grayCard(
            child: Text(
              counterpartyName,
              style: GoogleFonts.dmSans(fontSize: 14.5, color: const Color(0xFF232323)),
            ),
          ),

          // Rincian Pesanan (pembayaran)
          if (!isTopup && list.isNotEmpty) ...[
            const SizedBox(height: 18),
            _sectionTitle('Rincian Pesanan'),
            const SizedBox(height: 8),
            _grayCard(
              child: Column(
                children: [
                  for (int i = 0; i < list.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(list[i].name,
                              style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF232323))),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('x ${list[i].qty}',
                                style: GoogleFonts.dmSans(fontSize: 13.2, color: const Color(0xFF5B5F62))),
                            const SizedBox(height: 4),
                            Text(_rp(list[i].price),
                                style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF232323))),
                          ],
                        ),
                      ],
                    ),
                    if (i != list.length - 1) const SizedBox(height: 12),
                  ]
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          _sectionTitle(isTopup ? 'Ringkasan Top Up' : 'Ringkasan Pembayaran'),
          const SizedBox(height: 8),

          if (isTopup) ...[
            _grayCard(
              child: Column(
                children: [
                  _twoCols('Saldo Dipilih', _rp(saldoDipilih), muted: true),
                  const SizedBox(height: 10),
                  _twoCols('Biaya Admin', _rp(admin), muted: true),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _grayCard(child: _twoCols('Total Top Up', _rp(totalTopupValue), bold: true)),
          ] else ...[
            _grayCard(
              child: Column(
                children: [
                  _twoCols('Subtotal', _rp(subtotal), muted: true),
                  const SizedBox(height: 10),
                  _twoCols('Biaya Pengiriman', _rp(shipping), muted: true),
                  if (taxValue > 0) ...[
                    const SizedBox(height: 10),
                    _twoCols('Pajak', _rp(taxValue), muted: true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            _grayCard(child: _twoCols('Total Pembayaran', _rp(amount), bold: true)),
          ],
        ],
      ),
    );
  }

  // ===== helpers UI
  Widget _sectionTitle(String s) => Text(
        s,
        style: GoogleFonts.dmSans(
          fontSize: 14.5, fontWeight: FontWeight.w700, color: const Color(0xFF373E3C)),
      );

  static Widget _grayCard({required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEFF5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: child,
      );

  Widget _twoCols(String l, String r, {bool bold = false, bool muted = false}) {
    final labelStyle = GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: muted ? const Color(0xFF6B7280) : const Color(0xFF212121),
    );
    final valueStyle = GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: const Color(0xFF212121),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(l, style: labelStyle, overflow: TextOverflow.ellipsis)),
        Text(r, style: valueStyle),
      ],
    );
  }
}