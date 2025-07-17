import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/data/models/category_type.dart';  // Import file category_type.dart
import 'package:flutter_svg/flutter_svg.dart';  // Import untuk SVG icons

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  // List kategori sesuai dengan urutan yang ada di CategoryType
  final List<CategoryType> categories = const [
    CategoryType.merchandise,
    CategoryType.alatTulis,
    CategoryType.alatLab,
    CategoryType.produkDaurUlang,
    CategoryType.produkKesehatan,
    CategoryType.makanan,
    CategoryType.minuman,
    CategoryType.snacks,
    CategoryType.lainnya,
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
              Padding(
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
            ],
          ),
        ),
        const SizedBox(height: 18),

        // List kategori horizontal tanpa padding kiri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              final color = getCategoryColor(cat);
              final bgColor = getCategoryBgColor(cat);
              final label = categoryLabels[cat] ?? "Lainnya";
              final iconPath = 'assets/icons/${cat.name.toLowerCase()}.svg'; // SVG icon path

              return Container(
                margin: EdgeInsets.only(
                  left: i == 0 ? 20 : 0, // margin kiri untuk item pertama
                  right: 12,
                ),
                child: CategoryCard(
                  label: label,
                  icon: iconPath,  // Using SVG path here
                  color: color,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailPage(categoryLabel: label),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String label;
  final String icon;  // This will now hold SVG path
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDBDBDB), width: 1),
        ),
        child: Stack(
          children: [
            // Background half circle
            Positioned(
              right: -8,
              bottom: -10,
              child: ClipPath(
                clipper: _HalfCircleClipper(),
                child: Container(
                  width: 65,
                  height: 65,
                  color: color.withOpacity(0.13),
                ),
              ),
            ),
            // Icon (Now using SVG)
            Positioned(
              right: 13,
              bottom: 12,
              child: SvgPicture.asset(
                icon,  // Load SVG here
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
            // Label
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 0, 0),
              child: Text(
                label,
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
    );
  }
}

class _HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(10, size.height);
    path.arcToPoint(
      Offset(size.width, 10),
      radius: Radius.circular(size.width),
      clockwise: true,
      largeArc: false,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HalfCircleClipper oldClipper) => false;
}

class CategoryDetailPage extends StatelessWidget {
  final String categoryLabel;

  const CategoryDetailPage({super.key, required this.categoryLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryLabel)),
      body: Center(
        child: Text(
          'Ini halaman detail kategori: $categoryLabel',
          style: GoogleFonts.dmSans(fontSize: 20),
        ),
      ),
    );
  }
}
