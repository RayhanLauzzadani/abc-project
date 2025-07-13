import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/search_bar.dart' as custom_widgets;
import '../../../widgets/category_selector.dart';
import '../../../data/models/category_type.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProductsTabMine extends StatefulWidget {
  const ProductsTabMine({super.key});

  @override
  State<ProductsTabMine> createState() => _ProductsTabMineState();
}

class _ProductsTabMineState extends State<ProductsTabMine> {
  int selectedCategory = 0;
  String searchQuery = "";

  // Dummy data produk
  final List<Map<String, dynamic>> products = [
    {
      'image': 'assets/images/geprek.png',
      'name': 'Ayam Geprek',
      'stock': 10,
      'price': 15000,
      'category': CategoryType.makanan,
    },
    {
      'image': 'assets/images/geprek.png',
      'name': 'Es Teh Manis',
      'stock': 7,
      'price': 5000,
      'category': CategoryType.minuman,
    },
    {
      'image': 'assets/images/geprek.png',
      'name': 'Keripik Kentang',
      'stock': 22,
      'price': 8000,
      'category': CategoryType.snacks,
    },
    // Tambahkan produk lain jika perlu...
  ];

  @override
  Widget build(BuildContext context) {
    // Filter produk sesuai search dan kategori
    List<Map<String, dynamic>> filteredProducts = products.where((prod) {
      bool matchesSearch = searchQuery.isEmpty ||
          prod['name'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory = selectedCategory == 0 ||
          prod['category'] == CategoryType.values[selectedCategory - 1];
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: custom_widgets.SearchBar(
            hintText: "Cari produk anda",
            onChanged: (val) => setState(() => searchQuery = val),
          ),
        ),
        const SizedBox(height: 8),
        // Category chips
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 0),
          child: CategorySelector(
            categories: CategoryType.values,
            selectedIndex: selectedCategory,
            onSelected: (idx) => setState(() => selectedCategory = idx),
          ),
        ),
        const SizedBox(height: 12),
        // List produk
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.packageSearch,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Tidak ada produk di kategori ini",
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tambah produk baru atau pilih kategori lain.",
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filteredProducts.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final product = filteredProducts[idx];
                    return _ProductCardMine(
                      product: product,
                      onEdit: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur Edit belum tersedia')),
                        );
                      },
                      onDelete: () => _showDeleteDialog(context, product['name']),
                    );
                  },
                ),
        )
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0x1AFF5B5B),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5B5B), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Hapus Produk ?',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF232323),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: Color(0xFFB7B7B7)),
            )
          ],
        ),
        content: Text(
          "Anda yakin ingin menghapus produk \"$productName\"?",
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: const Color(0xFF494949),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF232323),
                    backgroundColor: const Color(0xFFF2F2F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(0, 42),
                  ),
                  child: Text(
                    "Tidak",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produk "$productName" dihapus (dummy).')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5B5B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(0, 42),
                    elevation: 0,
                  ),
                  child: Text(
                    "Iya",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Komponen kartu produk untuk Produk Saya
class _ProductCardMine extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCardMine({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE6E6E6), // abu muda, referensi Figma
          width: 1,
        ),
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produk
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                product['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 13),
            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Stok: ${product['stock']}",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: const Color(0xFF818181),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rp ${product['price'].toString()}",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: const Color(0xFF818181),
                    ),
                  ),
                ],
              ),
            ),
            // Tombol aksi (edit/hapus)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<int>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                onSelected: (value) {
                  if (value == 0) onEdit();
                  if (value == 1) onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF2056D3)),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Produk',
                          style: GoogleFonts.dmSans(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF5B5B)),
                        const SizedBox(width: 8),
                        Text(
                          'Hapus Produk',
                          style: GoogleFonts.dmSans(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF999999)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
