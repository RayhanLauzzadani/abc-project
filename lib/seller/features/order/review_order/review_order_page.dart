import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'order_accepted_popup.dart';
import 'order_delivered_popup.dart';

class ReviewOrderPage extends StatefulWidget {
  final String orderId;
  const ReviewOrderPage({super.key, required this.orderId});

  @override
  State<ReviewOrderPage> createState() => _ReviewOrderPageState();
}

class _ReviewOrderPageState extends State<ReviewOrderPage> {
  bool _showFullAddress = false;

  Future<void> _updateStatus(String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _acceptOrder() async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'asia-southeast2');
      await functions.httpsCallable('acceptOrder').call({'orderId': widget.orderId});
      if (!mounted) return;
      await showDialog(context: context, builder: (_) => const OrderAcceptedPopup());
      if (mounted) setState(() {});
    } on FirebaseFunctionsException catch (e) {
      final msg = e.message ?? 'Gagal menerima pesanan.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerima pesanan: $e')),
      );
    }
  }

  // ❗️UBAH: tolak pesanan harus memanggil cancelOrder agar dana buyer dikembalikan
  Future<void> _rejectOrder() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tolak Pesanan?', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text('Anda yakin ingin menolak pesanan ini?', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5B5B),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Tolak',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        final functions = FirebaseFunctions.instanceFor(region: 'asia-southeast2');
        await functions.httpsCallable('cancelOrder').call({
          'orderId': widget.orderId,
          'reason': 'Seller rejected',
        });
        if (mounted) Navigator.pop(context); // keluar halaman setelah sukses
      } on FirebaseFunctionsException catch (e) {
        final msg = e.message ?? 'Gagal membatalkan pesanan.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan pesanan: $e')),
        );
      }
    }
  }

  Future<void> _shipOrder() async {
    await _updateStatus('SHIPPED'); // aman: tidak menyentuh saldo
    if (!mounted) return;
   await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const OrderDeliveredPopup(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final orderDocStream =
        FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: orderDocStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || !snap.data!.exists) {
              return Center(child: Text('Pesanan tidak ditemukan', style: GoogleFonts.dmSans()));
            }

            final data = snap.data!.data()!;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            final buyerId = (data['buyerId'] ?? '') as String;
            final status = ((data['status'] ?? data['shippingAddress']?['status'] ?? 'PLACED') as String).toUpperCase();
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
            final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
            final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
            final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
            final tax = ((amounts['tax'] as num?) ?? 0).toInt();
            final total = ((amounts['total'] as num?) ?? 0).toInt();
            final shipAddr = (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
            final addressLabel = (shipAddr['label'] ?? '-') as String;
            final addressText = (shipAddr['address'] ?? '-') as String;
            final method = ((data['payment']?['method'] ?? 'abc_payment') as String).toUpperCase();

            // ambil nama buyer (opsional; kalau gagal tetap tampil '-')
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: buyerId.isEmpty
                ? null
                : FirebaseFirestore.instance.collection('users').doc(buyerId).snapshots(),
              builder: (context, userSnap) {
                final buyerName = (userSnap.data?.data()?['name'] ?? '-') as String;

                final isLong = addressText.length > 60;

                return CustomScrollView(
                  slivers: [
                    // Sticky header
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
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2056D3), shape: BoxShape.circle),
                                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text('Tinjau Pesanan',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 17, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // header info
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text('Username Pembeli',
                                style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold, fontSize: 17)),
                            const SizedBox(height: 2),
                            Text(buyerName, style: GoogleFonts.dmSans(fontSize: 15.5, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFFE6E6E6)),
                            const SizedBox(height: 8),
                            Text('Tanggal & Waktu',
                                style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              createdAt != null ? _fmtDateTime(createdAt) : '-',
                              style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF828282)),
                            ),
                            const SizedBox(height: 13),
                            Text('Alamat Pengiriman',
                                style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Builder(builder: (_) {
                              final body = '$addressLabel, $addressText';
                              if (isLong && !_showFullAddress) {
                                final cut = body.substring(0, 60);
                                return Wrap(
                                  children: [
                                    Text('$cut... ',
                                        style: GoogleFonts.dmSans(fontSize: 13.5)),
                                    GestureDetector(
                                      onTap: () => setState(() => _showFullAddress = true),
                                      child: Text('Lihat Selengkapnya',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2056D3))),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(body, style: GoogleFonts.dmSans(fontSize: 13.5)),
                                  if (isLong)
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
                            }),
                            const SizedBox(height: 15),
                            const Divider(color: Color(0xFFE6E6E6)),
                          ],
                        ),
                      ),
                    ),

                    // list item
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: items.map((it) {
                            final img = (it['imageUrl'] ?? it['image']) as String?; // fallback
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.5),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: img != null && img.isNotEmpty
                                        ? Image.network(
                                            img, width: 56, height: 56, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _imgFallback(),
                                          )
                                        : _imgFallback(),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text((it['name'] ?? '-') as String,
                                            style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.bold, fontSize: 14.7)),
                                        if (((it['variant'] ?? it['note'] ?? '') as String).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.5),
                                            child: Text(
                                              (it['variant'] ?? it['note']) as String,
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 12.5, color: const Color(0xFF888888)),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Rp ${_rupiah(((it['price'] as num?) ?? 0).toInt())}',
                                            style: GoogleFonts.dmSans(
                                                fontSize: 13.5, color: const Color(0xFF232323)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 9, top: 3),
                                    child: Text('x${((it['qty'] as num?) ?? 0).toInt()}',
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

                    // Nota & metode pembayaran
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(13, 4, 13, 13),
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
                                        fontSize: 15,
                                        color: const Color(0xFF222222),
                                      )),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {},
                                    child: Row(
                                      children: [
                                        Text('Lihat',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13.5,
                                              color: const Color(0xFF2056D3),
                                            )),
                                        const Icon(Icons.receipt_long_rounded,
                                            color: Color(0xFF2056D3), size: 17),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('Metode Pembayaran',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: const Color(0xFF828282),
                                      )),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Text(
                                        method == 'ABC_PAYMENT' ? 'ABC Payment' : method,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13.2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Image.asset(
                                        'assets/images/paymentlogo.png',
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // subtotal / total
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
                                  _feeRow('Subtotal', subtotal),
                                  const SizedBox(height: 3),
                                  _feeRow('Biaya Pengiriman', shipping),
                                  const SizedBox(height: 3),
                                  _feeRow('Pajak & Biaya Lainnya', tax),
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
                                          fontSize: 16.3, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text('Rp ${_rupiah(total)}',
                                      style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold, fontSize: 16.5)),
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
      bottomNavigationBar: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snap) {
          final st = (snap.data?.data()?['status'] ?? 'PLACED').toString().toUpperCase();
          final showAcceptReject = st == 'PLACED';
          final showShip = st == 'ACCEPTED';

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
            child: Row(
              children: [
                if (showAcceptReject) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _rejectOrder,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF3449),
                        backgroundColor: const Color(0xFFFFE8E8),
                        side: const BorderSide(color: Color(0xFFFF3449), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text('Tolak',
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2056D3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text('Terima',
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ] else if (showShip) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _shipOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2056D3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text('Kirim Pesanan',
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ] else
                  const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- helpers ----------
  static Widget _imgFallback() => Container(
        width: 56,
        height: 56,
        color: Colors.grey[200],
        child: const Icon(Icons.fastfood_rounded, size: 34, color: Colors.grey),
      );

  static Widget _feeRow(String title, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF888888))),
          const Spacer(),
          Text('Rp ${_rupiah(amount)}',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14.5)),
        ],
      ),
    );
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

  static String _fmtDateTime(DateTime dt) {
    // 05/07/2025, 8:00 PM (gaya contoh)
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y, $hour12:$min $ampm';
  }
}

// Sticky header delegate (tetap sama)
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