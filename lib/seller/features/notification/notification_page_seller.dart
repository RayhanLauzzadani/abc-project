import 'dart:async'; // for unawaited

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// CHAT detail
import 'package:abc_e_mart/seller/features/chat/chat_detail_page.dart';
// Riwayat withdraw
import 'package:abc_e_mart/seller/features/wallet/withdraw_history_page.dart';
// Review order (tap "Pesanan Baru" masuk ke sini) — SESUAIKAN path/class jika berbeda
import 'package:abc_e_mart/seller/features/order/review_order/review_order_page.dart';

class NotificationPageSeller extends StatelessWidget {
  const NotificationPageSeller({super.key});

  // Jenis notif seller lama (tetap didukung)
  static const Set<String> legacySellerTypes = {
    'product_approved',
    'product_rejected',
    'store_approved',
    'store_rejected',
    'ad_approved',
    'withdrawal_approved',
    'withdrawal_rejected',
    'seller_withdraw_approved',
    'seller_withdraw_rejected',
    'wallet_withdraw_approved',
    'wallet_withdraw_rejected',
  };

  // Jenis notif pesanan baru (buyer → seller)
  static const String orderCreatedType = 'order_created';
  // Tambahan: pesanan selesai (buyer → seller)
  static const String orderDeliveredType = 'order_delivered';

  bool _isWithdrawType(String type) => type.contains('withdraw');
  bool _isOrderType(String type) => type == orderCreatedType;
  bool _isOrderDelivered(String type) => type == orderDeliveredType;

  Color _bgColorFor(String type) {
    if (type.contains('rejected')) return const Color(0xFFFFF2F2);
    if (type.contains('approved')) return const Color(0xFFEFF8F1);
    if (_isWithdrawType(type)) return const Color(0xFFEEF2FF);
    if (_isOrderType(type)) return const Color(0xFFFFF3E6);
    if (_isOrderDelivered(type)) return const Color(0xFFE9FFF0); // hijau muda untuk selesai
    if (type == 'chat_message') return const Color(0xFFEAF4FF);
    return const Color(0xFFF7F7F7);
  }

  Color _iconBgFor(String type) {
    if (type.contains('rejected')) return const Color(0xFFFFE1E1);
    if (type.contains('approved')) return const Color(0xFFD8F3DD);
    if (_isWithdrawType(type)) return const Color(0xFFDDE3FF);
    if (_isOrderType(type)) return const Color(0xFFFFE2C8);
    if (_isOrderDelivered(type)) return const Color(0xFFD8FCD8); // hijau muda
    if (type == 'chat_message') return const Color(0xFFD6E8FF);
    return const Color(0xFFE0E0E0);
  }

  Color _iconColorFor(String type) {
    if (type.contains('rejected')) return const Color(0xFFD32F2F);
    if (type.contains('approved')) return const Color(0xFF2E7D32);
    if (_isWithdrawType(type)) return const Color(0xFF1C55C0);
    if (_isOrderType(type)) return const Color(0xFFEF6C00);
    if (_isOrderDelivered(type)) return const Color(0xFF2E7D32); // hijau
    if (type == 'chat_message') return const Color(0xFF1976D2);
    return const Color(0xFF616161);
  }

  IconData _iconFor(String type) {
    if (type.contains('rejected')) return Icons.close_rounded;
    if (type.contains('approved')) return Icons.check_rounded;
    if (_isWithdrawType(type)) return Icons.account_balance_wallet_rounded;
    if (_isOrderType(type)) return Icons.shopping_bag_rounded;
    if (_isOrderDelivered(type)) return Icons.task_alt_rounded; // centang selesai
    if (type == 'chat_message') return Icons.chat_bubble_rounded;
    return Icons.notifications_none_rounded;
  }

  String _formatTs(dynamic ts) {
    final t = ts is Timestamp ? ts : null;
    if (t == null) return '-';
    return DateFormat('dd MMM, yyyy | HH:mm').format(t.toDate());
  }

