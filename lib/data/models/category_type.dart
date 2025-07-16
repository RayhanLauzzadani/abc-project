import 'package:flutter/material.dart';

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

// Mapping dari string Firestore ke enum CategoryType
CategoryType mapCategoryType(String? value) {
  switch (value?.toLowerCase()) {
    case 'merchandise':
      return CategoryType.merchandise;
    case 'alat tulis':
      return CategoryType.alatTulis;
    case 'alat lab':
      return CategoryType.alatLab;
    case 'produk daur ulang':
      return CategoryType.produkDaurUlang;
    case 'produk kesehatan':
      return CategoryType.produkKesehatan;
    case 'makanan':
      return CategoryType.makanan;
    case 'minuman':
      return CategoryType.minuman;
    case 'snacks':
      return CategoryType.snacks;
    default:
      return CategoryType.lainnya;
  }
}

// Label kategori (untuk button, badge, dll)
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

// Warna utama per kategori
Color getCategoryColor(CategoryType type) {
  switch (type) {
    case CategoryType.merchandise: return const Color(0xFFB95FD0);
    case CategoryType.alatTulis: return const Color(0xFF1C55C0);
    case CategoryType.alatLab: return const Color(0xFFFF6725);
    case CategoryType.produkDaurUlang: return const Color(0xFF17A2B8);
    case CategoryType.produkKesehatan: return const Color(0xFF28A745);
    case CategoryType.makanan: return const Color(0xFFDC3545);
    case CategoryType.minuman: return const Color(0xFF8B4513);
    case CategoryType.snacks: return const Color(0xFFFFC90D);
    case CategoryType.lainnya: return const Color(0xFF656565);
  }
}

// Warna background badge kategori
Color getCategoryBgColor(CategoryType type) {
  switch (type) {
    case CategoryType.merchandise: return const Color(0x14B95FD0); // 8% alpha
    case CategoryType.alatTulis: return const Color(0x141C55C0);
    case CategoryType.alatLab: return const Color(0x14FF6725);
    case CategoryType.produkDaurUlang: return const Color(0x1417A2B8);
    case CategoryType.produkKesehatan: return const Color(0x1428A745);
    case CategoryType.makanan: return const Color(0x14DC3545);
    case CategoryType.minuman: return const Color(0x148B4513);
    case CategoryType.snacks: return const Color(0x14FFC90D);
    case CategoryType.lainnya: return const Color(0x14656565);
  }
}

/// Badge Kategori Responsive (Global Widget)
class CategoryBadge extends StatelessWidget {
  final CategoryType type;
  const CategoryBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final label = categoryLabels[type] ?? "Lainnya";
    final color = getCategoryColor(type);
    final bgColor = getCategoryBgColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
