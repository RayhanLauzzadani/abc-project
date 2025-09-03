import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../widgets/cart_and_order_list_card.dart';
import 'track_order/track_order_page.dart'; // Pastikan path & nama classnya sesuai

class SellerOrderTabDelivered extends StatelessWidget {
  const SellerOrderTabDelivered({super.key});

  // Map Firestore status -> kartu + teks badge
  (OrderStatus, String) _mapStatus(String? raw) {
    final s = (raw ?? '').toUpperCase();
    if (s == 'DELIVERED') return (OrderStatus.delivered, 'Terkirim');
    if (s == 'SHIPPED') return (OrderStatus.inProgress, 'Dikirim');
    if (s == 'COMPLETED' || s == 'SUCCESS')
      return (OrderStatus.success, 'Selesai');
    return (OrderStatus.inProgress, 'Dalam Proses');
  }

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

    // Pesanan yang sudah dikirim / terkirim untuk seller ini
    final stream = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: uid)
        .where(
          'status',
          whereIn: ['SHIPPED', 'DELIVERED'],
        ) // tambahkan DELIVERED juga
        .orderBy('updatedAt', descending: true)
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

        final docs = snap.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();

            // ID asli dokumen (untuk navigasi / query)
            final realOrderId = doc.id;

            // Tampilkan invoiceId jika ada, fallback doc.id
            final rawInvoice = (data['invoiceId'] as String?)?.trim();
            final displayId = (rawInvoice != null && rawInvoice.isNotEmpty)
                ? rawInvoice
                : realOrderId;

            final storeName = (data['storeName'] ?? '-') as String;

            // Items ringkas (gambar & total qty)
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
            final firstImage = items.isNotEmpty
                ? ((items.first['imageUrl'] ?? items.first['image'] ?? '')
                      as String)
                : '';
            final itemCount = items.fold<int>(
              0,
              (a, it) => a + ((it['qty'] as num?)?.toInt() ?? 0),
            );

            // Amounts / total
            final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
            final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
            final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
            final totalPrice = subtotal + shipping; // seller take

            // Tanggal update (fallback ke createdAt)
            final ts = data['updatedAt'] ?? data['createdAt'];
            final orderDateTime = ts is Timestamp
                ? ts.toDate()
                : DateTime.now();

            // Status & badge
            final statusStr = (data['status'] ?? 'SHIPPED') as String;
            final (cardStatus, badgeText) = _mapStatus(statusStr);

            return CartAndOrderListCard(
              storeName: storeName,
              orderId: realOrderId, // untuk navigasi
              displayId: displayId, // untuk tampilan (#INV…)
              productImage: firstImage,
              itemCount: itemCount,
              totalPrice: totalPrice,
              orderDateTime: orderDateTime,
              status: cardStatus,
              statusText: badgeText, // “Dikirim” / “Terkirim”
              showStatusBadge: true,
              actionTextOverride: "Lacak Pesanan",
              actionIconOverride: Icons.chevron_right_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackOrderPageSeller(orderId: realOrderId),
                  ),
                );
              },
              onActionTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackOrderPageSeller(orderId: realOrderId),
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
