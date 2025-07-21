import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/cart_and_order_list_card.dart';
import '../../../widgets/dummy/dummy_orders.dart';
import 'package:abc_e_mart/buyer/features/order/order_tracking_page_buyer.dart';

class CartTabInProgress extends StatelessWidget {
  const CartTabInProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = dummyOrdersInProgress;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.clock, size: 85, color: Colors.grey[350]),
            const SizedBox(height: 30),
            Text(
              "Belum ada pesanan dalam proses",
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Yuk, cek katalog dan mulai belanja!",
              style: GoogleFonts.dmSans(
                fontSize: 14.5,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        return CartAndOrderListCard(
          storeName: order.storeName,
          orderId: order.orderId,
          productImage: order.productImage,
          itemCount: order.itemCount,
          totalPrice: order.totalPrice,
          orderDateTime: order.orderDateTime,
          status: order.status,
          onTap: () {
            // Navigasi ke halaman lacak pesanan
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackingPage(),
              ), // Ganti dengan halaman Lacak Pesanan yang sesuai
            );
          },
        );
      },
    );
  }
}
