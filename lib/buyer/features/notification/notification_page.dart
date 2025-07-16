import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/seller/features/home/home_page_seller.dart';
import 'package:abc_e_mart/seller/widgets/shop_rejected_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const Set<String> buyerTypes = {
    'store_approved',
    'store_rejected',
    'order_update',
    'promo',
    // Tambahkan jika ada tipe lain
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
      body: user == null
          ? const Center(child: Text('Anda belum login'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

                final notifications = snapshot.data!.docs.where((notifDoc) {
                  final data = notifDoc.data() as Map<String, dynamic>;
                  final type = data['type']?.toString() ?? '';
                  return buyerTypes.contains(type);
                }).toList();

                if (notifications.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada notifikasi untuk Anda.",
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
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notifDoc = notifications[index];
                    final data = notifDoc.data() as Map<String, dynamic>;
                    final type = data['type']?.toString() ?? '';
                    final isRejected = type == 'store_rejected';
                    final isApproved = type == 'store_approved';
                    final isPromo = type == 'promo';
                    final isOrderUpdate = type == 'order_update';

                    // Warna
                    final bgColor = isRejected
                        ? Colors.red.shade50
                        : isApproved
                        ? Colors.green.shade50
                        : isPromo
                        ? Colors.yellow.shade50
                        : isOrderUpdate
                        ? Colors.blue.shade50
                        : Colors.grey.shade100;
                    final iconBg = isRejected
                        ? Colors.red.shade100
                        : isApproved
                        ? Colors.green.shade100
                        : isPromo
                        ? Colors.yellow.shade200
                        : isOrderUpdate
                        ? Colors.blue.shade100
                        : Colors.grey.shade300;
                    final iconColor = isRejected
                        ? Colors.red
                        : isApproved
                        ? Colors.green.shade800
                        : isPromo
                        ? Colors.orange
                        : isOrderUpdate
                        ? Colors.blue
                        : Colors.grey;
                    final iconData = isRejected
                        ? Icons.close_rounded
                        : isApproved
                        ? Icons.check_rounded
                        : isPromo
                        ? Icons.campaign_rounded
                        : isOrderUpdate
                        ? Icons.local_shipping_rounded
                        : Icons.notifications_none_rounded;

                    return GestureDetector(
                      onTap: () async {
                        // Mark as read
                        if (data['isRead'] != true) {
                          await notifDoc.reference.update({'isRead': true});
                        }

                        if (isApproved) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HomePageSeller(),
                            ),
                          );
                        } else if (isRejected) {
                          // Update juga "hasOpenedRejectedPage" kalau mau
                          await notifDoc.reference.update({'hasOpenedRejectedPage': true});
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ShopRejectedPage(
                                reason: data['body'] ?? '-',
                              ),
                            ),
                          );
                        } else if (isPromo) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                data['title'] ?? 'Promo',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                        } else if (isOrderUpdate) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                data['title'] ?? 'Update Pesanan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                              child: Icon(iconData, color: iconColor, size: 22),
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
                                      if (data['isRead'] == false ||
                                          data['isRead'] == null)
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

                                  // Date
                                  Text(
                                    data['timestamp'] != null
                                        ? DateFormat(
                                            'dd MMM, yyyy | HH:mm',
                                          ).format(
                                            (data['timestamp'] as Timestamp)
                                                .toDate(),
                                          )
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
            ),
    );
  }
}
