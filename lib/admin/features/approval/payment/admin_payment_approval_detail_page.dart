import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:abc_e_mart/admin/widgets/admin_dual_action_buttons.dart';
import 'package:abc_e_mart/admin/widgets/success_dialog.dart';
import 'package:abc_e_mart/admin/widgets/admin_reject_reason_page.dart';
import 'package:abc_e_mart/admin/data/services/payment_application_service.dart';

enum PaymentRequestType { topUp, withdrawal }

class AdminPaymentApprovalDetailPage extends StatefulWidget {
  final String applicationId;
  final PaymentRequestType type;

  const AdminPaymentApprovalDetailPage({
    super.key,
    required this.applicationId,
    required this.type,
  });

  @override
  State<AdminPaymentApprovalDetailPage> createState() =>
      _AdminPaymentApprovalDetailPageState();
}

class _AdminPaymentApprovalDetailPageState
    extends State<AdminPaymentApprovalDetailPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _adminProof;

  bool get _hasProof => _adminProof != null;

  Future<void> _pickAdminProof() async {
    try {
      final x =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
      if (x == null) return;
      final ext = x.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Format tidak didukung. Gunakan JPG/JPEG/PNG.', style: GoogleFonts.dmSans())),
        );
        return;
      }
      if (await x.length() > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ukuran file maksimal 2 MB.', style: GoogleFonts.dmSans())),
        );
        return;
      }
      setState(() => _adminProof = x);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e', style: GoogleFonts.dmSans())),
      );
    }
  }

  void _removeAdminProof() => setState(() => _adminProof = null);

  String _rp(num n) {
    final s = n.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final r = s.length - i;
      b.write(s[i]);
      if (r > 1 && r % 3 == 1) b.write('.');
    }
    return 'Rp $b';
  }

  Future<void> _onVerify(Map<String, dynamic> app) async {
    final realType = (app['type'] as String?) ?? (widget.type == PaymentRequestType.topUp ? 'topup' : 'withdrawal');
    final isTopUp = realType == 'topup';

    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      if (isTopUp) {
        await PaymentApplicationService.instance.approveTopUpApplication(
          applicationId: widget.applicationId,
        );
      } else {
        if (!_hasProof) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unggah bukti pembayaran terlebih dahulu.', style: GoogleFonts.dmSans())),
          );
          return;
        }
        final proof = await PaymentApplicationService.instance.uploadProof(
          file: File(_adminProof!.path),
          filenameHint: 'withdraw_${widget.applicationId}.${_adminProof!.name.split('.').last}',
          ownerId: app['ownerId'] as String?,
        );
        await PaymentApplicationService.instance.approveWithdrawalApplication(
          applicationId: widget.applicationId,
          adminProof: proof,
        );
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessDialog(
          message: isTopUp ? "Pengisian Saldo Berhasil Diterima" : "Pencairan Saldo Berhasil",
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal verifikasi: $e', style: GoogleFonts.dmSans())),
      );
    }
  }

  Future<void> _onReject(Map<String, dynamic> app) async {
    final realType = (app['type'] as String?) ?? (widget.type == PaymentRequestType.topUp ? 'topup' : 'withdrawal');
    final isTopUp = realType == 'topup';

    final reason = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AdminRejectReasonPage()),
    );
    if (reason == null || reason.trim().isEmpty) return;

    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      if (isTopUp) {
        await PaymentApplicationService.instance.rejectTopUpApplication(
          applicationId: widget.applicationId,
          reason: reason,
        );
      } else {
        await PaymentApplicationService.instance.rejectWithdrawalApplication(
          applicationId: widget.applicationId,
          reason: reason,
        );
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessDialog(
          message: isTopUp ? "Pengisian Saldo Berhasil Ditolak" : "Pencairan Saldo Berhasil Ditolak",
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak: $e', style: GoogleFonts.dmSans())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('paymentApplications')
              .doc(widget.applicationId)
              .get(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || !snap.hasData || !snap.data!.exists) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Gagal memuat ajuan.', style: GoogleFonts.dmSans(color: Colors.red)),
                ),
              );
            }

            final app = snap.data!.data()!;
            final isTopUp = (app['type'] as String? ?? '') == 'topup';
            final ts = (app['submittedAt'] as Timestamp?)?.toDate();
            final submittedAt = ts == null
                ? '-'
                : DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(ts);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 37,
                          height: 37,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C55C0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text("Detail Ajuan",
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: const Color(0xFF232323))),
                    ],
                  ),

                  const SizedBox(height: 28),
                  _sectionTitle("Tanggal Pengajuan"),
                  const SizedBox(height: 3),
                  _plainText(submittedAt),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),
                  const SizedBox(height: 22),

                  _sectionTitle(
                      isTopUp ? "Data Pengisian Saldo" : "Data Pencairan Saldo"),
                  const SizedBox(height: 16),

                  if (isTopUp) ...[
                    _label("Bukti Pembayaran"),
                    const SizedBox(height: 6),
                    _fileChip(
                      (app['proof']?['name'] as String?) ?? 'bukti.jpg',
                      app['proof']?['bytes'] == null
                          ? '—'
                          : '${((app['proof']['bytes'] as num) / (1024 * 1024)).toStringAsFixed(1)} MB',
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () {
                        final url = app['proof']?['url'] as String?;
                        if (url == null) return;
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.network(url, fit: BoxFit.contain),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _label("Nama Pelanggan"),
                    const SizedBox(height: 4),
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: app['buyerId'] == null
                          ? null
                          : FirebaseFirestore.instance
                              .collection('users')
                              .doc(app['buyerId'])
                              .get(),
                      builder: (_, userSnap) {
                        final m = userSnap.data?.data();
                        final name = (m?['displayName'] as String?) ??
                                    (m?['name'] as String?) ??
                                    (app['buyerEmail'] as String? ?? '-');
                        return _plainText(name);
                      },
                    ),
                    const SizedBox(height: 16),

                    _label("Metode Pembayaran"),
                    const SizedBox(height: 4),
                    _plainText(app['method'] as String? ?? '-'),
                    const SizedBox(height: 18),

                    _label("Detail Pembayaran"),
                    const SizedBox(height: 8),
                    _kvBox(items: [
                      _KV("Jumlah Pengisian Saldo", _rp((app['amount'] as num?) ?? 0)),
                      _KV("Biaya Admin", _rp((app['fee'] as num?) ?? 0)),
                    ]),
                    const SizedBox(height: 8),
                    _emphasizedTotal("Total Dibayar Pembeli", _rp((app['totalPaid'] as num?) ?? 0)),
                    const SizedBox(height: 40),
                  ] else ...[
                    // WITHDRAWAL
                    _label("Nama Pemilik Rekening"),
                    const SizedBox(height: 4),
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: app['ownerId'] == null
                          ? null
                          : FirebaseFirestore.instance
                              .collection('users')
                              .doc(app['ownerId'])
                              .get(),
                      builder: (_, uSnap) {
                        final m  = uSnap.data?.data();          // <-- perbaikan di sini
                        final nm = (m?['displayName'] as String?) ??
                                  (m?['name'] as String?) ??
                                  '-';
                        return _plainText(nm);
                      },
                    ),
                    const SizedBox(height: 12),

                    _label("Nama Bank"),
                    const SizedBox(height: 4),
                    _plainText(app['bankName'] as String? ?? '-'),
                    const SizedBox(height: 12),

                    _label("No. Rekening Tujuan"),
                    const SizedBox(height: 4),
                    _plainText(app['accountNumber'] as String? ?? '-'),
                    const SizedBox(height: 16),

                    _sectionTitle("Detail Pencairan Saldo"),
                    const SizedBox(height: 8),
                    _kvBox(items: [
                      _KV("Rekening Tujuan", app['accountNumber'] as String? ?? '-'),
                      _KV("Nominal Diajukan", _rp((app['amount'] as num?) ?? 0)),
                      _KV("Biaya Admin", _rp((app['fee'] as num?) ?? 0)),
                    ]),
                    const SizedBox(height: 8),
                    _emphasizedTotal("Dana Diterima Penjual", _rp((app['received'] as num?) ?? 0)),
                    const SizedBox(height: 12),

                    _label("Bukti Pembayaran *"),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _adminProof == null ? _pickAdminProof : null,
                      child: Container(
                        height: 152,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDFE3E6)),
                        ),
                        child: _adminProof == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add, size: 22, color: Color(0xFF9A9A9A)),
                                    const SizedBox(height: 4),
                                    Text("Tambah Foto",
                                        style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF9A9A9A))),
                                  ],
                                ),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(File(_adminProof!.path), fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Row(
                                      children: [
                                        _IconAction(icon: Icons.delete_rounded, tooltip: 'Hapus', onTap: _removeAdminProof),
                                        const SizedBox(width: 8),
                                        _IconAction(icon: Icons.swap_horiz_rounded, tooltip: 'Ganti', onTap: _pickAdminProof),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "• Format yang Didukung : JPG, PNG, JPEG\n• Ukuran file maksimum: 2 MB",
                      style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF9A9A9A), height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 6),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -3))],
          ),
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('paymentApplications')
                .doc(widget.applicationId)
                .get(),
            builder: (context, snap) {
              final appData = snap.data?.data() ?? const <String, dynamic>{};
              return AdminDualActionButtons(
                compact: true,
                rejectText: "Tolak",
                acceptText: "Verifikasi",
                onReject: () => _onReject(appData),
                onAccept: () => _onVerify(appData),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===== UI helpers =====
  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF373E3C),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: const Color(0xFF373E3C),
        ),
      );

  Widget _plainText(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF232323),
        ),
      );

  Widget _fileChip(String name, String size, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDFE3E6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file_rounded, size: 18, color: Color(0xFF808080)),
            const SizedBox(width: 6),
            Text(name, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF373E3C), fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text(size, style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF9A9A9A))),
            if (trailing != null) ...[const SizedBox(width: 6), trailing],
          ],
        ),
      ),
    );
  }

  Widget _kvBox({required List<_KV> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final it = items[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 10),
            child: Row(
              children: [
                Expanded(child: Text(it.left, style: GoogleFonts.dmSans(fontSize: 12.5, color: const Color(0xFF6D6D6D)))),
                Text(it.right, style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF373E3C))),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _emphasizedTotal(String left, String right) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(left,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF373E3C),
                  ))),
          Text(right,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF373E3C),
              )),
        ],
      ),
    );
  }
}

class _KV {
  final String left;
  final String right;
  _KV(this.left, this.right);
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _IconAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.45),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
