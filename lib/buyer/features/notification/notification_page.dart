import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/seller/features/home/home_page_seller.dart';
import 'package:abc_e_mart/seller/widgets/shop_rejected_page.dart';
import 'package:abc_e_mart/buyer/features/chat/chat_detail_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // ❌ tidak ada wallet_topup_submitted di sini
  static const Set<String> buyerTypes = {
    'store_approved',
    'store_rejected',
    'order_update',
    'promo',
    'wallet_topup_approved',
    'wallet_topup_rejected',
  };

  bool _isTopup(String t) => t.startsWith('wallet_topup');

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Anda belum login')));
    }

    final userNotifStream = FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();

    final chatNotifStream = FirebaseFirestore.instance
        .collection('chatNotifications')
        .where('receiverId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'chat_message')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, elevation: 0,
        title: Text('Notifikasi', style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700, fontSize: 19, color: Colors.black)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFF2056D3), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userNotifStream,
        builder: (context, userSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: chatNotifStream,
            builder: (context, chatSnap) {
              if (userSnap.connectionState == ConnectionState.waiting ||
                  chatSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Map<String, dynamic>> allNotifs = [];

              if (userSnap.hasData) {
                for (var doc in userSnap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final type = (data['type']?.toString() ?? '').toLowerCase();
                  if (buyerTypes.contains(type)) {
                    allNotifs.add({...data, '_id': doc.id, '_source': 'user'});
                  }
                }
              }

              if (chatSnap.hasData) {
                for (var doc in chatSnap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  allNotifs.add({...data, '_id': doc.id, '_source': 'chat'});
                }
              }

              allNotifs.sort((a, b) {
                final ta = a['timestamp'], tb = b['timestamp'];
                if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
                if (tb is Timestamp) return 1;
                if (ta is Timestamp) return -1;
                return 0;
              });

              if (allNotifs.isEmpty) {
                return Center(
                  child: Text("Belum ada notifikasi.",
                    style: GoogleFonts.dmSans(
                      fontStyle: FontStyle.italic, fontSize: 15, color: const Color(0xFF9A9A9A))),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: allNotifs.length,
                itemBuilder: (context, index) {
                  final data = allNotifs[index];
                  final type = (data['type'] ?? '').toString().toLowerCase();

                  final isRejected     = type == 'store_rejected';
                  final isApproved     = type == 'store_approved';
                  final isPromo        = type == 'promo';
                  final isOrderUpdate  = type == 'order_update';
                  final isChatMessage  = type == 'chat_message';

                  final isTopupApproved  = type == 'wallet_topup_approved';
                  final isTopupRejected  = type == 'wallet_topup_rejected';
                  final isTopupAny       = _isTopup(type);

                  final bgColor =
                        isTopupRejected ? Colors.red.shade50
                      : isTopupApproved ? Colors.green.shade50
                      : isRejected      ? Colors.red.shade50
                      : isApproved      ? Colors.green.shade50
                      : isPromo         ? Colors.yellow.shade50
                      : isOrderUpdate   ? Colors.blue.shade50
                      : isChatMessage   ? Colors.indigo.shade50
                      : Colors.grey.shade100;

                  final iconBg =
                        isTopupRejected ? Colors.red.shade100
                      : isTopupApproved ? Colors.green.shade100
                      : isRejected      ? Colors.red.shade100
                      : isApproved      ? Colors.green.shade100
                      : isPromo         ? Colors.yellow.shade200
                      : isOrderUpdate   ? Colors.blue.shade100
                      : isChatMessage   ? Colors.indigo.shade100
                      : Colors.grey.shade300;

                  final iconColor =
                        isTopupRejected ? Colors.red
                      : isTopupApproved ? Colors.green.shade800
                      : isRejected      ? Colors.red
                      : isApproved      ? Colors.green.shade800
                      : isPromo         ? Colors.orange
                      : isOrderUpdate   ? Colors.blue
                      : isChatMessage   ? Colors.indigo
                      : Colors.grey;

                  final iconData =
                        isTopupAny     ? Icons.account_balance_wallet_rounded
                      : isRejected     ? Icons.close_rounded
                      : isApproved     ? Icons.check_rounded
                      : isPromo        ? Icons.campaign_rounded
                      : isOrderUpdate  ? Icons.local_shipping_rounded
                      : isChatMessage  ? Icons.chat_bubble_rounded
                      : Icons.notifications_none_rounded;

                  return GestureDetector(
                    onTap: () async {
                      if (data['isRead'] != true) {
                        if (data['_source'] == 'user') {
                          await FirebaseFirestore.instance
                              .collection('users').doc(user.uid)
                              .collection('notifications').doc(data['_id'])
                              .update({'isRead': true});
                        } else if (data['_source'] == 'chat') {
                          await FirebaseFirestore.instance
                              .collection('chatNotifications')
                              .doc(data['_id']).update({'isRead': true});
                        }
                      }

                      // Topup approved/rejected → tampilkan detail ringkas
                      if (isTopupAny) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(data['title'] ?? 'Top Up', style: const TextStyle(fontWeight: FontWeight.bold)),
                            content: Text(data['body'] ?? '-', style: const TextStyle(fontSize: 15)),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                          ),
                        );
                        return;
                      }

                      if (isApproved) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomePageSeller()));
                        return;
                      }

                      if (isRejected) {
                        await FirebaseFirestore.instance
                            .collection('users').doc(user.uid)
                            .collection('notifications').doc(data['_id'])
                            .update({'hasOpenedRejectedPage': true});
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ShopRejectedPage(reason: data['body'] ?? '-'),
                        ));
                        return;
                      }

                      if (isPromo || isOrderUpdate) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(data['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                            content: Text(data['body'] ?? '-', style: const TextStyle(fontSize: 15)),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                          ),
                        );
                        return;
                      }

                      if (isChatMessage) {
                        final chatId = data['chatId'];
                        if (chatId != null) {
                          final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
                          final chatData = chatDoc.data();
                          if (chatData != null) {
                            final shopId = chatData['shopId'] ?? '';
                            final shopName = chatData['shopName'] ?? 'Toko';
                            // ignore: use_build_context_synchronously
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ChatDetailPage(chatId: chatId, shopId: shopId, shopName: shopName),
                            ));
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Data chat tidak ditemukan.")),
                            );
                          }
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1.2),
                        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
                            padding: const EdgeInsets.all(8),
                            child: Icon(iconData, color: iconColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(data['title'] ?? '-', style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                                    ),
                                    if (data['isRead'] == false || data['isRead'] == null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                        child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  () {
                                    final ts = data['timestamp'];
                                    if (ts is Timestamp) {
                                      return DateFormat('dd MMM, yyyy | HH:mm').format(ts.toDate());
                                    }
                                    return '-';
                                  }(),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(data['body'] ?? '-', style: const TextStyle(fontSize: 14)),
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
}
