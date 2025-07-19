import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../widgets/cart_and_order_list_card.dart';
import '../../../widgets/dummy/dummy_orders.dart';
import 'package:abc_e_mart/seller/features/order/review_order/review_order_page.dart';

class SellerOrderTabIncoming extends StatelessWidget {
  const SellerOrderTabIncoming({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy: order baru masuk (belum diproses)
    final orders = dummyOrdersInProgress; // Ganti source sesuai kebutuhan

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 85, color: Colors.grey[350]),
            const SizedBox(height: 30),
            Text(
              "Belum ada pesanan masuk",
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pesanan baru dari pembeli akan muncul di sini.",
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
          showStatusBadge: false,
          actionTextOverride: "Tinjau Pesanan",
          actionIconOverride: Icons.chevron_right_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReviewOrderPage(),
              ),
            );
          },
          onActionTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReviewOrderPage(),
              ),
            );
          },
          statusText: null, // ga perlu status text
        );
      },
    );
  }
}
