import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/cart_and_order_list_card.dart';
import 'package:abc_e_mart/buyer/features/order/order_tracking_page_buyer.dart';

class CartTabInProgress extends StatelessWidget {
  const CartTabInProgress({super.key});

  // Map string status Firestore -> enum yang dipakai card
  OrderStatus _mapOrderStatus(String s) {
    final v = s.toUpperCase();
    if (v == 'COMPLETED' || v == 'SUCCESS') return OrderStatus.success;
    if (v == 'DELIVERED') return OrderStatus.delivered;
    if (v == 'CANCELED' || v == 'CANCELLED' || v == 'REJECTED') {
      return OrderStatus.canceled;
    }
    return OrderStatus.inProgress; // PLACED/ACCEPTED/SHIPPED, dll
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Center(
        child: Text('Silakan login untuk melihat pesanan.', style: GoogleFonts.dmSans()),
      );
    }

    final statuses = ['PLACED', 'ACCEPTED', 'SHIPPED', 'DELIVERED'];

    final stream = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .where('status', whereIn: statuses) // mungkin perlu index komposit
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final orderId = docs[i].id;
            final storeName = (data['storeName'] ?? '') as String;
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
            final firstImage =
                items.isNotEmpty ? (items.first['imageUrl'] ?? '') as String : '';
            final itemCount = items.fold<int>(
              0,
              (acc, it) => acc + ((it['qty'] as num?)?.toInt() ?? 0), // ⬅ fix num→int
            );
            final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
            final totalPrice = ((amounts['total'] as num?) ?? 0).toInt();
            final ts = data['createdAt'];
            final orderDateTime = ts is Timestamp ? ts.toDate() : DateTime.now();
            final statusStr = (data['status'] ?? 'PLACED') as String;

            return CartAndOrderListCard(
              storeName: storeName,
              orderId: orderId,
              productImage: firstImage,
              itemCount: itemCount,
              totalPrice: totalPrice,
              orderDateTime: orderDateTime,
              status: _mapOrderStatus(statusStr),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingPage(orderId: orderId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}