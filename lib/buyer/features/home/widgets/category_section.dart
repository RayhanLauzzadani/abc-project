import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Enum kategori urut sesuai permintaan
enum CategoryType {
  merchandise,
  alatTulis,
  alatLab,
  produkDaurUlang,
  produkKesehatan,
  makanan,
  minuman,
  snacks,
  lainnya,
}

// Mapping label kategori (bisa dipakai global)
const Map<CategoryType, String> categoryLabels = {
  CategoryType.merchandise: 'Merchandise',
  CategoryType.alatTulis: 'Alat Tulis',
  CategoryType.alatLab: 'Alat Lab',
  CategoryType.produkDaurUlang: 'Produk Daur Ulang',
  CategoryType.produkKesehatan: 'Produk Kesehatan',
  CategoryType.makanan: 'Makanan',
  CategoryType.minuman: 'Minuman',
  CategoryType.snacks: 'Snacks',
  CategoryType.lainnya: 'Lainnya',
};

class CategorySection extends StatelessWidget {
  final Function(int) onCategorySelected;

  const CategorySection({super.key, required this.onCategorySelected});

  final List<Map<String, dynamic>> categories = const [
    {
      "label": "Merchandise",
      "icon": "assets/icons/home/merchandise.png",
      "color": Color(0xFFB95FD0),
    },
    {
      "label": "Alat Tulis",
      "icon": "assets/icons/home/alat_tulis.png",
      "color": Color(0xFF1C55C0),
    },
    {
      "label": "Alat Lab",
      "icon": "assets/icons/home/alat_lab.png",
      "color": Color(0xFFFF6725),
    },
    {
      "label": "Produk Daur Ulang",
      "icon": "assets/icons/home/produk_daur_ulang.png",
      "color": Color(0xFF17A2B8),
    },
    {
      "label": "Produk Kesehatan",
      "icon": "assets/icons/home/produk_kesehatan.png",
      "color": Color(0xFF28A745),
    },
    {
      "label": "Makanan",
      "icon": "assets/icons/home/makanan.png",
      "color": Color(0xFFDC3545),
    },
    {
      "label": "Minuman",
      "icon": "assets/icons/home/minuman.png",
      "color": Color(0xFF8B4513),
    },
    {
      "label": "Snacks",
      "icon": "assets/icons/home/snacks.png",
      "color": Color(0xFFFFC90D),
    },
    {
      "label": "Lainnya",
      "icon": "assets/icons/lainnya.png",
      "color": Color(0xFF656565),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & "Lihat Semua"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kategori",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF232323),
                ),
              ),
              GestureDetector(
                onTap: () => onCategorySelected(0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Lihat Semua",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // List kategori horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              return Container(
                margin: EdgeInsets.only(left: i == 0 ? 20 : 0, right: 12),
                child: CategoryCard(
                  label: cat['label'],
                  icon: cat['icon'],
                  color: cat['color'],
                  onTap: () => onCategorySelected(i + 1),

                  // ====== KONFIG POSISI 1/4 LINGKARAN ======
                  // Default: di TENGAH card
                  quarterCenter: null,
                  quarterRadius: 58,
                  quarterOrientation: QuarterOrientation.bottomRight,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// =================== Card dengan background painter ===================

enum QuarterOrientation {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class CategoryCard extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback? onTap;

  /// Pusat (center) dari 1/4 lingkaran relatif ke **card** (top-left = Offset(0,0)).
  /// Jika `null`, otomatis di tengah card.
  final Offset? quarterCenter;

  /// Radius 1/4 lingkaran.
  final double quarterRadius;

  /// Arah kuadran (90°) yang ingin digambar.
  final QuarterOrientation quarterOrientation;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.quarterCenter,
    this.quarterRadius = 58,
    this.quarterOrientation = QuarterOrientation.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    const cardRadius = 16.0;
    const borderColor = Color(0xFFDBDBDB);

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _CategoryCardPainter(
          cardRadius: cardRadius,
          borderColor: borderColor,
          bgColor: Colors.white,
          quarterColor: color.withOpacity(0.13),
          quarterCenter: quarterCenter,
          quarterRadius: quarterRadius,
          quarterOrientation: quarterOrientation,
        ),
        child: SizedBox(
          width: 110,
          height: 100,
          child: Stack(
            children: [
              // Icon
              Positioned(
                right: 13,
                bottom: 12,
                child: icon.endsWith('.svg')
                    ? SvgPicture.asset(icon, width: 30, height: 30, fit: BoxFit.contain)
                    : Image.asset(icon, width: 30, height: 30, fit: BoxFit.contain),
              ),
              // Label (padding kanan supaya tidak mepet border)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 0),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: const Color(0xFF232323),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter:
/// 1) Clip ke RRect card  → semua gambar di DALAM card.
/// 2) Cat background putih.
/// 3) Gambar 1/4 lingkaran (selalu 90°) di posisi yg bisa di-custom.
/// 4) Gambar border card di atasnya (tanpa clip agar border utuh).
class _CategoryCardPainter extends CustomPainter {
  final double cardRadius;
  final Color borderColor;
  final Color bgColor;

  final Color quarterColor;
  final Offset? quarterCenter; // null -> center of card
  final double quarterRadius;
  final QuarterOrientation quarterOrientation;

  _CategoryCardPainter({
    required this.cardRadius,
    required this.borderColor,
    required this.bgColor,
    required this.quarterColor,
    required this.quarterCenter,
    required this.quarterRadius,
    required this.quarterOrientation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(cardRadius),
    );

    // ----- LAYER DI DALAM CARD (CLIP) -----
    canvas.save();
    canvas.clipRRect(rrect);

    // 1) background putih
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    // 2) 1/4 lingkaran
    final center = quarterCenter ?? Offset(size.width / 1, size.height / 1);
    final rect = Rect.fromCircle(center: center, radius: quarterRadius);
    final paintQ = Paint()..color = quarterColor;

    // tentukan startAngle berdasarkan kuadran
    double startAngle;
    switch (quarterOrientation) {
      case QuarterOrientation.topLeft:
        startAngle = math.pi / 2; // 90°
        break;
      case QuarterOrientation.topRight:
        startAngle = math.pi; // 180°
        break;
      case QuarterOrientation.bottomLeft:
        startAngle = 3; // 0°
        break;
      case QuarterOrientation.bottomRight:
        startAngle = math.pi / -1; // -90°
        break;
    }

    // gambar sebagai sektor (pie) 90°
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, startAngle, math.pi / 2, false)
      ..close();

    canvas.drawPath(path, paintQ);

    // selesai: kembalikan clip
    canvas.restore();

    // 3) border card (di atas clip biar tidak terpotong)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(_CategoryCardPainter old) {
    return old.cardRadius != cardRadius ||
        old.borderColor != borderColor ||
        old.bgColor != bgColor ||
        old.quarterColor != quarterColor ||
        old.quarterRadius != quarterRadius ||
        old.quarterOrientation != quarterOrientation ||
        old.quarterCenter != quarterCenter;
  }
}
