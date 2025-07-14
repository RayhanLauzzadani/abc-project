import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import halaman seller-mu di sini!
import 'package:abc_e_mart/seller/features/home/home_page_seller.dart'; // Ganti sesuai project

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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

                final notifications = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notifDoc = notifications[index];
                    final data = notifDoc.data() as Map<String, dynamic>;
                    final isCancel = data['type'] == 'rejected';

                    return GestureDetector(
                      onTap: () async {
                        // Tandai notif sudah dibaca
                        if (data['isRead'] != true) {
                          await notifDoc.reference.update({'isRead': true});
                        }

                        // Jika notif "approved", arahkan ke HomePageSeller
                        if (data['type'] == 'approved') {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomePageSeller()),
                            (route) => false,
                          );
                        }
                        // Kalau rejected, bisa tambahin showDialog kalau mau info
                        // else if (data['type'] == 'rejected') {
                        //   showDialog(
                        //     context: context,
                        //     builder: (_) => AlertDialog(
                        //       title: const Text('Pengajuan Ditolak'),
                        //       content: Text(data['body'] ?? 'Ajuan Anda ditolak.'),
                        //       actions: [
                        //         TextButton(
                        //           onPressed: () => Navigator.pop(context),
                        //           child: const Text('OK'),
                        //         ),
                        //       ],
                        //     ),
                        //   );
                        // }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCancel ? Colors.red.shade50 : Colors.green.shade50,
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
                                color: isCancel ? Colors.red.shade100 : Colors.green.shade100,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isCancel ? Icons.close_rounded : Icons.check_rounded,
                                color: isCancel ? Colors.red : Colors.green.shade800,
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
