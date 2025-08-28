import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:abc_e_mart/admin/widgets/admin_search_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abc_e_mart/admin/features/approval/payment/admin_payment_approval_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentApprovalPage extends StatefulWidget {
  const AdminPaymentApprovalPage({super.key});

  @override
  State<AdminPaymentApprovalPage> createState() => _AdminPaymentApprovalPageState();
}

class _AdminPaymentApprovalPageState extends State<AdminPaymentApprovalPage> {
  String _search = "";

  String _formatDate(DateTime dt) =>
      DateFormat('dd/MM/yyyy, HH:mm').format(dt);
  String _formatRupiah(int v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  @override
  Widget build(BuildContext context) {
    final q = _search.trim().toLowerCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 31),
              Text(
                'Ajuan ABC Payment',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 23),

              // Search bar
              AdminSearchBar(
                hintText: "Cari yang anda inginkan...",
                onChanged: (val) => setState(() => _search = val),
              ),
              const SizedBox(height: 16),

              // ===== List real-time: hanya status pending =====
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('paymentApplications')
                      .where('status', isEqualTo: 'pending')
                      .orderBy('submittedAt', descending: true)
                      .limit(200)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Gagal memuat ajuan: ${snap.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final docs = snap.data?.docs ?? const [];
                    if (docs.isEmpty) {
                      return _empty();
                    }

                    // Filter sederhana di klien (nama/email/bank/account)
                    final filtered = docs.where((d) {
                      if (q.isEmpty) return true;
                      final m = d.data();
                      final type = (m['type'] as String? ?? '').toLowerCase();
                      if (type == 'topup') {
                        final email = (m['buyerEmail'] as String? ?? '').toLowerCase();
                        return email.contains(q);
                      } else {
                        final bank = (m['bankName'] as String? ?? '').toLowerCase();
                        final acc  = (m['accountNumber'] as String? ?? '').toLowerCase();
                        return bank.contains(q) || acc.contains(q);
                      }
                    }).toList();

                    if (filtered.isEmpty) return _empty();

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final doc = filtered[i];
                        final data = doc.data();

                        final isWithdraw = (data['type'] as String? ?? '') == 'withdrawal';
                        final type = isWithdraw ? _PaymentType.withdraw : _PaymentType.topup;

                        final createdAt =
                            (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                        // Amount yang ditampilkan di list:
                        final int amount = (data['amount'] as num?)?.toInt() ?? 0;

                        // Nama untuk tampilan:
                        // - withdrawal: ambil nama toko dari stores/{storeId}.name
                        // - topup: pakai email buyer (atau name kalau ada)
                        final Future<String> nameFut = () async {
                          if (isWithdraw) {
                            final storeId = data['storeId'] as String?;
                            if (storeId == null) return 'Penjual';
                            final st = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
                            return (st.data()?['name'] as String?) ?? 'Penjual';
                          } else {
                            final buyerId = data['buyerId'] as String?;
                            final email   = data['buyerEmail'] as String?;
                            if (buyerId != null) {
                              final u = await FirebaseFirestore.instance.collection('users').doc(buyerId).get();
                              final display = (u.data()?['displayName'] as String?) ??
                                              (u.data()?['name'] as String?);
                              if (display != null && display.trim().isNotEmpty) return display;
                            }
                            return email ?? 'Pembeli';
                          }
                        }();

                        return FutureBuilder<String>(
                          future: nameFut,
                          builder: (context, nameSnap) {
                            final name = nameSnap.data ?? (isWithdraw ? 'Penjual' : 'Pembeli');

                            return _PaymentCard(
                              name: name,
                              subtitle: isWithdraw ? "Penjual : Tarik Saldo" : "Pembeli : Isi Saldo",
                              amountText: _formatRupiah(amount),
                              dateText: _formatDate(createdAt),
                              type: type,
                              onTapDetail: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminPaymentApprovalDetailPage(
                                      applicationId: doc.id,
                                      // biar tampilan awal langsung benar (sebenarnya type juga bisa dibaca ulang di detail)
                                      type: isWithdraw
                                          ? PaymentRequestType.withdrawal
                                          : PaymentRequestType.topUp,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.inbox, size: 54, color: const Color(0xFFE2E7EF)),
            const SizedBox(height: 16),
            Text(
              "Belum ada ajuan ABC Payment",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF373E3C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Semua pengajuan isi saldo & tarik saldo akan tampil di sini\njika ada ajuan baru dari pembeli/penjual.",
              style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF9A9A9A)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ====== WIDGET & MODEL INTERNAL (tak berubah) ======
enum _PaymentType { topup, withdraw }

class _PaymentBadge extends StatelessWidget {
  final _PaymentType type;
  const _PaymentBadge({required this.type});
  Color get _mainColor =>
      type == _PaymentType.withdraw ? const Color(0xFF1C55C0) : const Color(0xFFF4C21B);
  IconData get _arrowIcon =>
      type == _PaymentType.withdraw ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: _mainColor, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: _mainColor.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Center(child: Icon(Icons.account_balance_wallet_rounded, size: 24, color: Colors.white)),
        ),
        Positioned(
          right: -2, bottom: -2,
          child: Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFEAEAEA))),
            child: Icon(_arrowIcon, size: 14, color: _mainColor),
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String amountText;
  final String dateText;
  final _PaymentType type;
  final VoidCallback onTapDetail;

  const _PaymentCard({
    required this.name,
    required this.subtitle,
    required this.amountText,
    required this.dateText,
    required this.type,
    required this.onTapDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PaymentBadge(type: type),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF373E3C))),
                      const SizedBox(height: 3),
                      Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF6A6A6A))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(amountText, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF373E3C))),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateText, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF9A9A9A))),
              InkWell(
                onTap: onTapDetail,
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Detail Ajuan", style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF1C55C0), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF1C55C0)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
