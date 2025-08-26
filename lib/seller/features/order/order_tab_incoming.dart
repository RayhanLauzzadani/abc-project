import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/cart_and_order_list_card.dart';
import 'package:abc_e_mart/seller/features/order/review_order/review_order_page.dart';

class SellerOrderTabIncoming extends StatelessWidget {
  const SellerOrderTabIncoming({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Center(
        child: Text('Silakan login sebagai seller.', style: GoogleFonts.dmSans()),
      );
    }

    // Pesanan masuk = status 'PLACED' untuk seller ini
    final stream = FirebaseFirestore.instance
      .collection('orders')
      .where('sellerId', isEqualTo: uid)
      .where('status', whereIn: ['PLACED', 'ACCEPTED'])
      .orderBy('createdAt', descending: true)
      .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
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
                  style: GoogleFonts.dmSans(fontSize: 14.5, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final docs = snap.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final orderId = docs[i].id;
            final statusStr = ((data['status'] ?? 'PLACED') as String).toUpperCase();

            final storeName = (data['storeName'] ?? '-') as String;
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
            final firstImage = items.isNotEmpty ? (items.first['imageUrl'] ?? '') as String : '';
            final itemCount = items.fold<int>(0, (a, it) => a + ((it['qty'] as num?)?.toInt() ?? 0));
            final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
            final totalPrice = ((amounts['total'] as num?) ?? 0).toInt();
            final ts = data['createdAt'];
            final orderDateTime = ts is Timestamp ? ts.toDate() : DateTime.now();

            return CartAndOrderListCard(
              storeName: storeName,
              orderId: orderId,
              productImage: firstImage,
              itemCount: itemCount,
              totalPrice: totalPrice,
              orderDateTime: orderDateTime,
              status: OrderStatus.inProgress,        // badge tetap disembunyikan
              showStatusBadge: false,
              actionTextOverride: statusStr == 'ACCEPTED' ? 'Kirim Pesanan' : 'Tinjau Pesanan', // <= opsional
              actionIconOverride: Icons.chevron_right_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewOrderPage(orderId: orderId)),
                );
              },
              onActionTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewOrderPage(orderId: orderId)),
                );
              },
              statusText: null,
            );
          },
        );
      },
    );
  }
}