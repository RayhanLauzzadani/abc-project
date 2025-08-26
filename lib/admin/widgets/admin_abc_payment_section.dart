import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminAbcPaymentSection extends StatelessWidget {
  final List<AdminAbcPaymentData> items;
  final VoidCallback? onSeeAll;
  final void Function(AdminAbcPaymentData item)? onDetail;
  final bool showSeeAll;

  const AdminAbcPaymentSection({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onDetail,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "ABC Payment",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ),
                if (showSeeAll && onSeeAll != null)
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Row(
                      children: [
                        Text(
                          "Lainnya",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFFBDBDBD),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBDBDBD)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Lihat ajuan ABC Payment dari para pelanggan dan penjual di sini!",
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 18),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    "Belum ada ajuan ABC Payment.",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9A9A9A),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...items.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AbcPaymentCard(
                    data: e,
                    onDetail: () => onDetail?.call(e),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum AbcPaymentType { withdraw, topup }

class AdminAbcPaymentData {
  final String name;
  final bool isSeller;        // true = Penjual, false = Pembeli
  final AbcPaymentType type;  // withdraw / topup
  final int amount;
  final DateTime createdAt;

  const AdminAbcPaymentData({
    required this.name,
    required this.isSeller,
    required this.type,
    required this.amount,
    required this.createdAt,
  });
}

/// === Badge yang sama dengan halaman Ajuan Payment ===
class _PaymentBadge extends StatelessWidget {
  final AbcPaymentType type;
  const _PaymentBadge({required this.type});

  Color get _main =>
      type == AbcPaymentType.withdraw ? const Color(0xFF1C55C0) : const Color(0xFFF4C21B);
  IconData get _arrow =>
      type == AbcPaymentType.withdraw ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _main,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _main.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.account_balance_wallet_rounded, size: 24, color: Colors.white),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Icon(_arrow, size: 14, color: _main),
          ),
        ),
      ],
    );
  }
}

class _AbcPaymentCard extends StatelessWidget {
  final AdminAbcPaymentData data;
  final VoidCallback? onDetail;
  const _AbcPaymentCard({required this.data, this.onDetail});

  String _formatRupiah(int v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);
  String _formatDate(DateTime dt) => DateFormat('dd/MM/yyyy, h:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final role = data.isSeller ? "Penjual" : "Pembeli";
    final action = data.type == AbcPaymentType.withdraw ? "Tarik Saldo" : "Isi Saldo";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PaymentBadge(type: data.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama & nominal sejajar baseline
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  data.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: const Color(0xFF373E3C),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _formatRupiah(data.amount),
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14, // <-- samakan dengan halaman Ajuan
                                color: const Color(0xFF373E3C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$role : $action",
                          style: GoogleFonts.dmSans(
                            fontSize: 12, // <-- samakan
                            color: const Color(0xFF6A6A6A), // <-- samakan
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18), // <-- samakan jarak ke footer

            // Footer: tanggal kiri — detail kanan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(data.createdAt),
                  style: GoogleFonts.dmSans(
                    fontSize: 12, // <-- samakan
                    color: const Color(0xFF9A9A9A), // <-- samakan
                  ),
                ),
                GestureDetector(
                  onTap: onDetail,
                  child: Row(
                    children: [
                      Text(
                        "Detail Ajuan",
                        style: GoogleFonts.dmSans(
                          fontSize: 12, // <-- samakan
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C55C0), // <-- samakan
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          size: 16, color: Color(0xFF1C55C0)), // <-- samakan
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}