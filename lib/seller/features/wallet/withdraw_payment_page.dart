  import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:abc_e_mart/seller/features/wallet/success_withdrawal_page.dart';
import 'package:abc_e_mart/seller/features/wallet/withdraw_history_page.dart';
import 'package:abc_e_mart/seller/features/home/home_page_seller.dart';

class WithdrawPaymentPage extends StatefulWidget {
  final int currentBalance; // contoh: 150000
  final int adminFee;       // contoh: 1000
  final int minWithdraw;    // contoh: 10000

  const WithdrawPaymentPage({
    super.key,
    this.currentBalance = 150000,
    this.adminFee = 1000,
    this.minWithdraw = 10000,
  });

  @override
  State<WithdrawPaymentPage> createState() => _WithdrawPaymentPageState();
}

class _WithdrawPaymentPageState extends State<WithdrawPaymentPage> {
  // nominal
  int _amount = 20000;
  final List<int> _presets = const [10000, 20000, 25000, 50000, 100000, 200000];

  // form data
  final _bankCtrl = TextEditingController();
  final _accNoCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();

  // counter
  int _bankLen = 0, _accNoLen = 0, _ownerLen = 0;

  @override
  void initState() {
    super.initState();
    _bankCtrl.addListener(() => setState(() => _bankLen = _bankCtrl.text.characters.length));
    _accNoCtrl.addListener(() => setState(() => _accNoLen = _accNoCtrl.text.characters.length));
    _ownerCtrl.addListener(() => setState(() => _ownerLen = _ownerCtrl.text.characters.length));
  }

  @override
  void dispose() {
    _bankCtrl.dispose();
    _accNoCtrl.dispose();
    _ownerCtrl.dispose();
    super.dispose();
  }

  String _formatRp(int v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
          .format(v)
          .replaceAll('Rp', 'Rp ');

  String _formatShort(int v) {
    final n = (v / 1000).round();
    return 'Rp${NumberFormat('#,###', 'id_ID').format(n)}rb';
  }

  String _maskAccount(String s) {
    final onlyDigits = s.replaceAll(RegExp(r'\D'), '');
    if (onlyDigits.isEmpty) return '-';
    if (onlyDigits.length <= 3) return '*' * onlyDigits.length;
    return onlyDigits.substring(0, onlyDigits.length - 3) + '***';
  }

  bool get _isFormValid {
    final hasRequired =
        _bankCtrl.text.trim().isNotEmpty &&
        _accNoCtrl.text.trim().isNotEmpty &&
        _ownerCtrl.text.trim().isNotEmpty;

    final nominalOk =
        _amount >= widget.minWithdraw && _amount <= widget.currentBalance;

    return hasRequired && nominalOk;
  }

  @override
  Widget build(BuildContext context) {
    final totalReceived = (_amount - widget.adminFee).clamp(0, 1 << 31);

    return Scaffold(
      backgroundColor: Colors.white,

      // HEADER
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
          'Tarik Saldo',
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total saldo
                    Center(
                      child: Column(
                        children: [
                          Text('Total Saldo Anda',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14.5,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            _formatRp(widget.currentBalance),
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Judul
                    Text(
                      'Jumlah Penarikan',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kartu nominal + preset
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEFF5)),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        children: [
                          // Display nominal
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

                          // Presets
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

                              // >>> DISABLED jika < minimal atau > saldo
                              final disabled = v < widget.minWithdraw || v > widget.currentBalance;

                              final bgColor = disabled
                                  ? const Color(0xFFF7F8FB)
                                  : (selected
                                      ? const Color(0xFF2056D3).withOpacity(.08)
                                      : Colors.white);
                              final borderColor = disabled
                                  ? const Color(0xFFE9EDF5)
                                  : (selected
                                      ? const Color(0xFF2056D3)
                                      : const Color(0xFFE0E5EE));
                              final textColor = disabled
                                  ? const Color(0xFFBFC7DA)
                                  : (selected
                                      ? const Color(0xFF2056D3)
                                      : const Color(0xFF374151));

                              return InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: disabled
                                    ? null
                                    : () => setState(() => _amount = v),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    border: Border.all(color: borderColor),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _formatShort(v),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '*Minimal Penarikan Sebesar ${_formatRp(widget.minWithdraw)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12.5,
                                color: const Color(0xFF9AA0A6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Data penarikan
                    Text(
                      'Data Penarikan Saldo',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _SellerInputField(
                      controller: _bankCtrl,
                      label: 'Bank Tujuan',
                      required: true,
                      maxLength: 300,
                      counter: _bankLen,
                    ),
                    _SellerInputField(
                      controller: _accNoCtrl,
                      label: 'No. Rekening Bank',
                      required: true,
                      maxLength: 16,
                      counter: _accNoLen,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                    ),
                    _SellerInputField(
                      controller: _ownerCtrl,
                      label: 'Nama Pemilik Rekening',
                      required: true,
                      maxLength: 300,
                      counter: _ownerLen,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '*Pastikan nomor rekening dan nama pemilik sesuai dengan data bank agar proses pencairan saldo berjalan lancar; kesalahan pengisian dapat menyebabkan pencairan tertunda atau gagal.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5,
                        color: const Color(0xFF6B7280),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Detail penarikan
                    Text(
                      'Detail Penarikan',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Box 1
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
                            label: 'Rekening Tujuan',
                            value: _maskAccount(_accNoCtrl.text),
                            boldValue: true,
                          ),
                          const SizedBox(height: 6),
                          _BillRow(
                            label: 'Jumlah Penarikan',
                            value: _formatRp(_amount),
                            boldValue: true,
                          ),
                          const SizedBox(height: 6),
                          _BillRow(
                            label: 'Biaya Admin',
                            value: _formatRp(widget.adminFee),
                            boldValue: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Box 2
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDEFF5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: _BillRow(
                        label: 'Total Diterima',
                        value: _formatRp(totalReceived),
                        boldLabel: true,
                        boldValue: true,
                        bigger: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Button
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20, 12, 20, 16 + MediaQuery.of(context).viewPadding.bottom),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid
                        ? () {
                            // TODO: kirim request penarikan ke backend di sini (optional)

                            // Buka halaman sukses penarikan
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SuccessWithdrawalPage(
                                  // tombol "Kembali ke Beranda"
                                  onGoHome: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const HomePageSeller()),
                                      (r) => false,
                                    );
                                  },
                                  // link "Lihat Status Penarikan"
                                  onViewHistory: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const WithdrawHistoryPageSeller(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2056D3),
                        disabledBackgroundColor: const Color(0xFFBFC7DA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Tarik Saldo',
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
  final bool boldLabel;
  final bool boldValue;
  final bool bigger;

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

/// Input field bergaya seller (dengan counter kanan)
class _SellerInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final int? maxLength;
  final int counter;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _SellerInputField({
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLength,
    required this.counter,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (required) const SizedBox(width: 4),
                  if (required)
                    const Text(
                      '*',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              filled: true, // <<< abu-abu seperti referensi
              fillColor: const Color(0xFFF7F8FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEDEFF5), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEDEFF5), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              hintText: 'Masukkan $label',
              hintStyle: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[400]),
              counterText: "",
            ),
          ),
          if (maxLength != null)
            Positioned(
              right: 14,
              bottom: 8,
              child: Text(
                "$counter/$maxLength",
                style: GoogleFonts.dmSans(fontSize: 13.5, color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }
}
