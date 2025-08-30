import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LineItem {
  final String name;
  final int qty;
  final int price; // harga satuan
  const LineItem(this.name, this.qty, this.price);
}

class DetailWalletSellerSuccessPage extends StatelessWidget {
  /// true = Pemasukan, false = Penarikan Saldo
  final bool isIncome;
  final String counterpartyName; // contoh: "Pesanan #WPN001" / "Ke Rekening BCA ***2341"

  /// Catatan:
  /// - Untuk PEMASUKAN: amount = total pemasukan.
  /// - Untuk PENARIKAN: amount = JUMLAH YANG DIPILIH seller (requested amount).
  final int amount;

  final DateTime createdAt;

  /// ====== OPSIONAL untuk PEMASUKAN ======
  final List<LineItem>? items;             // daftar item
  final int? shippingFeeOverride;          // override ongkir bila perlu

  /// ====== OPSIONAL untuk PENARIKAN ======
  final int? adminFee;                     // biaya layanan (sebelumnya "admin")
  final int? received;                     // total bersih diterima (jika disediakan server)
  final String? proofUrl;                  // bukti pencairan admin
  final String? proofName;
  final int? proofBytes;
  final int? tax;                          // pajak penarikan (opsional)

  const DetailWalletSellerSuccessPage({
    super.key,
    required this.isIncome,
    required this.counterpartyName,
    required this.amount,
    required this.createdAt,
    this.items,
    this.shippingFeeOverride,
    this.adminFee,
    this.received,
    this.proofUrl,
    this.proofName,
    this.proofBytes,
    this.tax,
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

  String _humanSize(int? b) {
    if (b == null) return '—';
    if (b >= 1024 * 1024) return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(b / 1024).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final sign = isIncome ? '+' : '-';
    final amountColor = isIncome ? const Color(0xFF18A558) : const Color(0xFF373E3C);

    // ===== perhitungan pemasukan
    final list = items ?? const <LineItem>[];
    final subtotal = list.fold<int>(0, (a, e) => a + e.price * e.qty);

    // Untuk seller: pajak income tidak ditampilkan/diikutkan
    final shipping = shippingFeeOverride ?? (list.isEmpty ? 0 : (amount - subtotal));

    // ===== perhitungan penarikan (biaya layanan + pajak)
    final requested = amount;        // nominal yang dipilih seller
    final fee = adminFee ?? 0;       // biaya layanan penarikan
    final wTax = tax ?? 0;           // pajak penarikan

    int receivedCalc = received ?? (requested - fee - wTax);
    if (receivedCalc < 0) receivedCalc = 0;
    if (receivedCalc > requested) receivedCalc = requested;
    final int totalReceived = receivedCalc;

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
                  'Detail Transaksi',
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
          // Angka besar:
          // - Pemasukan  : +total pemasukan
          // - Penarikan  : -requested (bukan bersih)
          Center(
            child: Text(
              '$sign${_rp(amount)}',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _date(createdAt),
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                color: const Color(0xFF9AA0A6),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Keterangan pihak terkait
          _sectionTitle(isIncome ? 'Diterima Dari' : 'Rekening Tujuan'),
          const SizedBox(height: 8),
          _grayCard(
            child: Text(
              counterpartyName,
              style: GoogleFonts.dmSans(fontSize: 14.5, color: const Color(0xFF232323)),
            ),
          ),

          // Rincian pesanan (hanya income & ada item)
          if (isIncome && list.isNotEmpty) ...[
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
                          child: Text(
                            list[i].name,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: const Color(0xFF232323),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('x ${list[i].qty}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.2,
                                  color: const Color(0xFF5B5F62),
                                )),
                            const SizedBox(height: 4),
                            Text(_rp(list[i].price),
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.5,
                                  color: const Color(0xFF232323),
                                )),
                          ],
                        ),
                      ],
                    ),
                    if (i != list.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],

          // Ringkasan
          const SizedBox(height: 18),
          _sectionTitle(isIncome ? 'Ringkasan Pemasukan' : 'Ringkasan Penarikan Saldo'),
          const SizedBox(height: 8),

          if (isIncome) ...[
            _grayCard(
              child: Column(
                children: [
                  _twoCols('Subtotal', _rp(subtotal), muted: true),
                  const SizedBox(height: 10),
                  _twoCols('Biaya Pengiriman', _rp(shipping < 0 ? 0 : shipping), muted: true),
                  // Tidak menampilkan pajak untuk seller (income)
                ],
              ),
            ),
            const SizedBox(height: 10),
            _grayCard(child: _twoCols('Total Pemasukan', _rp(amount), bold: true)),
          ] else ...[
            // ===== Rincian penarikan
            _grayCard(
              child: Column(
                children: [
                  _twoCols('Saldo Ditarik', _rp(requested), muted: true),
                  const SizedBox(height: 10),
                  _twoCols('Biaya Layanan', _rp(fee), muted: true), // label diganti
                  if (wTax > 0) ...[
                    const SizedBox(height: 10),
                    _twoCols('Pajak', _rp(wTax), muted: true),       // tampilkan pajak bila ada
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            _grayCard(child: _twoCols('Total Diterima', _rp(totalReceived), bold: true)),

            // Bukti pencairan saldo (opsional)
            if (proofUrl != null && proofUrl!.isNotEmpty) ...[
              const SizedBox(height: 18),
              _sectionTitle('Bukti Pencairan Saldo'),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: InteractiveViewer(
                        child: Image.network(proofUrl!, fit: BoxFit.contain),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEDEFF5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_rounded,
                          size: 18, color: Color(0xFF808080)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          proofName ?? 'bukti_pencairan.jpg',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF232323),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _humanSize(proofBytes),
                        style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF9A9A9A)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF808080)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // helpers UI
  Widget _sectionTitle(String s) => Text(
        s,
        style: GoogleFonts.dmSans(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF373E3C),
        ),
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
