import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ➜ pastikan import ini ada
import 'package:abc_e_mart/seller/features/transaction/transaction_detail_page.dart';

enum OrderStatus { selesai, dibatalkan, dikirim, menunggu }

class DetailOrderPage extends StatefulWidget {
  final String orderId;
  const DetailOrderPage({super.key, required this.orderId});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  bool _showFullAddress = false;

  @override
  Widget build(BuildContext context) {
    final orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: orderStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || !snap.data!.exists) {
              return Center(child: Text('Pesanan tidak ditemukan', style: GoogleFonts.dmSans()));
            }

            final data = snap.data!.data()!;
            final orderDocId = snap.data!.id; // ID asli dokumen
            final invoiceId = (data['invoiceId'] as String?)?.trim();
            final displayedId = (invoiceId != null && invoiceId.isNotEmpty) ? invoiceId : orderDocId;

            final statusStr = ((data['status'] ?? data['shippingAddress']?['status'] ?? 'PLACED') as String).toUpperCase();
            final orderStatus = _statusFrom(statusStr);

            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

            // buyer info
            final buyerId = (data['buyerId'] ?? '') as String;

            // alamat kirim
            final ship = (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
            final addressLabel = (ship['label'] ?? '-') as String;
            final addressText = (ship['address'] ?? '-') as String;
            final shippingAddress = '$addressLabel, $addressText';

            // items
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

            // amounts (dukung typo lama 'mounts')
            final amounts = (data['amounts'] ?? data['mounts'] ?? <String, dynamic>{}) as Map<String, dynamic>;
            final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
            final shippingFee = ((amounts['shipping'] as num?) ?? 0).toInt();
            final taxFee = ((amounts['tax'] as num?) ?? 0).toInt();
            final totalFee = ((amounts['total'] as num?) ?? (subtotal + shippingFee + taxFee)).toInt();

            // payment
            final method = ((data['payment']?['method'] ?? 'abc_payment') as String).toUpperCase();
            final methodText = method == 'ABC_PAYMENT' ? 'ABC Payment' : method;

            final addressThreshold = 60;
            final isLongAddress = shippingAddress.length > addressThreshold;

            // ➜ PERMINTAANMU: nota tetap bisa dilihat meskipun dibatalkan
            final showNota = true;

            // stream nama buyer
            final userStream = buyerId.isEmpty
                ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
                : FirebaseFirestore.instance.collection('users').doc(buyerId).snapshots();

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userStream,
              builder: (context, userSnap) {
                final buyerName = (userSnap.data?.data()?['name'] ?? 'Pembeli') as String;

                return CustomScrollView(
                  slivers: [
                    // Sticky Header
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyHeaderDelegate(
                        minHeight: 66,
                        maxHeight: 66,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 6),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2056D3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text('Detail Pesanan',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF232323))),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Header: nama pembeli + status + invoice/order id yang ditampilkan
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Username Pembeli',
                                      style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold, fontSize: 17, color: const Color(0xFF232323))),
                                  const SizedBox(height: 2),
                                  Text(buyerName,
                                      style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold, fontSize: 15.5, color: Colors.black)),
                                  const SizedBox(height: 2),
                                  // ➜ tampilkan invoiceId jika ada, fallback doc.id
                                  Text('#$displayedId',
                                      style: GoogleFonts.dmSans(fontSize: 12.5, color: const Color(0xFF888888))),
                                ],
                              ),
                            ),
                            _statusBadge(orderStatus),
                          ],
                        ),
                      ),
                    ),

                    _buildSeparator(),

                    // Tanggal & Waktu
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal & Waktu',
                                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(createdAt != null ? _fmtDateTime(createdAt) : '-',
                                style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF828282))),
                          ],
                        ),
                      ),
                    ),

                    // Alamat pengiriman
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Pengiriman',
                                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Builder(builder: (context) {
                              final textStyle =
                                  GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF232323));
                              if (isLongAddress && !_showFullAddress) {
                                final displayText = shippingAddress.substring(0, addressThreshold) + '... ';
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text.rich(
                                        TextSpan(
                                          text: displayText,
                                          style: textStyle,
                                          children: [
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: GestureDetector(
                                                onTap: () => setState(() => _showFullAddress = true),
                                                child: Text('Lihat Selengkapnya',
                                                    style: GoogleFonts.dmSans(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF2056D3))),
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(shippingAddress, style: textStyle),
                                    if (isLongAddress && _showFullAddress)
                                      GestureDetector(
                                        onTap: () => setState(() => _showFullAddress = false),
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 1),
                                          child: Text('Tutup',
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF2056D3))),
                                        ),
                                      ),
                                  ],
                                );
                              }
                            }),
                          ],
                        ),
                      ),
                    ),

                    _buildSeparator(),

                    // Produk list
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: items.map((it) {
                            final img = (it['imageUrl'] ?? it['image']) as String?;
                            final name = (it['name'] ?? '-') as String;
                            final note = (it['variant'] ?? it['note'] ?? '') as String;
                            final price = ((it['price'] as num?) ?? 0).toInt();
                            final qty = ((it['qty'] as num?) ?? 0).toInt();
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: img != null && img.isNotEmpty
                                        ? Image.network(
                                            img,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _imgPh(),
                                          )
                                        : _imgPh(),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.bold, fontSize: 14.7)),
                                        if (note.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.5),
                                            child: Text(note,
                                                style: GoogleFonts.dmSans(
                                                    fontSize: 12.5, color: const Color(0xFF888888))),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text('Rp ${_rupiah(price)}',
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 13.5, color: const Color(0xFF232323))),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 9, top: 3),
                                    child: Text('x$qty',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13.5, color: const Color(0xFF444444))),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    _buildSeparator(vertical: 18),

                    // Nota & metode pembayaran — SELALU tampil
                    if (showNota)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 11),
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Nota Pesanan',
                                        style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.3,
                                            color: const Color(0xFF222222))),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        final txMap = _mapOrderToTransaction(
                                          displayedId: displayedId, // invoice tampilan
                                          orderDocId: orderDocId,    // id asli doc
                                          data: data,
                                          buyerName: buyerName,
                                        );
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => TransactionDetailPage(transaction: txMap),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 20),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: Row(
                                        children: [
                                          Text('Lihat',
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 13.5, color: const Color(0xFF2056D3))),
                                          const Icon(Icons.receipt_long_rounded,
                                              color: Color(0xFF2056D3), size: 17),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Metode Pembayaran',
                                        style: GoogleFonts.dmSans(fontSize: 13, color: Color(0xFF828282))),
                                    const Spacer(),
                                    Text(methodText,
                                        style: GoogleFonts.dmSans(fontSize: 13.2, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Image.asset('assets/images/paymentlogo.png',
                                        height: 18, fit: BoxFit.contain),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Ringkasan biaya
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFeeRow('Subtotal', subtotal, bold: true),
                                  const SizedBox(height: 3),
                                  _buildFeeRow('Biaya Pengiriman', shippingFee, bold: true),
                                  const SizedBox(height: 3),
                                  _buildFeeRow('Pajak & Biaya Lainnya', taxFee, bold: true),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                              child: Row(
                                children: [
                                  Text('Total',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 16.3, fontWeight: FontWeight.bold, color: const Color(0xFF232323))),
                                  const Spacer(),
                                  Text('Rp ${_rupiah(totalFee)}',
                                      style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold, fontSize: 16.5, color: const Color(0xFF232323))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------- mapper to TransactionDetailPage ----------
  Map<String, dynamic> _mapOrderToTransaction({
    required String displayedId,   // invoice tampilan → gunakan invoiceId kalau ada
    required String orderDocId,    // id asli dokumen (opsional, buat keperluan internal)
    required Map<String, dynamic> data,
    required String buyerName,
  }) {
    final rawStatus = ((data['status'] ?? data['shippingAddress']?['status'] ?? 'PLACED') as String).toUpperCase();

    // label untuk UI TransactionDetailPage
    String uiStatus;
    if (rawStatus == 'COMPLETED' || rawStatus == 'DELIVERED' || rawStatus == 'SUCCESS' || rawStatus == 'SETTLED') {
      uiStatus = 'Sukses';
    } else if (rawStatus == 'CANCELLED' || rawStatus == 'CANCELED' || rawStatus == 'REJECTED' || rawStatus == 'FAILED') {
      uiStatus = 'Gagal';
    } else {
      uiStatus = 'Tertahan'; // PLACED / ACCEPTED / SHIPPED
    }

    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
    final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
    final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
    final tax = ((amounts['tax'] as num?) ?? 0).toInt();
    final total = ((amounts['total'] as num?) ?? (subtotal + shipping + tax)).toInt();

    final createdAt = (data['createdAt'] is Timestamp)
        ? (data['createdAt'] as Timestamp).toDate()
        : null;

    final ship = (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
    final addressLabel = (ship['label'] ?? '-') as String;
    final addressText = (ship['addressText'] ?? ship['address'] ?? '-') as String;
    final phone = (ship['phone'] ?? '-') as String;

    final method = ((data['payment']?['method'] ?? 'abc_payment') as String).toUpperCase();

    return {
      'invoiceId': displayedId,  // ➜ ini yang ditampilkan
      'orderDocId': orderDocId,  // ➜ kalau TransactionDetailPage ingin tahu id dokumen asli
      'status': uiStatus,
      'date': createdAt,
      'buyerName': buyerName,
      'shipping': {
        'recipient': buyerName,
        'addressLabel': addressLabel,
        'addressText': addressText,
        'phone': phone,
      },
      'paymentMethod': method,
      'items': items.map((it) {
        return {
          'name': (it['name'] ?? '-') as String,
          'qty': ((it['qty'] as num?) ?? 0).toInt(),
          'price': ((it['price'] as num?) ?? 0).toInt(),
          'variant': (it['variant'] ?? it['note'] ?? '') as String,
        };
      }).toList(),
      'amounts': {
        'subtotal': subtotal,
        'shipping': shipping,
        'tax': tax,
        'total': total,
      },
    };
  }

  // ---------- helpers ----------
  static OrderStatus _statusFrom(String s) {
    switch (s) {
      case 'COMPLETED':
      case 'SUCCESS':
        return OrderStatus.selesai;
      case 'DELIVERED':
      case 'SHIPPED':
        return OrderStatus.dikirim;
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return OrderStatus.dibatalkan;
      default:
        return OrderStatus.menunggu;
    }
  }

  static String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y, $h12:$min $ampm';
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

  SliverToBoxAdapter _buildSeparator({double vertical = 0}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: vertical),
        child: const Divider(thickness: 1, color: Color(0xFFE6E6E6)),
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    String text;
    Color color;
    switch (status) {
      case OrderStatus.selesai:
        text = 'Selesai';
        color = const Color(0xFF24B47E);
        break;
      case OrderStatus.dibatalkan:
        text = 'Dibatalkan';
        color = const Color(0xFFFF3449);
        break;
      case OrderStatus.dikirim:
        text = 'Dikirim';
        color = const Color(0xFF2056D3);
        break;
      case OrderStatus.menunggu:
      default:
        text = 'Menunggu';
        color = const Color(0xFF828282);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: color, fontSize: 13.2)),
        ],
      ),
    );
  }

  Widget _imgPh() => Container(
        width: 56,
        height: 56,
        color: Colors.grey[200],
        child: const Icon(Icons.fastfood_rounded, size: 34, color: Colors.grey),
      );

  Widget _buildFeeRow(String title, int amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(title,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: const Color(0xFF888888), fontWeight: bold ? FontWeight.w500 : FontWeight.normal)),
          const Spacer(),
          Text('Rp ${_rupiah(amount)}',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14.5, color: const Color(0xFF222222))),
        ],
      ),
    );
  }
}

// Sticky header delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
