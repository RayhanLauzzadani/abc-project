import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Pesanan Dibatalkan!',
        'message':
            'Anda telah membatalkan pesanan di Burger Hut. Kami mohon maaf atas ketidaknyamanan ini. Kami akan berusaha meningkatkan layanan kami di lain waktu 🤔',
        'timestamp': DateTime.now(),
        'isRead': false,
        'type': 'cancel',
      },
      {
        'title': 'Pesanan Terkirim!',
        'message':
            'Anda telah melakukan pemesanan di Burger Hut dan membayar \$24. Makanan Anda akan segera tiba. Nikmati layanan kami 😋',
        'timestamp': DateTime.now(),
        'isRead': false,
        'type': 'success',
      },
      {
        'title': 'Pesanan Dibatalkan!',
        'message':
            'Anda telah membatalkan pesanan di Burger Hut. Kami mohon maaf atas ketidaknyamanan ini. Kami akan berusaha meningkatkan layanan kami di lain waktu 🤔',
        'timestamp': DateTime.now(),
        'isRead': true,
        'type': 'cancel',
      },
      {
        'title': 'Pesanan Terkirim!',
        'message':
            'Anda telah melakukan pemesanan di Burger Hut dan membayar \$24. Makanan Anda akan segera tiba. Nikmati layanan kami 😋',
        'timestamp': DateTime.now(),
        'isRead': true,
        'type': 'success',
      },
    ];

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isCancel = notif['type'] == 'cancel';

          return Container(
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
                              notif['title'],
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (notif['isRead'] == false)
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
                        DateFormat('dd MMM, yyyy | HH:mm').format(notif['timestamp']),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Message
                      Text(
                        notif['message'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
