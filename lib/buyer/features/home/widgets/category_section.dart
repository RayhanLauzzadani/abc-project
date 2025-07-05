import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  // List kategori beserta label, icon, dan warna background
  final List<Map<String, dynamic>> categories = const [
    {
      "label": "Makanan",
      "icon": "assets/icons/makanan.png",
      "color": Color(0xFFFF455B),
    },
    {
      "label": "Minuman",
      "icon": "assets/icons/minuman.png",
      "color": Color(0xFF24BCD7),
    },
    {
      "label": "Snacks",
      "icon": "assets/icons/snacks.png",
      "color": Color(0xFFFFC928),
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
        Row(
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
              padding: const EdgeInsets.only(top: 8, right: 23), // right:23px
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
        const SizedBox(height: 18),
        // List kategori horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              return Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 16),
                child: CategoryCard(
                  label: cat['label'],
                  icon: cat['icon'],
                  color: cat['color'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailPage(categoryLabel: cat['label']),
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
      onTap: onTap, // Supaya navigasi berfungsi
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
            // Setengah lingkaran di kanan bawah (digeser bawah & kanan)
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
            // Icon PNG di pojok kanan bawah (padding kanan 13px)
            Positioned(
              right: 13,
              bottom: 12,
              child: Image.asset(
                icon,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
            // Label kiri atas
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

// Custom clipper setengah lingkaran kanan bawah
class _HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Mulai dari kiri bawah, buat arc ke kanan bawah, hanya kuadran kanan bawah lingkaran
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

// --- Dummy Halaman Detail Kategori ---
class CategoryDetailPage extends StatelessWidget {
  final String categoryLabel;

  const CategoryDetailPage({super.key, required this.categoryLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryLabel),
      ),
      body: Center(
        child: Text(
          'Ini halaman detail kategori: $categoryLabel',
          style: GoogleFonts.dmSans(fontSize: 20),
        ),
      ),
    );
  }
}
