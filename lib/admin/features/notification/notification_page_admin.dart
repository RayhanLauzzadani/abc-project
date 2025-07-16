import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_detail_page.dart';

class NotificationPageAdmin extends StatelessWidget {
  const NotificationPageAdmin({super.key});

  // Helper for card icon bg & icon color based on notif type
  Map<String, dynamic> _notifStyle(String? title) {
    if (title == null) {
      return {
        "svg": null,
        "iconColor": const Color(0xFFCCCCCC),
        "bgColor": const Color(0xFFEDEDED),
      };
    }
    final lower = title.toLowerCase();
    if (lower.contains('toko')) {
      return {
        "svg": 'assets/icons/store.svg',
        "iconColor": const Color(0xFF28A745),
        "bgColor": const Color(0xFFEDF9F1),
      };
    } else if (lower.contains('produk')) {
      return {
        "svg": 'assets/icons/box.svg',
        "iconColor": const Color(0xFF1C55C0),
        "bgColor": const Color(0x331C55C0), // 20% opacity
      };
    } else if (lower.contains('iklan')) {
      return {
        "svg": 'assets/icons/megaphone.svg',
        "iconColor": const Color(0xFFB95FD0),
        "bgColor": const Color(0x33B95FD0), // 20% opacity
      };
    }
    return {
      "svg": null,
      "iconColor": const Color(0xFFCCCCCC),
      "bgColor": const Color(0xFFEDEDED),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Header (bukan appbar biar full custom)
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18), // Atas ke header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 0, top: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C55C0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Notifikasi Admin',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // List notif
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('admin_notifications')
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 23),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notifDoc = notifications[index];
                      final data = notifDoc.data() as Map<String, dynamic>;
                      final styles = _notifStyle(data['title']);

                      return GestureDetector(
                        onTap: () async {
                          // Tandai notif sudah dibaca
                          if (data['isRead'] != true) {
                            await notifDoc.reference.update({'isRead': true});
                          }
                          // Navigasi ke detail pengajuan toko jika ada shopApplicationId
                          if (data['shopApplicationId'] != null &&
                              (data['shopApplicationId'] as String).isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminStoreApprovalDetailPage(
                                  docId: data['shopApplicationId'],
                                  approvalData: null,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SVG icon with custom bg & color
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: styles['bgColor'],
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: styles['svg'] != null
                                    ? SvgPicture.asset(
                                        styles['svg'],
                                        width: 30,
                                        height: 30,
                                        color: styles['iconColor'],
                                      )
                                    : Icon(
                                        Icons.notifications,
                                        color: Colors.grey.shade400,
                                        size: 32,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title + badge
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['title'] ?? '-',
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: const Color(0xFF373E3C),
                                            ),
                                          ),
                                        ),
                                        if (data['isRead'] == false ||
                                            data['isRead'] == null)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 9),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF28A745),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: const Text(
                                              'New',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Date
                                    Text(
                                      data['timestamp'] != null
                                          ? DateFormat(
                                                  'dd MMM, yyyy  |  HH:mm')
                                              .format((data['timestamp']
                                                      as Timestamp)
                                                  .toDate())
                                          : '-',
                                      style: GoogleFonts.dmSans(
                                        color: const Color(0xFF747474),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Message
                                    Text(
                                      data['body'] ?? '-',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        color: const Color(0xFF222222),
                                      ),
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
            ),
          ],
        ),
      ),
    );
  }
}
