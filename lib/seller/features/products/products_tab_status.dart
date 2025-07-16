import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/search_bar.dart' as custom_widgets;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abc_e_mart/seller/features/products/detail_product/detail_product.dart';

class ProductsTabStatus extends StatefulWidget {
  final String storeId;
  final int initialTab;
  const ProductsTabStatus({
    super.key,
    required this.storeId,
    this.initialTab = 0,
  });

  @override
  State<ProductsTabStatus> createState() => _ProductsTabStatusState();
}

class _ProductsTabStatusState extends State<ProductsTabStatus> {
  int selectedCategory = 0;
  String searchQuery = "";

  final List<String> statusCategories = [
    'Semua',
    'Menunggu',
    'Ditolak',
  ];

  // mapping firestore status -> label status UI
  String _mapStatus(String firestoreStatus) {
    switch (firestoreStatus) {
      case "pending":
        return "Menunggu";
      case "rejected":
        return "Ditolak";
      default:
        return firestoreStatus;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final storeId = widget.storeId;

    if (storeId.isEmpty) {
      return const Center(child: Text("Toko belum ditemukan/Belum diapprove"));
    }

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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('productsApplication')
                .where('storeId', isEqualTo: storeId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? [];
              List<Map<String, dynamic>> products = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = _mapStatus(data['status'] ?? '');
                return {
                  'id': doc.id,
                  'image': data['imageUrl'] ?? '',
                  'name': data['name'] ?? '-',
                  'stock': data['stock'] ?? 0,
                  'price': data['price'] ?? 0,
                  'category': data['category'] ?? '-',
                  'status': status,
                  'description': data['description'] ?? '',
                  'storeName': data['storeName'] ?? '',
                  // tambahkan field lain sesuai kebutuhan approval
                };
              }).toList();

              // Filter produk sesuai search & status
              List<Map<String, dynamic>> filteredProducts = products.where((
                prod,
              ) {
                bool matchesSearch =
                    searchQuery.isEmpty ||
                    prod['name'].toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    );
                bool matchesCategory =
                    selectedCategory == 0 ||
                    prod['status'] == statusCategories[selectedCategory];
                return matchesSearch && matchesCategory;
              }).toList();

              if (filteredProducts.isEmpty) {
                return Center(
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
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: filteredProducts.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                final product = filteredProducts[idx];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellerProductDetailPage(
                          productId: product['id'],
                          fromApplication: true,
                        ),
                      ),
                    );
                  },
                  child: _ProductCardStatus(product: product),
                );
              }
              );
            },
          ),
        ),
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
      case 'Menunggu':
        return const Color(0xFFFFD600);
      case 'Ditolak':
        return const Color(0xFFFF5B5B);
      default:
        return const Color(0xFF2066CF);
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
              right: idx < statusList.length - 1 ? 8 : 0,
            ),
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

// Card produk status
class _ProductCardStatus extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCardStatus({required this.product});

  Color _statusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return const Color(0xFFFFB800);
      case 'Ditolak':
        return const Color(0xFFFF5B5B);
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
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produk dari URL
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (product['image'] as String).isNotEmpty
                  ? Image.network(
                      product['image'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Icon(
                        LucideIcons.image,
                        color: Colors.grey[400],
                        size: 32,
                      ),
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
                        const SizedBox(width: 8),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 0,
                            maxWidth: 74,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBgColor(status),
                            border: Border.all(color: color, width: 1),
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
                                    fontSize: 11.5,
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
                      ],
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
