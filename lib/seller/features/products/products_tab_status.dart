import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/search_bar.dart' as custom_widgets;
import '../../../data/models/category_type.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProductsTabStatus extends StatefulWidget {
  const ProductsTabStatus({super.key});

  @override
  State<ProductsTabStatus> createState() => _ProductsTabStatusState();
}

class _ProductsTabStatusState extends State<ProductsTabStatus> {
  int selectedCategory = 0;
  String searchQuery = "";

  // Dummy produk dengan status
  final List<Map<String, dynamic>> products = [
    {
      'image': 'assets/images/geprek.png',
      'name': 'Ayam Geprek',
      'stock': 10,
      'price': 15000,
      'category': CategoryType.makanan,
      'status': 'Menunggu',
    },
    {
      'image': 'assets/images/geprek.png',
      'name': 'Es Teh Manis',
      'stock': 7,
      'price': 5000,
      'category': CategoryType.minuman,
      'status': 'Ditolak',
    },
    {
      'image': 'assets/images/geprek.png',
      'name': 'Keripik Kentang',
      'stock': 22,
      'price': 8000,
      'category': CategoryType.snacks,
      'status': 'Sukses',
    },
    {
      'image': 'assets/images/geprek.png',
      'name': 'Tahu Crispy',
      'stock': 17,
      'price': 6000,
      'category': CategoryType.snacks,
      'status': 'Menunggu',
    },
  ];

  // Chips status label
  final List<String> statusCategories = [
    'Semua',
    'Sukses',
    'Menunggu',
    'Ditolak',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter produk sesuai search & status
    List<Map<String, dynamic>> filteredProducts = products.where((prod) {
      bool matchesSearch = searchQuery.isEmpty ||
          prod['name'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory = selectedCategory == 0 ||
          prod['status'] == statusCategories[selectedCategory];
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
        const SizedBox(height: 12),
        // Chips status
        _StatusSelector(
          statusList: statusCategories,
          selectedIndex: selectedCategory,
          onSelected: (idx) => setState(() => selectedCategory = idx),
        ),
        const SizedBox(height: 12),
        // List produk status
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
                        "Tidak ada produk di kategori/status ini",
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tambah produk baru atau pilih status/kategori lain.",
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
                    return _ProductCardStatus(product: product);
                  },
                ),
        )
      ],
    );
  }
}

// Chips status custom dengan padding kiri sama search bar, lebih kecil ukurannya!
class _StatusSelector extends StatelessWidget {
  final List<String> statusList;
  final int selectedIndex;
  final void Function(int) onSelected;

  const _StatusSelector({
    required this.statusList,
    required this.selectedIndex,
    required this.onSelected,
  });

  Color _getColor(String label) {
    switch (label) {
      case 'Sukses':
        return const Color(0xFF18BC5B);
      case 'Menunggu':
        return const Color(0xFFFFD600);
      case 'Ditolak':
        return const Color(0xFFFF5B5B);
      default:
        return const Color(0xFF2066CF); // blue for 'Semua'
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 16),
        itemCount: statusList.length,
        itemBuilder: (context, idx) {
          final isSelected = selectedIndex == idx;
          final label = statusList[idx];
          final color = label == 'Semua'
              ? const Color(0xFF2066CF)
              : _getColor(label);

          return Padding(
            padding: EdgeInsets.only(
                right: idx < statusList.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelected(idx),
              child: Container(
                height: 26,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(label == 'Semua' ? 1.0 : 0.12)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFF9A9A9A),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                    color: isSelected
                        ? (label == 'Semua' ? Colors.white : color)
                        : const Color(0xFF9A9A9A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Card produk status, badge status lebih kecil, posisi & margin rapi
class _ProductCardStatus extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCardStatus({required this.product});

  Color _statusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return const Color(0xFFFFB800);
      case 'Ditolak':
        return const Color(0xFFFF5B5B);
      case 'Sukses':
        return const Color(0xFF18BC5B);
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Menunggu':
        return const Color(0x14FFD600);
      case 'Ditolak':
        return const Color(0x14FF5B5B);
      case 'Sukses':
        return const Color(0x1418BC5B);
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = product['status'] ?? '';
    final color = _statusColor(status);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE6E6E6),
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
                  // Nama produk & status dalam satu baris
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'],
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF232323),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status.isNotEmpty) ...[
                        const SizedBox(width: 8), // Lebih kecil agar tidak makan space
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 0,
                            maxWidth: 74, // Lebih kecil!
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5), // Lebih kecil!
                          decoration: BoxDecoration(
                            color: _statusBgColor(status),
                            border: Border.all(
                              color: color,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 4.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  status,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5, // Lebih kecil!
                                    color: color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
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
          ],
        ),
      ),
    );
  }
}
