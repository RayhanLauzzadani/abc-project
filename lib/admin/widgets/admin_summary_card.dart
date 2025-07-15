import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSummaryCard extends StatelessWidget {
  final int tokoBaru;
  final int tokoTerdaftar;
  final int produkBaru;
  final int produkDisetujui;
  final int iklanBaru;
  final int iklanAktif;

  const AdminSummaryCard({
    super.key,
    required this.tokoBaru,
    required this.tokoTerdaftar,
    required this.produkBaru,
    required this.produkDisetujui,
    required this.iklanBaru,
    required this.iklanAktif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
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
              "Ringkasan Admin",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
                double gap = 16;
                int maxInRow = 2;
                double minCardWidth = 120;
                double maxCardWidth = 180;
                double cardWidth = ((parentWidth - gap) / maxInRow).clamp(
                  minCardWidth,
                  maxCardWidth,
                );

                final List<_AdminSummaryItem> items = [
                  _AdminSummaryItem(
                    title: "Toko Baru",
                    value: tokoBaru.toString(),
                    width: cardWidth,
                  ),
                  _AdminSummaryItem(
                    title: "Toko Terdaftar",
                    value: tokoTerdaftar.toString(),
                    width: cardWidth,
                  ),
                  _AdminSummaryItem(
                    title: "Produk Baru",
                    value: produkBaru.toString(),
                    width: cardWidth,
                  ),
                  _AdminSummaryItem(
                    title: "Produk Disetujui",
                    value: produkDisetujui.toString(),
                    width: cardWidth,
                  ),
                  _AdminSummaryItem(
                    title: "Iklan Baru",
                    value: iklanBaru.toString(),
                    width: cardWidth,
                  ),
                  _AdminSummaryItem(
                    title: "Iklan Aktif",
                    value: iklanAktif.toString(),
                    width: cardWidth,
                  ),
                ];

                return Wrap(spacing: gap, runSpacing: gap, children: items);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final double width;

  const _AdminSummaryItem({
    required this.title,
    required this.value,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 83;
    final double circleDiameter = cardHeight * 1.5;

    return SizedBox(
      width: width,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // Quarter circle di kanan bawah
            Positioned(
              right: -circleDiameter / 4,
              bottom: -circleDiameter / 4,
              child: CustomPaint(
                size: Size(circleDiameter, circleDiameter),
                painter: _QuarterCirclePainter(
                  color: const Color(0xFFBFE5EB).withOpacity(0.8),
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
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
                    const SizedBox(height: 11),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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

class _QuarterCirclePainter extends CustomPainter {
  final Color color;
  const _QuarterCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(40, 50, size.width, size.height);
    canvas.drawArc(rect, math.pi, math.pi / 2, true, paint);
  }

  @override
  bool shouldRepaint(_QuarterCirclePainter oldDelegate) => false;
}
