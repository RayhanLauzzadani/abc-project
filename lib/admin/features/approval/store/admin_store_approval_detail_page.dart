import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/admin/widgets/admin_dual_action_buttons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/admin/data/models/admin_store_data.dart';
import 'package:abc_e_mart/admin/widgets/success_dialog.dart';
import 'package:abc_e_mart/admin/widgets/admin_reject_reason_page.dart';

class AdminStoreApprovalDetailPage extends StatelessWidget {
  final String docId;
  final AdminStoreApprovalData? approvalData;

  const AdminStoreApprovalDetailPage({
    super.key,
    required this.docId,
    this.approvalData,
  });

  // Penolakan
  Future<void> _onReject(BuildContext context) async {
    final reason = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => AdminRejectReasonPage()),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        await _sendRejectionMessage(context, reason);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Ajuan toko ditolak!")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _sendRejectionMessage(
    BuildContext context,
    String reason,
  ) async {
    final shopDoc = FirebaseFirestore.instance
        .collection('shopApplications')
        .doc(docId);
    final shopData = await shopDoc.get();
    final buyerId = shopData.data()?['owner']?['uid'] ?? '';

    await shopDoc.update({
      'status': 'rejected',
      'rejectionReason': reason,
      'rejectedAt': FieldValue.serverTimestamp(),
    });

    if (buyerId != '') {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(buyerId)
          .collection('notifications')
          .add({
            'title': 'Pengajuan Toko Ditolak',
            'body': reason,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': 'store_rejected',
          });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const SuccessDialog(message: "Ajuan Toko Berhasil Ditolak"),
    );
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context, rootNavigator: true).pop();
    await Future.delayed(const Duration(milliseconds: 200));
    Navigator.of(context).pop();
  }

  // Persetujuan
  Future<void> _onAccept(BuildContext context) async {
    final shopDoc = FirebaseFirestore.instance
        .collection('shopApplications')
        .doc(docId);

    try {
      await shopDoc.update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      final shopDataSnap = await shopDoc.get();
      final shopData = shopDataSnap.data();
      final buyerId = shopData?['owner']?['uid'] ?? '';

      if (buyerId != '') {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(buyerId);

        // ==== BUAT stores/{autoId} ====
        final storesRef = FirebaseFirestore.instance.collection('stores');
        final storeMap = {
        'ownerId': buyerId,
        'name': shopData?['shopName'] ?? "",
        'logoUrl': shopData?['logoUrl'] ?? "",
        'address': shopData?['address'] ?? "",
        'isOpen': true,
        'description': shopData?['description'] ?? "",
        'createdAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'ratingCount': 0,
        'totalSales': 0,
        'phone': shopData?['phone'] ?? "",
        'isOnline': true,
        'lastLogin': FieldValue.serverTimestamp(),
        'latitude': shopData?['latitude'] ?? 0.0,
        'longitude': shopData?['longitude'] ?? 0.0,
      };

        // ADD store & dapatkan storeId
        final newStoreDoc = await storesRef.add(storeMap);
        final storeId = newStoreDoc.id;

        // ==== Update user: role, storeId, storeName ====
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userSnap = await transaction.get(userRef);
          List<dynamic> currentRoles = [];
          if (userSnap.exists && userSnap.data()!.containsKey('role')) {
            currentRoles = List.from(userSnap['role'] ?? []);
          }
          if (!currentRoles.contains('seller')) {
            currentRoles.add('seller');
          }
          if (!currentRoles.contains('buyer')) {
            currentRoles.insert(0, 'buyer');
          }
          transaction.update(userRef, {
            'role': currentRoles,
            'storeName': shopData?['shopName'] ?? "",
            'storeId': storeId,
          });
        });

        // Notifikasi ke user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(buyerId)
            .collection('notifications')
            .add({
              'title': 'Pengajuan Toko Disetujui',
              'body':
                  'Selamat, pengajuan toko Anda telah disetujui! Sekarang toko Anda sudah aktif.',
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
              'type': 'store_approved',
              'storeId': storeId, // <- Tambahkan ini!
            });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SuccessDialog(message: "Ajuan Toko Diterima"),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shopApplications')
                  .doc(docId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Data tidak ditemukan'));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final owner = data['owner'] ?? {};
                final ktpUrl = data['ktpUrl'] ?? '';
                final logoUrl = data['logoUrl'] ?? '';
                final shopName = data['shopName'] ?? '-';
                final description = data['description'] ?? '-';
                final address = data['address'] ?? '-';
                final phone = data['phone'] ?? '-';
                final submittedAt = data['submittedAt'];
                String dateStr = '-';
                if (submittedAt != null && submittedAt is Timestamp) {
                  final dt = submittedAt.toDate();
                  dateStr =
                      "${dt.day.toString().padLeft(2, '0')}/"
                      "${dt.month.toString().padLeft(2, '0')}/"
                      "${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 110,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(32),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 37,
                              height: 37,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Detail Ajuan",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: const Color(0xFF232323),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        "Tanggal Pengajuan",
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateStr,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6D6D6D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: const Color(0xFFE5E7EB),
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 22),

                      // Data Diri Pemilik Toko
                      Text(
                        "Data Diri Pemilik Toko",
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 17),
                      // Foto KTP
                      Text(
                        "Foto KTP",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ktpUrl.isNotEmpty
                                  ? Image.network(
                                      ktpUrl,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.image_outlined,
                                      color: Color(0xFFDADADA),
                                      size: 22,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ktpUrl.isNotEmpty
                                        ? "KTP.jpg"
                                        : "Belum ada file",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: const Color(0xFF373E3C),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFBDBDBD),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Nama
                      Text(
                        "Nama",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        owner['nama'] ?? '-',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 13),
                      // NIK
                      Text(
                        "NIK",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        owner['nik'] ?? '-',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 13),
                      // Nama Bank
                      Text(
                        "Nama Bank",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        owner['bank'] ?? '-',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 13),
                      // Nomor Rekening
                      Text(
                        "Nomor Rekening",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        owner['rek'] ?? '-',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(
                        color: const Color(0xFFE5E7EB),
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 18),
                      // Data Toko
                      Text(
                        "Data Toko",
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 17),
                      // Logo toko
                      Text(
                        "Logo Toko",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFDADADA)),
                        ),
                        child: logoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  logoUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: SvgPicture.asset(
                                  'assets/icons/store.svg',
                                  width: 36,
                                  height: 36,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFDADADA),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      // Nama Toko
                      Text(
                        "Nama Toko",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shopName,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 13),
                      // Deskripsi Singkat Toko
                      Text(
                        "Deskripsi Singkat Toko",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 13),
                      // Alamat Lengkap Toko
                      Text(
                        "Alamat Lengkap Toko",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 13),
                      // Nomor HP
                      Text(
                        "Nomor HP",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF232323),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                );
              },
            ),
            // Sticky Button Area
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -3),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: AdminDualActionButtons(
                  onReject: () => _onReject(context),
                  onAccept: () => _onAccept(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
