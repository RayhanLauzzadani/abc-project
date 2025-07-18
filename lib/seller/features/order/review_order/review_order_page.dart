import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_accepted_popup.dart';

enum ReviewOrderState { review, accepted }

class ReviewOrderPage extends StatefulWidget {
  const ReviewOrderPage({super.key});
  @override
  State<ReviewOrderPage> createState() => _ReviewOrderPageState();
}

class _ReviewOrderPageState extends State<ReviewOrderPage> {
  ReviewOrderState _state = ReviewOrderState.review;
  bool _showFullAddress = false;

  final buyerUsername = "nabyll12765";
  final orderDate = "05/07/2025, 8:00 PM";
  final shippingAddress =
      "Home, Kemayoran, Cendana Street 1, Adinata Housing, Jakarta Pusat, RT 03 RW 06, Lantai 2, Dekat Gerbang Timur";
  final items = [
    {
      "name": "Ayam Geprek",
      "note": "Pedas",
      "qty": 1,
      "price": 15000,
      "image": "assets/images/geprek.png"
    },
    {
      "name": "Beng – Beng",
      "note": "",
      "qty": 1,
      "price": 7500,
      "image": null, // contoh tanpa gambar
    },
  ];
  final int subtotal = 22500;
  final int shippingFee = 1500;
  final int taxFee = 650;
  final int totalFee = 22500 + 1500 + 650;

  Future<void> _showOrderAcceptedPopup() async {
    await showDialog(
      context: context,
      builder: (_) => const OrderAcceptedPopup(),
    );
  }

  void _onAcceptOrder() async {
    await _showOrderAcceptedPopup();
    setState(() => _state = ReviewOrderState.accepted);
  }

  void _onRejectOrder() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0x1AFF5B5B),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.close_rounded, color: Color(0xFFFF5B5B), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Tolak Pesanan?',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF232323),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: Color(0xFFB7B7B7)),
            )
          ],
        ),
        content: Text(
          "Anda yakin ingin menolak pesanan ini?",
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: const Color(0xFF494949),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF232323),
                    backgroundColor: const Color(0xFFF2F2F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(0, 42),
                  ),
                  child: Text(
                    "Tidak",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5B5B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(0, 42),
                    elevation: 0,
                  ),
                  child: Text(
                    "Iya",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onShipOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan akan dikirim...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressThreshold = 60;
    final bool isLongAddress = shippingAddress.length > addressThreshold;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
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
                      Text(
                        "Tinjau Pesanan",
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF232323),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Username, tanggal, alamat, dst.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      "Username Pembeli",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: const Color(0xFF232323),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      buyerUsername,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(thickness: 1, color: Color(0xFFE6E6E6)),
                    const SizedBox(height: 8),
                    Text(
                      "Tanggal & Waktu",
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      orderDate,
                      style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF828282)),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      "Alamat Pengiriman",
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Builder(
                      builder: (context) {
                        final textStyle = GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF232323));
                        if (isLongAddress && !_showFullAddress) {
                          final displayText = shippingAddress.substring(0, addressThreshold) + "... ";
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
                                          child: Text(
                                            "Lihat Selengkapnya",
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2056D3),
                                            ),
                                          ),
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
                              Text(
                                shippingAddress,
                                style: textStyle,
                              ),
                              if (isLongAddress && _showFullAddress)
                                GestureDetector(
                                  onTap: () => setState(() => _showFullAddress = false),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Text(
                                      "Tutup",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2056D3),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Divider(thickness: 1, color: Color(0xFFE6E6E6)),
                  ],
                ),
              ),
            ),

            // Produk list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Gambar Produk (fallback ke Icon jika error)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: item['image'] != null
                                    ? Image.asset(
                                        item['image'] as String,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 56,
                                          height: 56,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.fastfood_rounded, size: 34, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.fastfood_rounded, size: 34, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] as String,
                                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14.7),
                                    ),
                                    if ((item['note'] as String).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.5),
                                        child: Text(
                                          item['note'] as String,
                                          style: GoogleFonts.dmSans(fontSize: 12.5, color: const Color(0xFF888888)),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "Rp ${(item['price'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}",
                                        style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF232323)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 9, top: 3),
                                child: Text(
                                  "x${item['qty']}",
                                  style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF444444)),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Garis setelah produk
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Divider(thickness: 1, color: Color(0xFFE6E6E6)),
              ),
            ),

            // Nota & metode pembayaran (kotak soft shadow, border transparan)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 11),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Nota Pesanan",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600, fontSize: 13.3, color: const Color(0xFF222222),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 20),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Row(
                              children: [
                                Text("Lihat", style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF2056D3))),
                                const Icon(Icons.receipt_long_rounded, color: Color(0xFF2056D3), size: 17),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Metode Pembayaran",
                        style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF828282)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Box abu subtotal dst
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.transparent),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFeeRow("Subtotal", subtotal, bold: true),
                          const SizedBox(height: 3),
                          _buildFeeRow("Biaya Pengiriman", shippingFee, bold: true),
                          const SizedBox(height: 3),
                          _buildFeeRow("Pajak & Biaya Lainnya", taxFee, bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.transparent),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                      child: Row(
                        children: [
                          Text(
                            "Total",
                            style: GoogleFonts.dmSans(
                              fontSize: 16.3,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF232323),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Rp ${totalFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                              color: const Color(0xFF232323),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Spacer bawah
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
        child: Row(
          children: [
            if (_state == ReviewOrderState.review) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _onRejectOrder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3449),
                    backgroundColor: const Color(0xFFFFE8E8),
                    side: const BorderSide(color: Color(0xFFFF3449), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text("Tolak", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onAcceptOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2056D3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text("Terima", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ] else ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: _onShipOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2056D3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text("Kirim Pesanan", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String title, int amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF888888),
              fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w500,
              fontSize: 14.5,
              color: const Color(0xFF222222),
            ),
          ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
