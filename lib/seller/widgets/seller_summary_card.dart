import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerSummaryCard extends StatelessWidget {
  final int pesananMasuk;
  final int pesananDikirim;
  final int pesananSelesai;
  final int pesananBatal;
  // Tetap ada untuk kompatibilitas, tapi tidak dipakai lagi:
  final String saldo;
  final String saldoTertahan;

  const SellerSummaryCard({
    super.key,
    required this.pesananMasuk,
    required this.pesananDikirim,
    required this.pesananSelesai,
    required this.pesananBatal,
    required this.saldo,
    required this.saldoTertahan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ringkasan Toko",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Yuk, pantau terus perkembangan toko Anda untuk memastikan semuanya berjalan lancar",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF373E3C),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  double parentWidth = constraints.maxWidth;
                  double idealWidth = 158;
                  double minWidth = 130;
                  double gap = 15;
                  int columns = 2;
                  double cardWidth = (parentWidth - gap) / columns;
                  if (cardWidth > idealWidth) cardWidth = idealWidth;
                  if (cardWidth < minWidth) {
                    columns = 1;
                    cardWidth = parentWidth;
                  }

                  final List<_SummaryItem> items = [
                    _SummaryItem(
                      title: "Pesanan Masuk",
                      value: pesananMasuk.toString(),
                      width: cardWidth,
                    ),
                    _SummaryItem(
                      title: "Pesanan Sedang Dikirim",
                      value: pesananDikirim.toString(),
                      width: cardWidth,
                    ),
                    _SummaryItem(
                      title: "Pesanan Selesai",
                      value: pesananSelesai.toString(),
                      width: cardWidth,
                    ),
                    _SummaryItem(
                      title: "Pesanan Batal",
                      value: pesananBatal.toString(),
                      width: cardWidth,
                    ),
                  ];

                  return Wrap(spacing: gap, runSpacing: gap, children: items);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isCurrency;
  final double width;

  const _SummaryItem({
    required this.title,
    required this.value,
    this.isCurrency = false,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 73;
    final double circleDiameter = cardHeight * 2;

    return SizedBox(
      width: width,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            Positioned(
              left: (width - circleDiameter) / 2,
              bottom: -(circleDiameter / 2 - cardHeight / 2),
              child: CustomPaint(
                size: Size(circleDiameter, circleDiameter),
                painter: _HalfCirclePainter(
                  color: const Color(0x331C55C0), // 20% biru
                ),
              ),
            ),
            Container(
              width: width,
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF373E3C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HalfCirclePainter extends CustomPainter {
  final Color color;
  const _HalfCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(100, 50, size.width, size.height);
    canvas.drawArc(
      rect,
      math.pi,
      math.pi / 2,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(_HalfCirclePainter oldDelegate) => false;
}
