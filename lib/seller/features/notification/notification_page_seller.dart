import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// CHAT detail
import 'package:abc_e_mart/seller/features/chat/chat_detail_page.dart';
// Riwayat withdraw
import 'package:abc_e_mart/seller/features/wallet/withdraw_history_page.dart';

class NotificationPageSeller extends StatelessWidget {
  const NotificationPageSeller({super.key});

  /// Jenis notif seller dari subcollection users/{uid}/notifications
  static const Set<String> sellerTypes = {
    // existing
    'product_approved',
    'product_rejected',
    'store_approved',
    'store_rejected',
    'ad_approved',

    // wallet (terima semua varian yang pernah dipakai)
    'withdrawal_approved',
    'withdrawal_rejected',
    'seller_withdraw_approved',
    'seller_withdraw_rejected',
    'wallet_withdraw_approved',   // <— kompatibilitas data lama
    'wallet_withdraw_rejected',   // <— kompatibilitas data lama
  };

  // longgarkan: selama mengandung 'withdraw' kita anggap notif penarikan
  bool _isWithdrawType(String type) => type.contains('withdraw');

  Color _bgColorFor(String type) {
    if (type.contains('rejected')) return Colors.red.shade50;
    if (type.contains('approved')) return Colors.green.shade50;
    if (_isWithdrawType(type)) return Colors.indigo.shade50;
    if (type == 'chat_message') return Colors.blue.shade50;
    return Colors.grey.shade100;
  }

  Color _iconBgFor(String type) {
    if (type.contains('rejected')) return Colors.red.shade100;
    if (type.contains('approved')) return Colors.green.shade100;
    if (_isWithdrawType(type)) return Colors.indigo.shade100;
    if (type == 'chat_message') return Colors.blue.shade100;
    return Colors.grey.shade300;
  }

  Color _iconColorFor(String type) {
    if (type.contains('rejected')) return Colors.red;
    if (type.contains('approved')) return Colors.green.shade800;
    if (_isWithdrawType(type)) return const Color(0xFF1C55C0);
    if (type == 'chat_message') return Colors.blue;
    return Colors.grey;
  }

  IconData _iconFor(String type) {
    if (type.contains('rejected')) return Icons.close_rounded;
    if (type.contains('approved')) return Icons.check_rounded;
    if (_isWithdrawType(type)) return Icons.account_balance_wallet_rounded;
    if (type == 'chat_message') return Icons.chat_bubble_rounded;
    return Icons.notifications_none_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Anda belum login')),
      );
    }

    final userNotifStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
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
                  if (sellerTypes.contains(type)) {
                    allNotifs.add({
                      ...data,
                      '_id': doc.id,
                      '_source': 'user',
                    });
                  }
                }
              }

              if (chatSnap.hasData) {
                for (var doc in chatSnap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  allNotifs.add({
                    ...data,
                    '_id': doc.id,
                    '_source': 'chat',
                  });
                }
              }

              allNotifs.sort((a, b) {
                final ta = a['timestamp'];
                final tb = b['timestamp'];
                if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
                if (tb is Timestamp) return 1;
                if (ta is Timestamp) return -1;
                return 0;
              });

              if (allNotifs.isEmpty) {
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
                itemCount: allNotifs.length,
                itemBuilder: (context, index) {
                  final data = allNotifs[index];
                  final type = (data['type'] ?? '').toString().toLowerCase();
                  final isChat = type == 'chat_message';
                  final bgColor = _bgColorFor(type);
                  final iconBg = _iconBgFor(type);
                  final iconColor = _iconColorFor(type);
                  final iconData = _iconFor(type);

                  return GestureDetector(
                    onTap: () async {
                      if (data['isRead'] != true) {
                        if (data['_source'] == 'user') {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('notifications')
                              .doc(data['_id'])
                              .update({'isRead': true});
                        } else if (data['_source'] == 'chat') {
                          await FirebaseFirestore.instance
                              .collection('chatNotifications')
                              .doc(data['_id'])
                              .update({'isRead': true});
                        }
                      }

                      if (_isWithdrawType(type)) {
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WithdrawHistoryPageSeller(),
                          ),
                        );
                        return;
                      }

                      if (isChat) {
                        final chatId = data['chatId'];
                        if (chatId != null && chatId.toString().isNotEmpty) {
                          final chatDoc = await FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .get();
                          final chatData = chatDoc.data();

                          if (chatData != null) {
                            final buyerId = chatData['buyerId'] ?? '';
                            final buyerName = chatData['buyerName'] ?? 'Pembeli';
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SellerChatDetailPage(
                                  chatId: chatId,
                                  buyerId: buyerId,
                                  buyerName: buyerName,
                                ),
                              ),
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Data chat tidak ditemukan.")),
                            );
                          }
                        }
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            data['title'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            data['body'] ?? '-',
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
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon Circle
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: iconBg,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              iconData,
                              color: iconColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data['title'] ?? '-',
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (data['isRead'] == false || data['isRead'] == null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'New',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
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
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['body'] ?? '-',
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
}
