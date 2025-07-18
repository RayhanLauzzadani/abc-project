import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OrderStatus { selesai, dibatalkan, dikirim, menunggu }

class DetailOrderPage extends StatefulWidget {
  const DetailOrderPage({super.key});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  bool _showFullAddress = false;

  @override
  Widget build(BuildContext context) {
    // Simulasi data order (dummy)
    final orderStatus = OrderStatus.dibatalkan; // selesai/dibatalkan/dikirim/menunggu
    final buyerName = "nabyll12765";
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
        "image": null,
      },
    ];
    final int subtotal = 22500;
    final int shippingFee = 1500;
    final int taxFee = 650;
    final int totalFee = subtotal + shippingFee + taxFee;

    final addressThreshold = 60;
    final bool isLongAddress = shippingAddress.length > addressThreshold;
    final bool showNota = orderStatus != OrderStatus.dibatalkan;

    SliverToBoxAdapter _buildSeparator({double vertical = 0}) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: vertical),
          child: Divider(thickness: 1, color: const Color(0xFFE6E6E6)),
        ),
      );
    }


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
                        "Detail Pesanan",
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

            // Header: nama pembeli + status badge
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
                            buyerName,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(orderStatus),
                  ],
                ),
              ),
            ),

            // Garis separator setelah header
            _buildSeparator(),

            // Tanggal & waktu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tanggal & Waktu",
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      orderDate,
                      style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF828282)),
                    ),
                  ],
                ),
              ),
            ),

            // Alamat pengiriman (dengan read more)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
            ),

            // Garis separator setelah alamat
            _buildSeparator(),

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

            // Garis separator setelah produk
            _buildSeparator(vertical: 18),

            // Nota & metode pembayaran (hanya jika tidak dibatalkan)
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
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Metode Pembayaran",
                              style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF828282)),
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/images/qris.png',
                              height: 14,
                              fit: BoxFit.contain,
                            ),
                          ],
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
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    String text;
    Color color;
    switch (status) {
      case OrderStatus.selesai:
        text = "Selesai";
        color = const Color(0xFF24B47E);
        break;
      case OrderStatus.dibatalkan:
        text = "Dibatalkan";
        color = const Color(0xFFFF3449);
        break;
      case OrderStatus.dikirim:
        text = "Dikirim";
        color = const Color(0xFF2056D3);
        break;
      case OrderStatus.menunggu:
        text = "Menunggu";
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
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 13.2,
            ),
          ),
        ],
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

// Sticky header delegate (sama seperti sebelumnya)
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
