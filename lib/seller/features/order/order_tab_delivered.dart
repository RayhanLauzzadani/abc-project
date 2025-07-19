import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../widgets/cart_and_order_list_card.dart';
import '../../../widgets/dummy/dummy_orders.dart';

class SellerOrderTabDelivered extends StatelessWidget {
  const SellerOrderTabDelivered({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy: order dikirim/dalam proses (gunakan dummy yang relevan)
    final orders = dummyOrdersInProgress;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.truck, size: 85, color: Colors.grey[350]),
            const SizedBox(height: 30),
            Text(
              "Belum ada pesanan dikirim",
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pesanan yang sudah dikirim akan muncul di sini.",
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
          storeName: order.storeName, // ganti ke order.buyerName jika sudah ada
          orderId: order.orderId,
          productImage: order.productImage,
          itemCount: order.itemCount,
          totalPrice: order.totalPrice,
          orderDateTime: order.orderDateTime,
          status: order.status,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tinjau Pesanan...")),
            );
          },
          onActionTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tinjau Pesanan...")),
            );
          },
          statusText: "Dalam Proses", // bisa diganti sesuai status
        );
      },
    );
  }
}
