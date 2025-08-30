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
        child: Text(
          'Silakan login sebagai seller.',
          style: GoogleFonts.dmSans(),
        ),
      );
    }

    // Pesanan masuk untuk seller ini (PLACED / ACCEPTED)
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

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
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
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();

            // ID dokumen asli (untuk navigasi/query)
            final String realOrderId = doc.id;

            // ID yang ditampilkan di kartu (#...) → pakai invoiceId jika ada
            final String displayedId = (() {
              final String? inv = (data['invoiceId'] as String?)?.trim();
              if (inv != null && inv.isNotEmpty) return inv;
              return realOrderId; // fallback
            })();

            final statusStr = ((data['status'] ?? 'PLACED') as String)
                .toUpperCase();

            // Nama toko
            final storeName = (data['storeName'] ?? '-') as String;

            // Items ringkas (gambar pertama & total qty)
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
            final firstImage = items.isNotEmpty
                ? (items.first['imageUrl'] ?? '') as String
                : '';
            final itemCount = items.fold<int>(
              0,
              (a, it) => a + ((it['qty'] as num?)?.toInt() ?? 0),
            );

            // Amounts / total
            final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
            final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
            final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
            final totalPrice = subtotal + shipping; // seller hanya menerima ini

            // Tanggal dibuat
            final ts = data['createdAt'];
            final orderDateTime = ts is Timestamp ? ts.toDate() : null;

            return CartAndOrderListCard(
              storeName: storeName,
              // TAMPILAN # → invoiceId (fallback doc.id)
              orderId: displayedId,
              productImage: firstImage,
              itemCount: itemCount,
              totalPrice: totalPrice,
              orderDateTime: orderDateTime,
              status: OrderStatus.inProgress,
              showStatusBadge: false,
              actionTextOverride: statusStr == 'ACCEPTED'
                  ? 'Kirim Pesanan'
                  : 'Tinjau Pesanan',
              actionIconOverride: Icons.chevron_right_rounded,
              // Navigasi tetap pakai doc.id asli
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewOrderPage(orderId: realOrderId),
                  ),
                );
              },
              onActionTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewOrderPage(orderId: realOrderId),
                  ),
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
