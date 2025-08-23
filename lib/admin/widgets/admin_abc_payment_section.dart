import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final String name;          // Nippon Mart / Rayhanmuzaki
  final bool isSeller;        // true = Penjual, false = Pembeli
  final AbcPaymentType type;  // withdraw / topup
  final int amount;           // nominal dalam rupiah
  final DateTime createdAt;

  const AdminAbcPaymentData({
    required this.name,
    required this.isSeller,
    required this.type,
    required this.amount,
    required this.createdAt,
  });
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
    final isWithdraw = data.type == AbcPaymentType.withdraw;

    // warna bulatan & warna ikon
    final Color tone = isWithdraw ? const Color(0xFF2056D3) : const Color(0xFFFFC107);
    final Color iconColor = isWithdraw ? Colors.white : Colors.black;

    final role = data.isSeller ? "Penjual" : "Pembeli";
    final action = isWithdraw ? "Tarik Saldo" : "Isi Saldo";

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
            // baris atas: ikon + (nama & amount satu baris) + subtitle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bulatan penuh + ikon SVG
                Container(
                  width: 56,  
                  height: 56,
                  decoration: BoxDecoration(
                    color: tone,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/banknote-arrow-down.svg',
                    width: 28,
                    height: 28,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 14),

                // Konten teks
                Expanded(
                  child: Padding(
                    // sedikit turun supaya tidak sejajar banget dengan tepi atas bulatan
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama & nominal — selalu sejajar
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            // Padding kanan kecil supaya "..." muncul sedikit lebih awal
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10), // ← gap “…” vs harga
                                child: Text(
                                  data.name,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: const Color(0xFF373E3C),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Text(
                              _formatRupiah(data.amount),
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: const Color(0xFF373E3C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$role : $action",
                          style: GoogleFonts.dmSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF373E3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Footer (diturunkan tapi tidak terlalu jauh)
            const SizedBox(height: 24), 

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(data.createdAt),
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    color: const Color.fromARGB(255, 103, 103, 103),
                  ),
                ),
                GestureDetector(
                  onTap: onDetail,
                  child: Row(
                    children: [
                      Text(
                        "Detail Ajuan",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFF1867C2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFF1C55C0)),
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
