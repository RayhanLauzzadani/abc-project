import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Detail approval toko
import 'package:abc_e_mart/admin/features/approval/store/admin_store_approval_detail_page.dart';
// Detail approval payment (topup & withdraw)
import 'package:abc_e_mart/admin/features/approval/payment/admin_payment_approval_detail_page.dart';
// Detail approval iklan
import 'package:abc_e_mart/admin/features/approval/ad/admin_ad_approval_detail_page.dart';
import 'package:abc_e_mart/seller/data/models/ad.dart';

class NotificationPageAdmin extends StatelessWidget {
  const NotificationPageAdmin({super.key});

  /// Style ikon berdasarkan `type` atau fallback `title`
  Map<String, dynamic> _notifStyle({String? type, String? title}) {
    final lowerType = (type ?? '').toLowerCase();
    final lowerTitle = (title ?? '').toLowerCase();

    // ---- Payment: Topup (oranye)
    if (lowerType.startsWith('wallet_topup') || lowerTitle.contains('isi saldo')) {
      return {
        "svg": null,
        "iconData": Icons.account_balance_wallet_rounded,
        "iconColor": const Color(0xFFF4C21B),
        "bgColor": const Color(0x33F4C21B),
      };
    }

    // ---- Payment: Withdraw (biru/indigo)
    if (lowerType.startsWith('wallet_withdraw') ||
        lowerType.startsWith('seller_withdraw') ||
        lowerTitle.contains('tarik saldo') ||
        lowerTitle.contains('pencairan')) {
      return {
        "svg": null,
        "iconData": Icons.account_balance_wallet_rounded,
        "iconColor": const Color(0xFF1C55C0),
        "bgColor": const Color(0x331C55C0),
      };
    }

    // ---- Toko
    if (lowerTitle.contains('toko')) {
      return {
        "svg": 'assets/icons/store.svg',
        "iconData": null,
        "iconColor": const Color(0xFF28A745),
        "bgColor": const Color(0xFFEDF9F1),
      };
    }

    // ---- Produk
    if (lowerTitle.contains('produk')) {
      return {
        "svg": 'assets/icons/box.svg',
        "iconData": null,
        "iconColor": const Color(0xFF1C55C0),
        "bgColor": const Color(0x331C55C0),
      };
    }

    // ---- Iklan
    if (lowerTitle.contains('iklan')) {
      return {
        "svg": 'assets/icons/megaphone.svg',
        "iconData": null,
        "iconColor": const Color(0xFFB95FD0),
        "bgColor": const Color(0x33B95FD0),
      };
    }

    // Default
    return {
      "svg": null,
      "iconData": Icons.notifications,
      "iconColor": const Color(0xFF9AA0A6),
      "bgColor": const Color(0xFFEDEDED),
    };
  }

  bool _looksLikeAd(Map<String, dynamic> data) {
    final type = (data['type'] as String?)?.toLowerCase() ?? '';
    final title = (data['title'] as String?)?.toLowerCase() ?? '';
    return type.contains('ad') || type.contains('iklan') || title.contains('iklan');
  }

