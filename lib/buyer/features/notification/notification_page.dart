import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Seller pages (tetap)
import 'package:abc_e_mart/seller/features/home/home_page_seller.dart';
import 'package:abc_e_mart/seller/widgets/shop_rejected_page.dart';

// Buyer chat detail (tetap)
import 'package:abc_e_mart/buyer/features/chat/chat_detail_page.dart';
import 'package:abc_e_mart/buyer/features/order/order_tracking_page_buyer.dart';


// ---------------------------------------------------------------------
// Jika kamu punya route untuk tracking, daftarkan di MaterialApp routes:
// routes: {'/buyer/order-tracking': (_) => OrderTrackingPageBuyer()},
// Lalu di sini kita cukup pushNamed tanpa import widget-nya.
// ---------------------------------------------------------------------

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  /// Tipe notif Buyer (legacy + order flow baru—TANPA order_delivered)
  static const Set<String> buyerTypes = {
    'store_approved',
    'store_rejected',
    'order_update',
    'promo',
    'wallet_topup_approved',
    'wallet_topup_rejected',

    // order flow baru (BUYER ONLY)
    'order_accepted',
    'order_shipped',
  };

  bool _isTopup(String t) => t.startsWith('wallet_topup');

  // ---------- style helpers ----------
  Color _bgColorFor(String t) {
    if (t == 'wallet_topup_rejected' || t == 'store_rejected')
      return const Color(0xFFFFF2F2);
    if (t == 'wallet_topup_approved' || t == 'store_approved')
      return const Color(0xFFEFF8F1);
    if (t == 'promo') return const Color(0xFFFFF7E6);
    if (t == 'order_update' || t == 'order_shipped')
      return const Color(0xFFEAF4FF);
    if (t == 'order_accepted') return const Color(0xFFF1FFF6);
    if (t == 'chat_message') return const Color(0xFFE8ECFF);
    return const Color(0xFFF5F5F5);
  }

  Color _iconBgFor(String t) {
    if (t == 'wallet_topup_rejected' || t == 'store_rejected')
      return const Color(0xFFFFE1E1);
    if (t == 'wallet_topup_approved' || t == 'store_approved')
      return const Color(0xFFD8F3DD);
    if (t == 'promo') return const Color(0xFFFFECCC);
    if (t == 'order_update' || t == 'order_shipped')
      return const Color(0xFFD6E8FF);
    if (t == 'order_accepted') return const Color(0xFFE8FFF0);
    if (t == 'chat_message') return const Color(0xFFDDE3FF);
    return const Color(0xFFE0E0E0);
  }

  Color _iconColorFor(String t) {
    if (t == 'wallet_topup_rejected' || t == 'store_rejected')
      return const Color(0xFFD32F2F);
    if (t == 'wallet_topup_approved' || t == 'store_approved')
      return const Color(0xFF2E7D32);
    if (t == 'promo') return const Color(0xFFEF6C00);
    if (t == 'order_update' || t == 'order_shipped')
      return const Color(0xFF1976D2);
    if (t == 'order_accepted') return const Color(0xFF2E7D32);
    if (t == 'chat_message') return const Color(0xFF3F51B5);
    return const Color(0xFF616161);
  }

  IconData _iconFor(String t) {
    if (t == 'wallet_topup_rejected' || t == 'store_rejected')
      return Icons.close_rounded;
    if (t == 'wallet_topup_approved' || t == 'store_approved')
      return Icons.check_rounded;
    if (t == 'promo') return Icons.campaign_rounded;
    if (t == 'order_update' || t == 'order_shipped')
      return Icons.local_shipping_rounded;
    if (t == 'order_accepted') return Icons.task_alt_rounded;
    if (t == 'chat_message') return Icons.chat_bubble_rounded;
    return Icons.notifications_none_rounded;
  }

  // format waktu unify (pakai createdAt kalau ada)
  String _formatTs(Map<String, dynamic> data) {
    final ts = (data['createdAt'] is Timestamp)
        ? data['createdAt'] as Timestamp
        : (data['timestamp'] is Timestamp
              ? data['timestamp'] as Timestamp
              : null);
    if (ts == null) return '-';
    return DateFormat('dd MMM, yyyy | HH:mm').format(ts.toDate());
  }

  // Stream: user notifications (tanpa orderBy agar kompatibel field waktu)
  Stream<QuerySnapshot<Map<String, dynamic>>> _userNotifStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .snapshots();
  }

  // Stream: chat notifications (pakai timestamp)
  Stream<QuerySnapshot<Map<String, dynamic>>> _chatNotifStream(String uid) {
    return FirebaseFirestore.instance
        .collection('chatNotifications')
        .where('receiverId', isEqualTo: uid)
        .where('type', isEqualTo: 'chat_message')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ambil ts unify untuk sort
  Timestamp? _pickTs(Map<String, dynamic> data) {
    final c = data['createdAt'];
    final t = data['timestamp'];
    if (c is Timestamp) return c;
    if (t is Timestamp) return t;
    return null;
  }

  // tandai read (fire-and-forget agar tidak perlu double tap)
  void _markUserRead({required String uid, required String docId}) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(docId)
        .update({'isRead': true});
  }

  void _markChatRead(String docId) {
    FirebaseFirestore.instance
        .collection('chatNotifications')
        .doc(docId)
        .update({'isRead': true});
  }

  // Rapikan body untuk order notif (hilangkan #xxxx, tampilkan invoice bila ada)
  String _prettyOrderBody(Map<String, dynamic> data) {
    final invoice = (data['invoiceId'] as String?)?.trim();
    if (invoice != null && invoice.isNotEmpty) {
      final t = (data['type'] as String? ?? '').toLowerCase();
      final base = t == 'order_shipped'
          ? 'Pesanan sedang dikirim'
          : 'Pesanan telah diterima penjual';
      return '$base (Invoice: $invoice).';
    }
    final body = (data['body'] as String?) ?? '';
    final cleaned = body.replaceAll(RegExp(r'#[^\s]+'), '').trim();
    return cleaned.isEmpty ? 'Status pesanan diperbarui.' : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Anda belum login')));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2056D3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _userNotifStream(user.uid),
        builder: (context, userSnap) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _chatNotifStream(user.uid),
            builder: (context, chatSnap) {
              if (userSnap.connectionState == ConnectionState.waiting ||
                  chatSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Map<String, dynamic>> all = [];

              // user notifications (filter tipe & archived=false)
              if (userSnap.hasData) {
                for (final doc in userSnap.data!.docs) {
                  final data = doc.data();
                  final type = (data['type']?.toString() ?? '').toLowerCase();
                  final archived = data['archived'] == true;
                  if (buyerTypes.contains(type) && !archived) {
                    all.add({
                      ...data,
                      '_id': doc.id,
                      '_source': 'user',
                      '_ts': _pickTs(data),
                    });
                  }
                }
              }

              // chat notifications
              if (chatSnap.hasData) {
                for (final doc in chatSnap.data!.docs) {
                  final data = doc.data();
                  all.add({
                    ...data,
                    '_id': doc.id,
                    '_source': 'chat',
                    '_ts': (data['timestamp'] is Timestamp)
                        ? data['timestamp']
                        : null,
                  });
                }
              }

              // sort desc by time
              all.sort((a, b) {
                final ta = a['_ts'];
                final tb = b['_ts'];
                if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
                if (tb is Timestamp) return 1;
                if (ta is Timestamp) return -1;
                return 0;
              });

              if (all.isEmpty) {
                return Center(
                  child: Text(
                    "Belum ada notifikasi.",
                    style: GoogleFonts.dmSans(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      color: const Color(0xFF9A9A9A),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: all.length,
                itemBuilder: (context, index) {
                  final data = all[index];
                  final type = (data['type'] ?? '').toString().toLowerCase();

                  final isRejected = type == 'store_rejected';
                  final isApproved = type == 'store_approved';
                  final isPromo = type == 'promo';
                  final isOrderUpdate = type == 'order_update';

                  final isOrderAccepted = type == 'order_accepted';
                  final isOrderShipped = type == 'order_shipped';
                  final isOrderFlow = isOrderAccepted || isOrderShipped;

                  final isChatMessage = type == 'chat_message';
                  final isTopupAny = _isTopup(type);

                  final bgColor = _bgColorFor(type);
                  final iconBg = _iconBgFor(type);
                  final iconCol = _iconColorFor(type);
                  final icon = _iconFor(type);

                  // Title & body
                  String title =
                      (data['title'] as String?) ??
                      (isOrderFlow ? 'Status Pesanan' : 'Notifikasi');
                  String body = (data['body'] as String?) ?? '';
                  if (isOrderFlow) {
                    body = _prettyOrderBody(data);
                    title = isOrderAccepted
                        ? 'Pesanan Diterima'
                        : 'Pesanan Dikirim';
                  }

                  final tsText = _formatTs(data);

                  return GestureDetector(
                    onTap: () async {
                      // tandai read (non-blocking)
                      if (data['_source'] == 'user') {
                        _markUserRead(uid: user.uid, docId: data['_id']);
                      } else {
                        _markChatRead(data['_id']);
                      }

                      // ====== navigasi per tipe ======
                      if (isTopupAny || isPromo || isOrderUpdate) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              body,
                              style: const TextStyle(fontSize: 15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      if (isApproved) {
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePageSeller(),
                          ),
                        );
                        return;
                      }

                      if (isRejected) {
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopRejectedPage(reason: body),
                          ),
                        );
                        return;
                      }

                      if (isChatMessage) {
                        final chatId = data['chatId'];
                        if (chatId != null) {
                          final chatDoc = await FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .get();
                          final chatData = chatDoc.data();
                          if (!context.mounted) return;
                          if (chatData != null) {
                            final shopId = chatData['shopId'] ?? '';
                            final shopName = chatData['shopName'] ?? 'Toko';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  chatId: chatId,
                                  shopId: shopId,
                                  shopName: shopName,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Data chat tidak ditemukan."),
                              ),
                            );
                          }
                        }
                        return;
                      }

                      if (isOrderFlow) {
                        // buka tracking buyer via route agar tidak tergantung class
                        final orderId =
                            (data['orderId'] as String?) ??
                            (data['orderDocId'] as String?) ??
                            '';
                        if (!context.mounted) return;
                        if (orderId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderTrackingPage(orderId: orderId),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Detail Pesanan'),
                              content: Text(body),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        }
                        return;
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _iconBgFor(type),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(icon, color: iconCol, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    if ((data['isRead'] != true) ||
                                        (data['_source'] == 'chat' &&
                                            data['isRead'] == false))
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'New',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTs(data),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isOrderFlow(type)
                                      ? _prettyOrderBody(data)
                                      : (data['body'] ?? '-'),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // kecil saja biar inline
  bool _isOrderFlow(String t) => t == 'order_accepted' || t == 'order_shipped';
}
