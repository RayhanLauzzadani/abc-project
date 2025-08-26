import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// PDF
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ===== ambil data dari map =====
    final String invoiceId = transaction['invoiceId']?.toString() ?? 'No ID';
    final String status = transaction['status']?.toString() ?? 'Unknown';

    final DateTime? txDate = (() {
      final v = transaction['date'];
      if (v is DateTime) return v;
      return null;
    })();

    final Map<String, dynamic> amounts =
        (transaction['amounts'] as Map?)?.cast<String, dynamic>() ?? {};
    final int subtotal = (amounts['subtotal'] as num?)?.toInt() ?? 0;
    final int shippingFee = (amounts['shipping'] as num?)?.toInt() ?? 0;
    final int tax = (amounts['tax'] as num?)?.toInt() ?? 0;
    final int total =
        (amounts['total'] as num?)?.toInt() ?? (subtotal + shippingFee + tax);

    final String paymentMethod =
        (transaction['paymentMethod']?.toString() ?? 'ABC_PAYMENT').toUpperCase();

    final Map<String, dynamic> shipping =
        (transaction['shipping'] as Map?)?.cast<String, dynamic>() ?? {};
    final String buyerName = transaction['buyerName']?.toString() ?? '-';
    final String shipRecipient = shipping['recipient']?.toString() ?? buyerName;
    final String shipAddressText = shipping['addressText']?.toString() ?? '-';
    final String shipPhone = shipping['phone']?.toString() ?? '-';

    final List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from(transaction['items'] ?? const []);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.only(left: 20, top: 40, bottom: 10),
          color: Colors.white,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 37,
                  height: 37,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1C55C0),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Detail Transaksi',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Baris: (Kiri) Invoice + teks | (Kanan) Status + Unduh =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KIRI
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice ID : $invoiceId',
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Klik tombol untuk mengunduh salinan invoice dalam format PDF.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // KANAN
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusBubble(status: status, color: _statusColor(status)),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => _generateAndSharePdf(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFAFAFA),
                            side: const BorderSide(color: Color(0xFFD5D7DA), width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: const Color(0xFF373E3C),
                            textStyle: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          child: const Text('Unduh'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ===== Total Pembayaran & Tanggal Transaksi =====
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${_rupiah(total)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Transaksi',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        txDate != null ? _fmtDate(txDate) : '-',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 24),

            // ===== Rincian Pengiriman & Metode Pembayaran =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rincian Pengiriman
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian Pengiriman',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$shipRecipient\n$shipAddressText\n$shipPhone',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Metode Pembayaran
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metode Pembayaran',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/paymentlogo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            paymentMethod == 'ABC_PAYMENT' ? 'ABC Payment' : paymentMethod,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF373E3C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 24),

            // ===== Rincian Pesanan =====
            Text(
              'Rincian Pesanan',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map((it) {
                  final name = (it['name'] ?? '-') as String;
                  final qty = ((it['qty'] as num?) ?? 0).toInt();
                  final price = ((it['price'] as num?) ?? 0).toInt();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: _productRow(name, 'Rp ${_rupiah(price)}', 'x$qty'),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),
            _divider(),
            const SizedBox(height: 16),

            // ===== Ringkasan Pembayaran =====
            Text(
              'Ringkasan Pembayaran',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 8),
            _summaryRow('Subtotal', 'Rp ${_rupiah(subtotal)}'),
            const SizedBox(height: 7),
            _summaryRow('Biaya Pengiriman', 'Rp ${_rupiah(shippingFee)}'),
            const SizedBox(height: 7),
            _summaryRow('Pajak & Biaya Lainnya', 'Rp ${_rupiah(tax)}'),
            const SizedBox(height: 7),
            _summaryRow('Total Pembayaran', 'Rp ${_rupiah(total)}'),
          ],
        ),
      ),
    );
  }

  // ===== PDF =====
  Future<void> _generateAndSharePdf(BuildContext context) async {
    // ------- ambil data fleksibel dari map -------
    final invoiceId = transaction['invoiceId']?.toString() ?? 'No ID';
    final status = (transaction['status'] ?? 'Unknown').toString();

    // info toko / penjual
    final Map<String, dynamic> storeMap =
        (transaction['store'] as Map?)?.cast<String, dynamic>() ??
            (transaction['seller'] as Map?)?.cast<String, dynamic>() ??
            {};
    final String storeName =
        transaction['storeName']?.toString() ??
            storeMap['name']?.toString() ??
            '-';
    final String storePhone =
        transaction['storePhone']?.toString() ??
            storeMap['phone']?.toString() ??
            '-';
    final String storeAddress =
        transaction['storeAddress']?.toString() ??
            storeMap['address']?.toString() ??
            '-';

    // info pembeli
    final Map<String, dynamic> buyerMap =
        (transaction['buyer'] as Map?)?.cast<String, dynamic>() ??
            (transaction['customer'] as Map?)?.cast<String, dynamic>() ??
            {};
    final Map<String, dynamic> shipping =
        (transaction['shipping'] as Map?)?.cast<String, dynamic>() ?? {};

    final String buyerName =
        transaction['buyerName']?.toString() ??
            buyerMap['name']?.toString() ??
            '-';
    final String buyerPhone =
        transaction['buyerPhone']?.toString() ??
            buyerMap['phone']?.toString() ??
            shipping['phone']?.toString() ??
            '-';
    final String buyerAddress =
        transaction['buyerAddress']?.toString() ??
            shipping['addressText']?.toString() ??
            shipping['address']?.toString() ?? // fallback lama
            '-';

    // metode pembayaran (opsional)
    final paymentMethod = (transaction['payment'] is Map &&
        (transaction['payment'] as Map)['method'] != null)
        ? (transaction['payment'] as Map)['method'].toString()
        : (transaction['paymentMethod']?.toString() ?? 'ABC_PAYMENT');

    // items & amounts
    final List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from(transaction['items'] ?? const []);
    final amounts = (transaction['amounts'] as Map<String, dynamic>?) ?? {};
    final subtotal = (amounts['subtotal'] as num?)?.toInt() ?? _calcSubtotal(items);
    final shippingFee = (amounts['shipping'] as num?)?.toInt() ?? 0;
    final tax = (amounts['tax'] as num?)?.toInt() ?? 0;
    final total = (amounts['total'] as num?)?.toInt() ?? (subtotal + shippingFee + tax);

    final doc = pw.Document();

    final hStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
    final bStyle = const pw.TextStyle(fontSize: 10);

    doc.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title + invoice + status
              pw.Text('Detail Transaksi',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Invoice ID: $invoiceId', style: bStyle),
              pw.SizedBox(height: 2),
              pw.Row(
                children: [
                  pw.Text('Status: ', style: bStyle),
                  pw.Text(status,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: _pdfStatusColor(status),
                      )),
                  pw.SizedBox(width: 10),
                  pw.Text('Metode: ${paymentMethod.toUpperCase()}', style: bStyle),
                ],
              ),

              pw.SizedBox(height: 14),

              // Seller & Buyer block
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Seller
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Penjual (Toko)', style: hStyle),
                          pw.SizedBox(height: 6),
                          _kv('Nama Toko', storeName),
                          _kv('Telepon', storePhone),
                          _kv('Alamat', storeAddress),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    // Buyer
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Pembeli', style: hStyle),
                          pw.SizedBox(height: 6),
                          _kv('Nama', buyerName),
                          _kv('Telepon', buyerPhone),
                          _kv('Alamat', buyerAddress),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // Tabel Items
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1.2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF5F5F5),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Nama Item', style: hStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Qty', style: hStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Harga', style: hStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Subtotal', style: hStyle),
                      ),
                    ],
                  ),
                  // Data rows
                  ...items.map((it) {
                    final name = (it['name'] ?? '-') as String;
                    final qty = ((it['qty'] as num?) ?? 0).toInt();
                    final price = ((it['price'] as num?) ?? 0).toInt();
                    final sub = qty * price;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(name, style: bStyle),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('$qty', style: bStyle),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Rp ${_rupiah(price)}', style: bStyle),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Rp ${_rupiah(sub)}', style: bStyle),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 16),

              // Ringkasan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfSummaryRow('Subtotal', subtotal),
                        _pdfSummaryRow('Biaya Pengiriman', shippingFee),
                        _pdfSummaryRow('Pajak & Biaya Lainnya', tax),
                        pw.SizedBox(height: 6),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFFF3F3F3),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(width: 14),
                              pw.Text('Rp ${_rupiah(total)}',
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  // key-value row untuk blok toko/pembeli
  static pw.Widget _kv(String k, String v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$k: ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
            pw.TextSpan(text: v, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _pdfSummaryRow(String label, int amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(width: 10),
          pw.Text('Rp ${_rupiah(amount)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  // ===== UI helpers =====
  Widget _divider() => Container(
        height: 1,
        width: double.infinity,
        color: const Color(0xFFF2F2F3),
      );

  Widget _productRow(String name, String price, String qty) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF373E3C),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              qty,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF373E3C),
              ),
            ),
            Text(
              price,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF9A9A9A),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF373E3C),
          ),
        ),
      ],
    );
  }

  // ===== Mappers & formatters =====
  static Color _statusColor(String status) {
    switch (status) {
      case 'Sukses':
        return const Color(0xFF29B057);
      case 'Tertahan':
        return const Color(0xFFFFB800);
      case 'Gagal':
        return const Color(0xFFFF6161);
      default:
        return const Color(0xFFD1D5DB);
    }
  }

  static PdfColor _pdfStatusColor(String status) {
    switch (status) {
      case 'Sukses':
        return PdfColors.green;
      case 'Tertahan':
        return PdfColors.orange;
      case 'Gagal':
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  static int _calcSubtotal(List<Map<String, dynamic>> items) {
    int s = 0;
    for (final it in items) {
      final q = ((it['qty'] as num?) ?? 0).toInt();
      final p = ((it['price'] as num?) ?? 0).toInt();
      s += q * p;
    }
    return s;
  }

  static String _rupiah(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromRight = s.length - i;
      b.write(s[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    return b.toString();
  }

  static String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString().substring(2);
    return '$dd/$mm/$yy';
  }
}

// ===== Bubble label kategori (tanpa titik) =====
class _StatusBubble extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBubble({Key? key, required this.status, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = color.withAlpha(33); // ~13%
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}
