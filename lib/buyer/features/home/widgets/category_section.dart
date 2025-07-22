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
                onTap: () {
                  onCategorySelected(0);
                },
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
        // List kategori horizontal tanpa padding kiri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              return Container(
                margin: EdgeInsets.only(
                  left: i == 0 ? 20 : 0, // margin kiri untuk item pertama
                  right: 12,
                ),
                child: CategoryCard(
                  label: cat['label'],
                  icon: cat['icon'],
                  color: cat['color'],
                  onTap: () {
                    onCategorySelected(i + 1); // Menggunakan 1-based index
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

// Kartu kategori
class CategoryCard extends StatelessWidget {
  final String label;
  final String icon;
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
        width: 110,
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
            // Icon
            Positioned(
              right: 13,
              bottom: 12,
              child: icon.endsWith('.svg')
                  ? SvgPicture.asset(
                      icon,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      icon,
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