  // Stream users/{uid}/notifications — tanpa orderBy (kompatibel createdAt/timestamp)
  Stream<QuerySnapshot<Map<String, dynamic>>> _userNotifStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .snapshots();
  }

  // Stream chatNotifications: pakai orderBy timestamp
  Stream<QuerySnapshot<Map<String, dynamic>>> _chatNotifStream(String uid) {
    return FirebaseFirestore.instance
        .collection('chatNotifications')
        .where('receiverId', isEqualTo: uid)
        .where('type', isEqualTo: 'chat_message')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Ambil timestamp unified dari user-notif
  Timestamp? _pickUserNotifTime(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final legacyTs = data['timestamp'];
    if (createdAt is Timestamp) return createdAt;
    if (legacyTs is Timestamp) return legacyTs;
    return null;
  }

  // Arsip (hilangkan dari list)
  Future<void> _archiveUserNotif({
    required String uid,
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(docId)
        .update({'archived': true});
  }

  // Tandai dibaca (hanya hilangkan badge New)
  Future<void> _markUserRead({
    required String uid,
    required String docId,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(docId)
        .update({'isRead': true});
  }

  Future<void> _markChatRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('chatNotifications')
        .doc(docId)
        .update({'isRead': true});
  }

  // Body rapi untuk order_created
  String _prettyOrderBody(Map<String, dynamic> data) {
    final invoice = (data['invoiceId'] as String?)?.trim();
    if (invoice != null && invoice.isNotEmpty) {
      return 'Ada pesanan baru (Invoice: $invoice). Mohon ditinjau.';
    }
    final body = (data['body'] as String?) ?? '';
    final cleaned = body.replaceAll(RegExp(r'#[^\s]+'), '').trim();
    if (cleaned.isEmpty || cleaned.length < 10) {
      return 'Ada pesanan baru. Mohon ditinjau.';
    }
    return cleaned;
  }

  // Body rapi untuk order_delivered (saldo masuk)
  String _prettyDeliveredBody(Map<String, dynamic> data) {
    final invoice = (data['invoiceId'] as String?)?.trim();
    final amt = data['amountToSeller'];
    final nominal = (amt is num)
        ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amt)
        : null;

    if (invoice != null && invoice.isNotEmpty) {
      return nominal != null
          ? 'Pesanan (Invoice: $invoice) selesai. Saldo $nominal telah masuk ke dompet Anda.'
          : 'Pesanan (Invoice: $invoice) selesai. Saldo telah masuk.';
    }
    return nominal != null
        ? 'Pesanan selesai. Saldo $nominal telah masuk ke dompet Anda.'
        : 'Pesanan selesai. Saldo telah masuk ke dompet Anda.';
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
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2056D3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
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
              if (userSnap.hasError || chatSnap.hasError) {
                return Center(
                  child: Text('Gagal memuat notifikasi',
                      style: GoogleFonts.dmSans(fontSize: 15, color: Colors.red)),
                );
              }

              final List<Map<String, dynamic>> all = [];

              // Kumpulkan user notifications
              if (userSnap.hasData) {
                for (final doc in userSnap.data!.docs) {
                  final data = doc.data();
                  final type = (data['type']?.toString() ?? '').toLowerCase();
                  final isLegacy = legacySellerTypes.contains(type);
                  final isOrder = type == orderCreatedType;
                  final isDelivered = type == orderDeliveredType;
                  final archived = data['archived'] == true;
                  if ((isLegacy || isOrder || isDelivered) && !archived) {
                    all.add({
                      ...data,
                      '_id': doc.id,
                      '_source': 'user',
                      '_ts': _pickUserNotifTime(data),
                    });
                  }
                }
              }

              // Kumpulkan chat notifications
              if (chatSnap.hasData) {
                for (final doc in chatSnap.data!.docs) {
                  final data = doc.data();
                  all.add({
                    ...data,
                    '_id': doc.id,
                    '_source': 'chat',
                    '_ts': (data['timestamp'] is Timestamp) ? data['timestamp'] : null,
                  });
                }
              }

              // Sort desc by time
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

              // === penting: pakai root context yang stabil untuk navigator/snackbar ===
              return Builder(
                builder: (rootCtx) {
                  final messenger = ScaffoldMessenger.of(rootCtx);
                  final navigator = Navigator.of(rootCtx);

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: all.length,
                    itemBuilder: (context, i) {
                      final data = all[i];
                      final type = (data['type'] ?? '').toString().toLowerCase();
                      final isChat = type == 'chat_message';
                      final bgColor = _bgColorFor(type);
                      final iconBg = _iconBgFor(type);
                      final iconColor = _iconColorFor(type);
                      final iconData = _iconFor(type);
                      final tsText = _formatTs(data['_ts']);
                      final invoice = (data['invoiceId'] as String?)?.trim();

                      // Title & body
                      String title =
                          (data['title'] as String?) ?? (isChat ? 'Pesan Baru' : 'Notifikasi');
                      String body = (data['body'] as String?) ?? '';
                      if (_isOrderType(type)) {
                        title = 'Pesanan Baru';
                        body = _prettyOrderBody(data);
                      } else if (_isOrderDelivered(type)) {
                        title = 'Pesanan Selesai';
                        body = _prettyDeliveredBody(data);
                      }

                      // Badge NEW: pakai isRead != true
                      final bool showNewBadge = (data['isRead'] != true);

                      // ---- handler tap (mark read TANPA await lalu navigate) ----
                      Future<void> _handleTap() async {
                        if (data['_source'] == 'user') {
                          unawaited(_markUserRead(uid: user.uid, docId: data['_id']));
                        } else {
                          unawaited(_markChatRead(data['_id']));
                        }

                        if (_isWithdrawType(type)) {
                          navigator.push(MaterialPageRoute(
                            builder: (_) => const WithdrawHistoryPageSeller(),
                          ));
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
                              navigator.push(MaterialPageRoute(
                                builder: (_) => SellerChatDetailPage(
                                  chatId: chatId,
                                  buyerId: chatData['buyerId'] ?? '',
                                  buyerName: chatData['buyerName'] ?? 'Pembeli',
                                ),
                              ));
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Data chat tidak ditemukan.')),
                              );
                            }
                          }
                          return;
                        }

                        if (_isOrderType(type)) {
                          final orderId = (data['orderId'] as String?) ?? '';
                          if (orderId.isNotEmpty) {
                            navigator.push(MaterialPageRoute(
                              builder: (_) => ReviewOrderPage(orderId: orderId),
                            ));
                          } else {
                            showDialog(
                              context: rootCtx,
                              builder: (_) => const AlertDialog(
                                title: Text('Pesanan Baru'),
                                content: Text('OrderId tidak ditemukan.'),
                              ),
                            );
                          }
                          return;
                        }

                        if (_isOrderDelivered(type)) {
                          final amt = data['amountToSeller'];
                          final nominal = (amt is num)
                              ? NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(amt)
                              : null;

                          showDialog(
                            context: rootCtx,
                            builder: (_) => AlertDialog(
                              title: const Text('Pesanan Selesai'),
                              content: Text(
                                nominal != null
                                    ? 'Saldo sebesar $nominal telah masuk ke dompet Anda.'
                                    : 'Pesanan selesai. Saldo telah masuk ke dompet Anda.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => navigator.pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        showDialog(
                          context: rootCtx,
                          builder: (_) => AlertDialog(
                            title: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              body,
                              style: const TextStyle(fontSize: 15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => navigator.pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }

                      return Dismissible(
                        key: ValueKey('${data['_source']}_${data['_id']}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          color: Colors.green.shade600,
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          if (data['_source'] == 'user') {
                            await _archiveUserNotif(uid: user.uid, docId: data['_id']);
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Notifikasi diarsipkan')),
                            );
                            return true;
                          } else {
                            await _markChatRead(data['_id']);
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Pesan ditandai dibaca')),
                            );
                            return true;
                          }
                        },
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _handleTap,
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withOpacity(0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon besar
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: iconBg,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(iconData, color: iconColor, size: 30),
                                ),
                                const SizedBox(width: 12),
                                // Texts
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16.5,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          if (showNewBadge)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF22C55E),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: const Text(
                                                'New',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(tsText,
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 12.5, color: Colors.black54)),
                                          if (invoice != null && invoice.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: Colors.black26,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Invoice: $invoice',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 12.5,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _isOrderType(type)
                                            ? _prettyOrderBody(data)
                                            : (_isOrderDelivered(type)
                                                ? _prettyDeliveredBody(data)
                                                : (data['body'] ?? '-')),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14.5,
                                          color: const Color(0xFF1F1F1F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
