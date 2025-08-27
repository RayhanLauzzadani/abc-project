import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Firestore (untuk opsi orderId langsung)
import 'package:cloud_firestore/cloud_firestore.dart';

// PDF
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class TransactionDetailPage extends StatelessWidget {
  /// Pakai salah satu:
  /// - [transaction] = map siap pakai, ATAU
  /// - [orderId] = biar halaman ini fetch & rakit semua data sendiri.
  final Map<String, dynamic>? transaction;
  final String? orderId;

  const TransactionDetailPage({
    Key? key,
    this.transaction,
    this.orderId,
  })  : assert(transaction != null || orderId != null,
            'Harus isi transaction atau orderId'),
        super(key: key);

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final Future<Map<String, dynamic>> futureTx = orderId != null
        ? _loadTxFromOrderId(orderId!)
        : Future.value(_normalizeTransaction(transaction!));

    return FutureBuilder<Map<String, dynamic>>(
      future: futureTx,
      builder: (context, snap) {
        if (!snap.hasData) {
          if (snap.hasError) {
            return Scaffold(
              appBar: _appbar(context),
              body: Center(
                child: Text('Gagal memuat transaksi:\n${snap.error}',
                    textAlign: TextAlign.center, style: GoogleFonts.dmSans()),
              ),
            );
          }
          return Scaffold(
            appBar: _appbar(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final tx = snap.data!;

        // ===== ambil data dari tx (SUDAH dinormalisasi) =====
        final String invoiceId = tx['invoiceId']?.toString() ?? 'No ID';
        final String status = tx['status']?.toString() ?? 'Unknown';

        final DateTime? txDate = (tx['date'] is DateTime) ? tx['date'] as DateTime : null;

        final Map<String, dynamic> amounts =
            (tx['amounts'] as Map?)?.cast<String, dynamic>() ?? {};
        final int subtotal = (amounts['subtotal'] as num?)?.toInt() ?? 0;
        final int shippingFee = (amounts['shipping'] as num?)?.toInt() ?? 0;
        final int tax = (amounts['tax'] as num?)?.toInt() ?? 0;
        final int total =
            (amounts['total'] as num?)?.toInt() ?? (subtotal + shippingFee + tax);

        final String paymentMethod =
            (tx['paymentMethod']?.toString() ?? 'ABC_PAYMENT').toUpperCase();

        final Map<String, dynamic> shipping =
            (tx['shipping'] as Map?)?.cast<String, dynamic>() ?? {};
        final String buyerName = tx['buyerName']?.toString() ??
            (tx['buyer']?['name']?.toString() ?? '-');
        final String shipRecipient = shipping['recipient']?.toString() ?? buyerName;
        final String shipAddressText = shipping['addressText']?.toString() ?? '-';
        final String shipPhone = shipping['phone']?.toString() ?? '-';

        final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
          tx['items'] ?? const [],
        );

        return Scaffold(
          appBar: _appbar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Header 2-row =====
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Invoice + Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Invoice ID : $invoiceId',
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF373E3C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          fit: FlexFit.loose,
                          child: _StatusBubble(
                            status: status,
                            color: _statusColor(status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row 2: desc + Unduh
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Klik tombol untuk mengunduh salinan invoice dalam format PDF.',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF373E3C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => _generateAndSharePdf(context, tx),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFAFAFA),
                            side: const BorderSide(
                              color: Color(0xFFD5D7DA),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
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
                  ],
                ),

                const SizedBox(height: 24),

                // ===== Total & Tanggal =====
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Pembayaran',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: const Color(0xFF373E3C))),
                          const SizedBox(height: 4),
                          Text('Rp ${_rupiah(total)}',
                              style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF373E3C))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Transaksi',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: const Color(0xFF373E3C))),
                          const SizedBox(height: 4),
                          Text(txDate != null ? _fmtDate(txDate) : '-',
                              style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF373E3C))),
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
                          Text('Rincian Pengiriman',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: const Color(0xFF373E3C))),
                          const SizedBox(height: 4),
                          Text('$shipRecipient\n$shipAddressText\n$shipPhone',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: const Color(0xFF9A9A9A))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Metode Pembayaran
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Metode Pembayaran',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: const Color(0xFF373E3C))),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/paymentlogo.png',
                                  width: 40, height: 40, fit: BoxFit.contain),
                              const SizedBox(width: 6),
                              Text(
                                paymentMethod == 'ABC_PAYMENT'
                                    ? 'ABC Payment'
                                    : paymentMethod,
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
                Text('Rincian Pesanan',
                    style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C))),
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
                Text('Ringkasan Pembayaran',
                    style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C))),
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
      },
    );
  }

  PreferredSizeWidget _appbar(BuildContext context) {
    return PreferredSize(
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
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Text('Detail Transaksi',
                style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C))),
          ],
        ),
      ),
    );
  }

  // ---------- FETCH & NORMALIZE (inline, tanpa helper terpisah) ----------

  Future<Map<String, dynamic>> _loadTxFromOrderId(String orderId) async {
    final fs = FirebaseFirestore.instance;
    final orderSnap = await fs.collection('orders').doc(orderId).get();
    if (!orderSnap.exists) {
      throw Exception('Order $orderId tidak ditemukan');
    }
    final order = Map<String, dynamic>.from(orderSnap.data()!);

    // buyer & store
    final buyerId = (order['buyerId'] ?? '') as String;
    final storeId = (order['storeId'] ?? order['sellerStoreId'] ?? '') as String;

    Map<String, dynamic>? buyer;
    Map<String, dynamic>? store;

    if (buyerId.isNotEmpty) {
      final b = await fs.collection('users').doc(buyerId).get();
      buyer = b.data();
    }
    if (storeId.isNotEmpty) {
      final s = await fs.collection('stores').doc(storeId).get();
      store = s.data();
    }

    // Rakitan final (mirip mapper), lengkap & dinormalisasi:
    return _normalizeTransaction({
      'orderId': orderSnap.id,
      'invoiceId': (order['invoiceId'] as String?)?.trim(),
      'statusRaw': ((order['status'] ??
                  order['shippingAddress']?['status'] ??
                  'PLACED') as String)
              .toUpperCase() ??
          'PLACED',
      'status': _uiStatus(((order['status'] ??
                      order['shippingAddress']?['status'] ??
                      'PLACED') as String)
                  .toUpperCase()),
      'date': (order['createdAt'] is Timestamp)
          ? (order['createdAt'] as Timestamp).toDate()
          : null,
      'updatedAt': (order['updatedAt'] is Timestamp)
          ? (order['updatedAt'] as Timestamp).toDate()
          : null,
      'store': {
        'id': storeId,
        'name': (order['storeName'] ?? store?['name'] ?? '-') as String,
        'phone': (store?['phone'] ?? '-') as String,
        'address': (store?['address'] ?? '-') as String,
        'logoUrl': (store?['logoUrl'] ?? '') as String,
      },
      'storeName': (order['storeName'] ?? store?['name'] ?? '-') as String,
      'buyer': {
        'id': buyerId,
        'name': (buyer?['name'] ?? order['buyerName'] ?? 'Pembeli') as String,
        'phone': (buyer?['phone'] ?? '-') as String,
      },
      'buyerName':
          (buyer?['name'] ?? order['buyerName'] ?? 'Pembeli') as String,
      'shipping': {
        'recipient':
            (buyer?['name'] ?? order['buyerName'] ?? 'Pembeli') as String,
        'addressLabel':
            ((order['shippingAddress']?['label']) ?? '-') as String,
        'addressText': ((order['shippingAddress']?['addressText']) ??
                (order['shippingAddress']?['address']) ??
                '-') as String,
        'phone': ((order['shippingAddress']?['phone']) ??
                (buyer?['phone']) ??
                '-') as String,
      },
      'payment': (order['payment'] as Map<String, dynamic>?) ?? {},
      'paymentMethod':
          ((order['payment']?['method'] ?? order['paymentMethod'] ?? 'ABC_PAYMENT') as String)
              .toUpperCase(),
      'items': order['items'] ?? const [],
      'amounts': (order['amounts'] ?? order['mounts'] ?? <String, dynamic>{}),
    });
  }

  Map<String, dynamic> _normalizeTransaction(Map<String, dynamic> raw) {
    // invoice fallback → orderId
    final inv = (raw['invoiceId'] as String?)?.trim();
    final invoiceId = (inv != null && inv.isNotEmpty) ? inv : (raw['orderId']?.toString() ?? '-');

    // status UI fallback
    final uiStatus = raw['status'] ??
        _uiStatus(((raw['statusRaw'] ?? 'PLACED') as String).toUpperCase());

    // items → list<map>
    final items = _normalizeItems(raw['items']);

    // amounts + fallback hitung subtotal
    final amounts =
        (raw['amounts'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final subtotal =
        ((amounts['subtotal'] as num?) ?? _calcSubtotal(items)).toInt();
    final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
    final tax = ((amounts['tax'] as num?) ?? 0).toInt();
    final total =
        ((amounts['total'] as num?) ?? (subtotal + shipping + tax)).toInt();

    // payment method
    final method = ((raw['paymentMethod'] ??
                (raw['payment'] is Map ? (raw['payment']['method']) : null) ??
                'ABC_PAYMENT') as String)
            .toUpperCase();

    // shipping map minimal
    final ship = (raw['shipping'] as Map?)?.cast<String, dynamic>() ?? {};
    final buyerName = raw['buyerName']?.toString() ??
        (raw['buyer']?['name']?.toString() ?? 'Pembeli');
    final shippingNorm = {
      'recipient': ship['recipient']?.toString() ?? buyerName,
      'addressLabel': ship['addressLabel']?.toString() ?? '-',
      'addressText': (ship['addressText'] ??
              ship['address'] ??
              '-') // kompat lama
          .toString(),
      'phone': ship['phone']?.toString() ??
          (raw['buyer']?['phone']?.toString() ?? '-'),
    };

    // store & buyer blocks aman
    final store = (raw['store'] as Map?)?.cast<String, dynamic>() ?? {};
    final buyer = (raw['buyer'] as Map?)?.cast<String, dynamic>() ?? {};

    return {
      ...raw,
      'invoiceId': invoiceId,
      'status': uiStatus,
      'items': items,
      'amounts': {
        'subtotal': subtotal,
        'shipping': shipping,
        'tax': tax,
        'total': total,
      },
      'paymentMethod': method,
      'shipping': shippingNorm,
      'store': {
        'id': store['id']?.toString() ?? '',
        'name': (raw['storeName'] ?? store['name'] ?? '-').toString(),
        'phone': store['phone']?.toString() ?? '-',
        'address': store['address']?.toString() ?? '-',
        'logoUrl': store['logoUrl']?.toString() ?? '',
      },
      'buyer': {
        'id': buyer['id']?.toString() ?? '',
        'name': buyer['name']?.toString() ?? buyerName,
        'phone': buyer['phone']?.toString() ?? '-',
      },
      'buyerName': buyerName,
    };
  }

  List<Map<String, dynamic>> _normalizeItems(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map<Map<String, dynamic>>((e) {
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        m['name'] = (m['name'] ?? '-').toString();
        m['qty'] = ((m['qty'] as num?) ?? 0).toInt();
        m['price'] = ((m['price'] as num?) ?? 0).toInt();
        m['variant'] = (m['variant'] ?? m['note'] ?? '').toString();
        m['note'] = (m['note'] ?? m['variant'] ?? '').toString();
        m['imageUrl'] = (m['imageUrl'] ?? m['image'] ?? '').toString();
        m['productId'] = (m['productId'] ?? m['id'] ?? '').toString();
        return m;
      }
      // object (mis. TransactionCardItem)
      try {
        final d = e as dynamic;
        return {
          'name': (d.name ?? '-').toString(),
          'qty': (d.qty is num) ? (d.qty as num).toInt() : 0,
          'price': (d.price is num) ? (d.price as num).toInt() : 0,
          'variant': (d.variant ?? d.note ?? '').toString(),
          'note': (d.note ?? d.variant ?? '').toString(),
          'imageUrl': (d.imageUrl ?? d.image ?? '').toString(),
          'productId': (d.productId ?? d.id ?? '').toString(),
        };
      } catch (_) {
        return {
          'name': e.toString(),
          'qty': 0,
          'price': 0,
          'variant': '',
          'note': '',
          'imageUrl': '',
          'productId': '',
        };
      }
    }).toList();
  }

  // ---------- PDF ----------
  Future<void> _generateAndSharePdf(
      BuildContext context, Map<String, dynamic> tx) async {
    // tx sudah dinormalisasi
    final invoiceId = tx['invoiceId']?.toString() ?? 'No ID';
    final status = (tx['status'] ?? 'Unknown').toString();

    // toko
    final store = (tx['store'] as Map?)?.cast<String, dynamic>() ?? {};
    final storeName = (tx['storeName'] ?? store['name'] ?? '-').toString();
    final storePhone = (store['phone'] ?? '-').toString();
    final storeAddress = (store['address'] ?? '-').toString();

    // pembeli & shipping
    final buyer = (tx['buyer'] as Map?)?.cast<String, dynamic>() ?? {};
    final shipping = (tx['shipping'] as Map?)?.cast<String, dynamic>() ?? {};
    final buyerName =
        (tx['buyerName'] ?? buyer['name'] ?? '-').toString();
    final buyerPhone =
        (buyer['phone'] ?? shipping['phone'] ?? '-').toString();
    final buyerAddress =
        (tx['buyerAddress'] ?? shipping['addressText'] ?? shipping['address'] ?? '-')
            .toString();

    // metode
    final paymentMethod = (tx['paymentMethod'] ?? 'ABC_PAYMENT').toString();

    // items & amounts
    final List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from(tx['items'] ?? const []);
    final amounts = (tx['amounts'] as Map<String, dynamic>?) ?? {};
    final subtotal =
        (amounts['subtotal'] as num?)?.toInt() ?? _calcSubtotal(items);
    final shippingFee = (amounts['shipping'] as num?)?.toInt() ?? 0;
    final tax = (amounts['tax'] as num?)?.toInt() ?? 0;
    final total =
        (amounts['total'] as num?)?.toInt() ?? (subtotal + shippingFee + tax);

    final doc = pw.Document();
    final hStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
    final bStyle = const pw.TextStyle(fontSize: 10);

    doc.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Detail Transaksi',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Invoice ID: $invoiceId', style: bStyle),
              pw.SizedBox(height: 2),
              pw.Row(children: [
                pw.Text('Status: ', style: bStyle),
                pw.Text(status,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: _pdfStatusColor(status))),
                pw.SizedBox(width: 10),
                pw.Text('Metode: ${paymentMethod.toUpperCase()}', style: bStyle),
              ]),
              pw.SizedBox(height: 14),

              // seller + buyer
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
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

              // tabel items
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1.2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
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

              // ringkasan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColors.grey300, width: 0.5),
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
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFFF3F3F3),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text('Total',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(width: 14),
                              pw.Text('Rp ${_rupiah(total)}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
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

  // ---------- kecil-kecil ----------
  static String _uiStatus(String raw) {
    if (raw == 'COMPLETED' ||
        raw == 'DELIVERED' ||
        raw == 'SUCCESS' ||
        raw == 'SETTLED') return 'Sukses';
    if (raw == 'CANCELLED' ||
        raw == 'CANCELED' ||
        raw == 'REJECTED' ||
        raw == 'FAILED') return 'Gagal';
    return 'Tertahan';
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

  // PDF helpers
  static pw.Widget _kv(String k, String v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: '$k: ',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
          pw.TextSpan(text: v, style: const pw.TextStyle(fontSize: 10)),
        ]),
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
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  // UI helpers
  Widget _divider() =>
      Container(height: 1, width: double.infinity, color: const Color(0xFFF2F2F3));

  Widget _productRow(String name, String price, String qty) {
    return Row(
      children: [
        Expanded(
          child: Text(name,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: const Color(0xFF373E3C))),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(qty,
                style: GoogleFonts.dmSans(
                    fontSize: 14, color: const Color(0xFF373E3C))),
            Text(price,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C))),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 14, color: const Color(0xFF9A9A9A))),
        Text(amount,
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C))),
      ],
    );
  }

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

// ===== Bubble label =====
class _StatusBubble extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBubble({Key? key, required this.status, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = color.withAlpha(33);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(status,
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600, fontSize: 10, color: color)),
    );
  }
}
