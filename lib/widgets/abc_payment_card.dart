import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ABCPaymentCard extends StatelessWidget {
  final int balance;
  final String title;
  final String primaryLabel;        // 'Isi Saldo' / 'Tarik Saldo'
  final VoidCallback onPrimary;
  final VoidCallback onHistory;
  final String logoAsset;
  final EdgeInsetsGeometry margin;

  final IconData primaryIcon;       // fallback jika tidak pakai widget
  final IconData historyIcon;       // fallback jika tidak pakai widget
  final Color actionColor;

  // ikon kustom (contoh: SVG). Jika diisi, akan dipakai menggantikan IconData.
  final Widget? primaryIconWidget;
  final Widget? historyIconWidget;

  // ukuran & gaya yang bisa di-tweak
  final double logoOuterSize;        // diameter bulatan logo
  final double logoInnerPadding;     // padding logo di dalam bulatan
  final double actionBoxSize;        // sisi kotak aksi
  final double actionIconSize;       // ukuran icon di kotak (untuk IconData)
  final double actionGap;            // jarak antar dua kotak aksi
  final double cardBorderWidth;      // ketebalan border kartu
  final Color cardBorderColor;

  // kalau saldo terlalu panjang, tombol aksi dipindah ke baris bawah
  final bool stackActionsWhenTight;

  const ABCPaymentCard({
    super.key,
    required this.balance,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onHistory,
    this.title = 'ABC Payment',
    this.logoAsset = 'assets/images/paymentlogo.png',
    this.margin = const EdgeInsets.symmetric(horizontal: 20),

    this.primaryIcon = Icons.add,
    this.historyIcon = Icons.history,
    this.actionColor = const Color(0xFF2056D3),

    this.primaryIconWidget,
    this.historyIconWidget,

    this.logoOuterSize = 48,
    this.logoInnerPadding = 8,
    this.actionBoxSize = 28,
    this.actionIconSize = 20,
    this.actionGap = 22,
    this.cardBorderWidth = 1.2,
    this.cardBorderColor = const Color(0xFFEDEFF5),

    this.stackActionsWhenTight = true,
  });

  String _formatRupiah(int nominal) {
    // selalu full, tanpa singkatan "jt"
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    final balanceText = _formatRupiah(balance);

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // judul di luar kartu
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),

          // kartu saldo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: cardBorderColor, width: cardBorderWidth),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // aturan sederhana: kalau teks saldo panjang *dan* lebar kartu sempit,
                // kita stack tombol aksi ke baris bawah agar tidak tabrakan
                final bool shouldStack =
                    stackActionsWhenTight &&
                    (balanceText.length >= 14 && constraints.maxWidth < 360);

                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SquareAction(
                      label: primaryLabel,
                      icon: primaryIcon,
                      iconWidget: primaryIconWidget,
                      boxSize: actionBoxSize,
                      iconSize: actionIconSize,
                      color: actionColor,
                      onTap: onPrimary,
                    ),
                    SizedBox(width: actionGap),
                    _SquareAction(
                      label: 'Riwayat',
                      icon: historyIcon,
                      iconWidget: historyIconWidget,
                      boxSize: actionBoxSize,
                      iconSize: actionIconSize,
                      color: actionColor,
                      onTap: onHistory,
                    ),
                  ],
                );

                if (!shouldStack) {
                  // layout normal: saldo kiri, aksi kanan
                  return Row(
                    children: [
                      _LogoBubble(
                        size: logoOuterSize,
                        padding: logoInnerPadding,
                        asset: logoAsset,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          balanceText,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212121),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      actions,
                    ],
                  );
                }

                // layout sempit/panjang: saldo di atas, aksi di bawah kanan
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LogoBubble(
                      size: logoOuterSize,
                      padding: logoInnerPadding,
                      asset: logoAsset,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            balanceText,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: actions,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBubble extends StatelessWidget {
  final double size;
  final double padding;
  final String asset;

  const _LogoBubble({
    required this.size,
    required this.padding,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF4F6FF), // bulatan soft tanpa garis tepi
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  final String label;
  final IconData icon;        // fallback
  final Widget? iconWidget;   // kustom (SVG)
  final double boxSize;
  final double iconSize;
  final Color color;
  final VoidCallback onTap;

  const _SquareAction({
    required this.label,
    required this.icon,
    required this.boxSize,
    required this.iconSize,
    required this.color,
    required this.onTap,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: boxSize,
              height: boxSize,
              child: Center(
                child: iconWidget ??
                    Icon(icon, size: iconSize, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
