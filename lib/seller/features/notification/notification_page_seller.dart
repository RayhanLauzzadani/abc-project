import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPageSeller extends StatelessWidget {
  const NotificationPageSeller({super.key});

  // Daftar tipe notif yang ditujukan untuk seller
  static const Set<String> sellerTypes = {
    'product_approved',
    'product_rejected',
    'store_approved',
    'store_rejected',
    // Tambah lagi jika ada tipe baru untuk seller
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

                // Hanya notif yang tipenya ditujukan ke seller
                final notifications = snapshot.data!.docs.where((notifDoc) {
                  final data = notifDoc.data() as Map<String, dynamic>;
                  final type = data['type']?.toString() ?? '';
                  return sellerTypes.contains(type);
                }).toList();

                if (notifications.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada notifikasi untuk seller.",
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
                    final isRejected = type.contains('rejected');
                    final isApproved = type.contains('approved');

                    // Warna notif
                    final bgColor = isRejected
                        ? Colors.red.shade50
                        : isApproved
                            ? Colors.green.shade50
                            : Colors.grey.shade100;
                    final iconBg = isRejected
                        ? Colors.red.shade100
                        : isApproved
                            ? Colors.green.shade100
                            : Colors.grey.shade300;
                    final iconColor = isRejected
                        ? Colors.red
                        : isApproved
                            ? Colors.green.shade800
                            : Colors.grey;
                    final iconData = isRejected
                        ? Icons.close_rounded
                        : isApproved
                            ? Icons.check_rounded
                            : Icons.notifications_none_rounded;

                    return GestureDetector(
                      onTap: () async {
                        // Tandai notif sudah dibaca
                        if (data['isRead'] != true) {
                          await notifDoc.reference.update({'isRead': true});
                        }

                        if (isRejected) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                data['title'] ?? 'Pengajuan Ditolak',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                data['body'] ?? 'Ajuan Anda ditolak.',
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
                        } else if (isApproved) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                data['title'] ?? 'Pengajuan Disetujui',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                data['body'] ?? 'Ajuan Anda disetujui!',
                                style: const TextStyle(fontSize: 15),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        }
                        // else: kamu bisa tambah handle notif lain jika perlu
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
            ),
    );
  }
}