  String? _extractAdId(Map<String, dynamic> data) {
    // coba ambil dari beberapa kemungkinan field
    final keys = [
      'adApplicationId',
      'adId',
      'adDocId',
      'docId',
      'applicationId',
    ];
    for (final k in keys) {
      final v = data[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  Future<void> _openAdById(BuildContext context, String adId) async {
    // loader ringan
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final snap = await FirebaseFirestore.instance
          .collection('adsApplication')
          .doc(adId)
          .get();

      Navigator.of(context, rootNavigator: true).pop(); // close loader

      if (!snap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajuan iklan tidak ditemukan.')),
        );
        return;
      }
      final ad = AdApplication.fromFirestore(snap);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminAdApprovalDetailPage(ad: ad)),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka ajuan iklan: $e')),
      );
    }
  }

  Future<void> _openLatestPendingAdFallback(BuildContext context) async {
    // loader ringan
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final qs = await FirebaseFirestore.instance
          .collection('adsApplication')
          .where('status', whereIn: ['Menunggu', 'menunggu', 'pending'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      Navigator.of(context, rootNavigator: true).pop(); // close loader

      if (qs.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada ajuan iklan berstatus menunggu.')),
        );
        return;
      }

      final ad = AdApplication.fromFirestore(qs.docs.first);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminAdApprovalDetailPage(ad: ad)),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat ajuan iklan: $e')),
      );
    }
  }

  Future<void> _handleTap({
    required BuildContext context,
    required DocumentSnapshot notifDoc,
    required Map<String, dynamic> data,
  }) async {
    // Tandai read
    if (data['isRead'] != true) {
      await notifDoc.reference.update({'isRead': true});
    }

    final String type = (data['type'] as String?)?.toLowerCase() ?? '';
    final String title = (data['title'] as String?) ?? '';
    final String? shopAppId = data['shopApplicationId'] as String?;
    final String? paymentAppId = data['paymentAppId'] as String?;

    // 1) Payment
    if (paymentAppId != null && paymentAppId.isNotEmpty) {
      PaymentRequestType requestType;
      if (type.startsWith('wallet_topup') || title.toLowerCase().contains('isi saldo')) {
        requestType = PaymentRequestType.topUp;
      } else if (type.startsWith('wallet_withdraw') ||
          type.startsWith('seller_withdraw') ||
          title.toLowerCase().contains('tarik saldo') ||
          title.toLowerCase().contains('pencairan')) {
        requestType = PaymentRequestType.withdrawal;
      } else {
        requestType = PaymentRequestType.topUp;
      }

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminPaymentApprovalDetailPage(
            applicationId: paymentAppId,
            type: requestType,
          ),
        ),
      );
      return;
    }

    // 2) Toko
    if (shopAppId != null && shopAppId.isNotEmpty) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminStoreApprovalDetailPage(
            docId: shopAppId,
            approvalData: null,
          ),
        ),
      );
      return;
    }

    // 3) Iklan
    if (_looksLikeAd(data)) {
      final adId = _extractAdId(data);
      if (adId != null) {
        await _openAdById(context, adId);
      } else {
        // fallback: buka latest pending ad agar tetap responsif
        await _openLatestPendingAdFallback(context);
      }
      return;
    }

    // 4) Default: tidak ada action yang cocok
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak ada aksi untuk notifikasi ini.')),
    );
  }

  // ====== FILTER UTAMA ADMIN ======
  // Buang notifikasi hasil keputusan (approved/rejected) – hanya tampilkan pengajuan.
  bool _visibleForAdmin(Map<String, dynamic> m) {
    final t = (m['type'] ?? '').toString().toLowerCase().trim();
    final title = (m['title'] ?? '').toString().toLowerCase();

    const blockedTypes = {
      // withdraw/topup
      'withdrawal_approved',
      'withdrawal_rejected',
      'seller_withdraw_approved',
      'seller_withdraw_rejected',
      'wallet_withdraw_approved',
      'wallet_withdraw_rejected',
      'wallet_withdrawal_approved',
      'wallet_withdrawal_rejected',
      'wallet_topup_approved',
      'wallet_topup_rejected',
      // ads
      'ad_approved',
      'ad_rejected',
      'ads_approved',
      'ads_rejected',
    };

    final looksLikeDecision =
        (title.contains('pencairan') &&
            (title.contains('disetujui') || title.contains('ditolak') || title.contains('diterima'))) ||
        (title.contains('isi saldo') &&
            (title.contains('disetujui') || title.contains('ditolak') || title.contains('diterima'))) ||
        (title.contains('iklan') &&
            (title.contains('disetujui') || title.contains('ditolak') || title.contains('diterima')));

    if (blockedTypes.contains(t) || looksLikeDecision) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.07),
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

            // ===== List Notifikasi =====
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

                  final docs = snapshot.data!.docs.where((d) {
                    final m = d.data() as Map<String, dynamic>;
                    return _visibleForAdmin(m);
                  }).toList();

                  if (docs.isEmpty) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 23),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final notifDoc = docs[index];
                      final data = notifDoc.data() as Map<String, dynamic>;

                      final styles = _notifStyle(
                        type: data['type'] as String?,
                        title: data['title'] as String?,
                      );

                      final ts = data['timestamp'];
                      final dateText = (ts is Timestamp)
                          ? DateFormat('dd MMM, yyyy  |  HH:mm').format(ts.toDate())
                          : '-';

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _handleTap(
                          context: context,
                          notifDoc: notifDoc,
                          data: data,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.05),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon bulat
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: styles['bgColor'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: (styles['svg'] as String?) != null
                                    ? SvgPicture.asset(
                                        styles['svg'] as String,
                                        width: 30,
                                        height: 30,
                                        color: styles['iconColor'] as Color,
                                      )
                                    : Icon(
                                        (styles['iconData'] as IconData?) ?? Icons.notifications,
                                        color: styles['iconColor'] as Color,
                                        size: 30,
                                      ),
                              ),
                              const SizedBox(width: 16),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title + badge New
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            (data['title'] as String?) ?? '-',
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: const Color(0xFF373E3C),
                                            ),
                                          ),
                                        ),
                                        if (data['isRead'] == false || data['isRead'] == null)
                                          Container(
                                            margin: const EdgeInsets.only(left: 9),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF28A745),
                                              borderRadius: BorderRadius.circular(14),
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
                                      dateText,
                                      style: GoogleFonts.dmSans(
                                        color: const Color(0xFF747474),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Body
                                    Text(
                                      (data['body'] as String?) ?? '-',
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
