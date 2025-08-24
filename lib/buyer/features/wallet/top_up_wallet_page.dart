// lib/buyer/features/wallet/top_up_wallet_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TopUpWalletPage extends StatefulWidget {
  const TopUpWalletPage({super.key});

  @override
  State<TopUpWalletPage> createState() => _TopUpWalletPageState();
}

class _TopUpWalletPageState extends State<TopUpWalletPage> {
  int _amount = 20000;
  final int _adminFee = 1000;
  final List<int> _presets = const [10000, 20000, 25000, 50000, 100000, 200000];

  String? _paymentMethod;

  String _formatRp(int v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
          .format(v)
          .replaceAll('Rp', 'Rp ');

  String _formatShort(int v) {
    final n = (v / 1000).round();
    return 'Rp${NumberFormat('#,###', 'id_ID').format(n)}rb';
  }

  Future<void> _pickPaymentMethod() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final items = [
          'Transfer Bank',
          'E-Wallet (OVO/DANA/GoPay)',
          'Virtual Account',
          'Kartu Kredit/Debit',
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E9EF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pilih Metode Pembayaran',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...items.map((e) => ListTile(
                    title: Text(e, style: GoogleFonts.dmSans(fontSize: 14.5)),
                    onTap: () => Navigator.pop(context, e),
                  )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _paymentMethod = selected);
  }

  @override
  Widget build(BuildContext context) {
    final total = _amount + _adminFee;

    return Scaffold(
      backgroundColor: Colors.white,

      // Header (H5 seperti halaman Favorit)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2056D3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
        title: Text(
          'Isi Saldo',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            color: Colors.black,
          ),
        ),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nominal Saldo',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kartu nominal
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEFF5)),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        children: [
                          // Display nominal: abu-abu
                          Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE6E9EF)),
                            ),
                            child: Text(
                              _formatRp(_amount),
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF212121),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Preset chips (grid 3 kolom)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _presets.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.7,
                            ),
                            itemBuilder: (context, i) {
                              final v = _presets[i];
                              final selected = v == _amount;
                              return InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => setState(() => _amount = v),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFF2056D3).withOpacity(.08)
                                        : Colors.white,
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFF2056D3)
                                          : const Color(0xFFE0E5EE),
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _formatShort(v),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? const Color(0xFF2056D3)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // H4
                    Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 10),

                    InkWell(
                      onTap: _pickPaymentMethod,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDEFF5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_rounded,
                                size: 20, color: Color(0xFF212121)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _paymentMethod ?? 'Pilih Metode Pembayaran',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF212121),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF212121)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // H4
                    Text(
                      'Detail Tagihan',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kotak 1: Isi Saldo + Biaya Admin
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDEFF5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        children: [
                          _BillRow(
                            label: 'Isi Saldo',
                            value: _formatRp(_amount),
                            boldValue: true, // hanya angka yang tebal
                          ),
                          const SizedBox(height: 6),
                          _BillRow(
                            label: 'Biaya Admin',
                            value: _formatRp(_adminFee),
                            boldValue: true, // hanya angka yang tebal
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kotak 2: Total
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDEFF5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: _BillRow(
                        label: 'Total',
                        value: _formatRp(total),
                        boldLabel: true,
                        boldValue: true,
                        bigger: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  16 + MediaQuery.of(context).viewPadding.bottom,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _paymentMethod == null
                                  ? 'Silakan pilih metode pembayaran dulu.'
                                  : 'Konfirmasi isi saldo sebesar ${_formatRp(total)} (${_paymentMethod!})',
                              style: GoogleFonts.dmSans(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2056D3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Konfirmasi',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool boldLabel; // tebal untuk label?
  final bool boldValue; // tebal untuk angka?
  final bool bigger;    // sedikit lebih besar (untuk Total)

  const _BillRow({
    required this.label,
    required this.value,
    this.boldLabel = false,
    this.boldValue = false,
    this.bigger = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = bigger ? 15 : 14;

    final labelStyle = GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: boldLabel ? FontWeight.w800 : FontWeight.w500,
      color: const Color(0xFF212121),
    );

    final valueStyle = GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: boldValue ? FontWeight.w800 : FontWeight.w500,
      color: const Color(0xFF212121),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
      ],
    );
  }
}
