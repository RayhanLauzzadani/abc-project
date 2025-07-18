import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/cart_and_order_list_card.dart';
import '../../../widgets/dummy/dummy_orders.dart';
// Tambahkan import berikut
import 'detail_history_page.dart';

class CartTabHistory extends StatelessWidget {
  const CartTabHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = dummyOrdersHistory;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.history,
              size: 85,
              color: Colors.grey[350],
            ),
            const SizedBox(height: 30),
            Text(
              "Riwayat pesanan masih kosong",
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Belum ada riwayat transaksi sebelumnya.",
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
            // Navigasi ke halaman detail pesanan buyer
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DetailHistoryPage(
                // Bisa pass id/order, atau pass objek order (kalau DetailHistoryPage sudah bisa menerima param)
                // Contoh: DetailHistoryPage(order: order),
              ),
            ));
          },
        );
      },
    );
  }
}
