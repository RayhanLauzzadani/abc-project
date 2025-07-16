import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/search_bar.dart' as custom_widgets;
import '../../../widgets/category_selector.dart';
import '../../../data/models/category_type.dart';
import 'package:abc_e_mart/seller/data/models/product_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:abc_e_mart/seller/widgets/success_delete_product.dart';
import 'package:abc_e_mart/seller/features/products/edit_product/edit_product.dart';
import 'package:abc_e_mart/seller/features/products/detail_product/detail_product.dart';

class ProductsTabMine extends StatefulWidget {
  final String storeId;

  const ProductsTabMine({super.key, required this.storeId});

  @override
  State<ProductsTabMine> createState() => _ProductsTabMineState();
}

class _ProductsTabMineState extends State<ProductsTabMine> {
  int selectedCategory = 0;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final storeId = widget.storeId;

    if (storeId.isEmpty) {
      // Handle case: user belum punya toko (opsional)
      return Center(
        child: Text(
          "Kamu belum punya toko.\nAjukan toko dulu ya!",
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      );
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
        // List produk dari Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('shopId', isEqualTo: storeId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Terjadi error!'));
              }
              final docs = snapshot.data?.docs ?? [];

              // Mapping ke model
              List<ProductModel> products = docs
                  .map((doc) => ProductModel.fromDoc(doc))
                  .toList();

              // === Filter by kategori & search
              products = products.where((prod) {
                final matchSearch = searchQuery.isEmpty ||
                    prod.name.toLowerCase().contains(searchQuery.toLowerCase());
                final matchCat = selectedCategory == 0 ||
                    CategoryType.values[selectedCategory - 1]
                        .name
                        .toLowerCase() ==
                        prod.category.toLowerCase();
                return matchSearch && matchCat;
              }).toList();

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.packageSearch,
                        size: 90,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        selectedCategory == 0 && searchQuery.isEmpty
                            ? "Produk toko kamu masih kosong"
                            : "Tidak ada produk di kategori ini",
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedCategory == 0 && searchQuery.isEmpty
                            ? "Yuk, tambah produk pertama kamu!"
                            : "Tambah produk baru atau pilih kategori lain.",
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: products.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final product = products[idx];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SellerProductDetailPage(
                            productId: product.id,
                            fromApplication: false,
                          ),
                        ),
                      );
                    },
                    child: _ProductCardMine(
                      product: product,
                      onEdit: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductPage(productId: product.id),
                          ),
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      },
                      onDelete: () => _showDeleteDialog(context, product),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, ProductModel product) {
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
          "Anda yakin ingin menghapus produk \"${product.name}\"?",
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
                  onPressed: () async {
                    // Tutup dialog konfirmasi dulu
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 100));

                    // Proses hapus
                    try {
                      // 1. Hapus file di Storage kalau ada
                      String? imageUrl = product.imageUrl;
                      if (imageUrl.isNotEmpty) {
                        Uri uri = Uri.parse(imageUrl);
                        String? pathInStorage;
                        final segments = uri.pathSegments;
                        final oIndex = segments.indexOf('o');
                        if (oIndex != -1 && oIndex + 1 < segments.length) {
                          pathInStorage = Uri.decodeFull(segments[oIndex + 1]);
                        } else {
                          pathInStorage = uri.queryParameters['name'];
                        }
                        if (pathInStorage != null && pathInStorage.isNotEmpty) {
                          final ref = FirebaseStorage.instance.ref().child(pathInStorage);
                          await ref.delete();
                        }
                      }
                    } catch (_) {}

                    // 2. Hapus data Firestore
                    await FirebaseFirestore.instance
                        .collection('products')
                        .doc(product.id)
                        .delete();

                    // 3. Tampilkan dialog animasi berhasil hapus (otomatis menutup)
                    if (mounted) {
                      await SuccessDeleteDialog(
                        context: context,
                        title: 'Produk berhasil dihapus!',
                        message: 'Produk "${product.name}" telah dihapus dari toko kamu.',
                        lottieAsset: 'assets/lottie/success_check.json', // ganti sesuai asset kamu
                        duration: const Duration(milliseconds: 1600),
                      );
                    }
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
  final ProductModel product;
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
            // Image produk (pakai NetworkImage!)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Icon(LucideIcons.image, color: Colors.grey[400], size: 32),
                    ),
            ),
            const SizedBox(width: 13),
            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF232323),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Stok: ${product.stock}",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: const Color(0xFF818181),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rp ${product.price}",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: const Color(0xFF818181),
                    ),
                  ),
                  // Menampilkan produk terjual jika ingin
                  if (product.sold > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        "Terjual: ${product.sold}",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: const Color(0xFF8D8D8D),
                        ),
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
