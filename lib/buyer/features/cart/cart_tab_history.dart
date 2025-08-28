import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../widgets/cart_and_order_list_card.dart' as cards;
import 'detail_history_page.dart' show DetailHistoryPage;

class CartTabHistory extends StatelessWidget {
  const CartTabHistory({super.key});

  // Map status string -> (status badge kartu, teks)
  (cards.OrderStatus, String) _mapStatus(String? raw) {
    final s = (raw ?? '').toUpperCase();
    if (s == 'COMPLETED' || s == 'SUCCESS') {
      return (cards.OrderStatus.success, 'Selesai');
    }
    if (s == 'CANCELED' || s == 'CANCELLED' || s == 'REJECTED') {
      return (cards.OrderStatus.canceled, 'Dibatalkan');
    }
    // fallback (harusnya jarang muncul di riwayat)
    return (cards.OrderStatus.inProgress, '—');
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text('Silakan login untuk melihat riwayat.', style: GoogleFonts.dmSans()),
      );
    }

    // Pesanan yang sudah berakhir (selesai atau batal)
    final endStatuses = ['COMPLETED', 'SUCCESS', 'CANCELED', 'CANCELLED', 'REJECTED'];

    final stream = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .where('status', whereIn: endStatuses) // mungkin perlu index komposit
        .orderBy('updatedAt', descending: true)
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
                Icon(LucideIcons.history, size: 85, color: Colors.grey[350]),
                const SizedBox(height: 30),
                Text(
                  "Riwayat pesanan masih kosong",
                  style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  "Belum ada riwayat pesanan sebelumnya.",
                  style: GoogleFonts.dmSans(fontSize: 14.5, color: Colors.grey[500]),
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
            final orderId = doc.id;

            final storeName = (data['storeName'] ?? '-') as String;

            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
            final firstImage = items.isNotEmpty ? (items.first['imageUrl'] ?? '') as String : '';
            final itemCount = items.fold<int>(
              0,
              (a, it) => a + ((it['qty'] as num?)?.toInt() ?? 0),
            );

            final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
            final totalPrice = ((amounts['total'] as num?) ?? 0).toInt();

            final ts = data['updatedAt'] ?? data['createdAt'];
            final orderDateTime = ts is Timestamp ? ts.toDate() : DateTime.now();

            // status (fallback ke shippingAddress.status untuk data lama)
            final rawStatus = (data['status'] ?? data['shippingAddress']?['status']) as String?;
            final (badgeStatus, badgeText) = _mapStatus(rawStatus);

            // ambil invoiceId (kalau ada) untuk ditampilkan di kartu
            final invoiceRaw = (data['invoiceId'] as String?)?.trim();
            final displayId = (invoiceRaw != null && invoiceRaw.isNotEmpty) ? invoiceRaw : null;

            return cards.CartAndOrderListCard(
              storeName: storeName,
              orderId: orderId,               // tetap pakai doc.id untuk navigasi
              displayId: displayId,           // tampilkan #invoiceId di UI kalau ada
              productImage: firstImage,
              itemCount: itemCount,
              totalPrice: totalPrice,
              orderDateTime: orderDateTime,
              status: badgeStatus,            // hijau untuk selesai, merah untuk batal
              statusText: badgeText,          // "Selesai" / "Dibatalkan"
              actionTextOverride: "Detail Pesanan",
              actionIconOverride: Icons.chevron_right_rounded,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetailHistoryPage(orderId: orderId)),
                );
              },
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetailHistoryPage(orderId: orderId)),
                );
              },
            );
          },
        );
      },
    );
  }
}
