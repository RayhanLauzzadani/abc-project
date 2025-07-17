import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/seller/features/chat/chat_detail_page.dart';

class NotificationPageSeller extends StatelessWidget {
  const NotificationPageSeller({super.key});

  static const Set<String> sellerTypes = {
    'product_approved',
    'product_rejected',
    'store_approved',
    'store_rejected',
    // 'chat_message', // Dihandle via chatNotifications
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Anda belum login')),
      );
    }

    // 1. Stream notif selain chat
    final userNotifStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();

    // 2. Stream chat notif dari root
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
              // Loading state
              if (userSnap.connectionState == ConnectionState.waiting ||
                  chatSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Kumpulkan semua notif
              final List<Map<String, dynamic>> allNotifs = [];

              // Ambil notif regular
              if (userSnap.hasData) {
                for (var doc in userSnap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Filter hanya seller notif
                  final type = data['type']?.toString() ?? '';
                  if (sellerTypes.contains(type)) {
                    allNotifs.add({
                      ...data,
                      '_id': doc.id,
                      '_source': 'user', // Penanda
                    });
                  }
                }
              }

              // Ambil notif chat
              if (chatSnap.hasData) {
                for (var doc in chatSnap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  allNotifs.add({
                    ...data,
                    '_id': doc.id,
                    '_source': 'chat', // Penanda
                  });
                }
              }

              // Urutkan descending
              allNotifs.sort((a, b) =>
                (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp)
              );

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
                  final type = data['type'] ?? '';
                  final isChat = type == 'chat_message';
                  final isRejected = type.contains('rejected');
                  final isApproved = type.contains('approved');

                  // Color & Icon
                  final bgColor = isRejected
                    ? Colors.red.shade50
                    : isApproved
                    ? Colors.green.shade50
                    : isChat
                    ? Colors.blue.shade50
                    : Colors.grey.shade100;

                  final iconBg = isRejected
                    ? Colors.red.shade100
                    : isApproved
                    ? Colors.green.shade100
                    : isChat
                    ? Colors.blue.shade100
                    : Colors.grey.shade300;

                  final iconColor = isRejected
                    ? Colors.red
                    : isApproved
                    ? Colors.green.shade800
                    : isChat
                    ? Colors.blue
                    : Colors.grey;

                  final iconData = isRejected
                    ? Icons.close_rounded
                    : isApproved
                    ? Icons.check_rounded
                    : isChat
                    ? Icons.chat_bubble_rounded
                    : Icons.notifications_none_rounded;

                  return GestureDetector(
                    onTap: () async {
                      // Mark as read
                      if (data['isRead'] != true) {
                        if (data['_source'] == 'user') {
                          // Update ke subcollection
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

                      // Handle navigation
                      if (isRejected || isApproved) {
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
                      } else if (isChat) {
                        final chatId = data['chatId'];
                        if (chatId != null) {
                          final chatDoc = await FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .get();
                          final chatData = chatDoc.data();

                          if (chatData != null) {
                            final buyerId = chatData['buyerId'] ?? '';
                            final buyerName = chatData['buyerName'] ?? 'Pembeli';
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
                                // Title + New Badge
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
                                // Date
                                Text(
                                  data['timestamp'] != null
                                      ? DateFormat('dd MMM, yyyy | HH:mm').format(
                                          (data['timestamp'] as Timestamp).toDate())
                                      : '-',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Message
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
