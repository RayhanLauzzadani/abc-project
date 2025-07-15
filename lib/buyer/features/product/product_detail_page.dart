import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/cart/cart_item.dart';
import '../../data/repositories/cart_repository.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const colorPrimary = Color(0xFF1C55C0);
  static const colorInput = Color(0xFF404040);
  static const colorPlaceholder = Color(0xFF757575);
  static const colorDivider = Color(0xFFE5E5E5);

  bool _isDescExpanded = false;
  int _selectedVariant = 0;

  final List<String> variants = ["Pedas", "Sedang", "Tidak Pedas"];
  static const int descLimit = 160;

  bool isFavoritedProduct = false;
  bool favLoading = false;
  bool isAddCartLoading = false;

  final CartRepository cartRepo = CartRepository();

  String? _productImageUrl;

  @override
  void initState() {
    super.initState();
    _productImageUrl = widget.product['imageUrl']; // Langsung ambil dari Firestore
    _checkIsFavoritedProduct();
  }

  Future<void> _checkIsFavoritedProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final favDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteProducts')
        .doc(widget.product['id'])
        .get();
    setState(() {
      isFavoritedProduct = favDoc.exists;
    });
  }

  Future<void> _toggleFavoriteProduct() async {
    setState(() => favLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteProducts')
        .doc(widget.product['id']);

    if (isFavoritedProduct) {
      await docRef.delete();
    } else {
      await docRef.set({
        'id': widget.product['id'],
        'name': widget.product['name'],
        'imageUrl': _productImageUrl ?? '',
        'price': widget.product['price'],
        'rating': widget.product['rating'] ?? 0,
        'storeId': widget.product['storeId'],
        'description': widget.product['description'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    setState(() {
      isFavoritedProduct = !isFavoritedProduct;
      favLoading = false;
    });
  }

  Future<void> _addToCart() async {
    setState(() => isAddCartLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda belum login!"))
      );
      setState(() => isAddCartLoading = false);
      return;
    }

    final String storeId = widget.product['storeId'];
    final String storeName = widget.product['storeName'] ?? '';

    final selectedVariantName = variants.isNotEmpty ? variants[_selectedVariant] : '';
    final cartItem = CartItem(
      id: widget.product['id'],
      name: widget.product['name'],
      image: _productImageUrl ?? '',
      price: widget.product['price'],
      quantity: 1,
      variant: selectedVariantName,
    );

    try {
      await cartRepo.addOrUpdateCartItem(
        userId: user.uid,
        item: cartItem,
        storeId: storeId,
        storeName: storeName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil ditambahkan ke keranjang!"),
          backgroundColor: colorPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menambah ke keranjang: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => isAddCartLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.product['name'] ?? '';
    final int price = widget.product['price'] ?? 0;
    final String description = widget.product['description'] ?? '';
    final bool isLongDesc = description.length > descLimit;
    final String descShort = isLongDesc
        ? description.substring(0, descLimit) + '...'
        : description;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _ProductImageWithBackButton(
                imageUrl: _productImageUrl,
                onBackTap: () => Navigator.of(context).pop(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _circleIcon(icon: Icons.chat_bubble_outline, onTap: () {}),
                            const SizedBox(width: 8),
                            _circleIcon(
                              icon: isFavoritedProduct ? Icons.favorite : Icons.favorite_border,
                              iconColor: isFavoritedProduct ? Colors.red : colorPrimary,
                              onTap: favLoading ? null : _toggleFavoriteProduct,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(width: double.infinity, height: 1.3, color: colorDivider),
                    const SizedBox(height: 18),
                    Text("Deskripsi",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: colorInput,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedCrossFade(
                      firstChild: Text(descShort,
                        style: GoogleFonts.dmSans(
                          color: Colors.black,
                          fontSize: 14.2,
                          height: 1.45,
                        ),
                      ),
                      secondChild: Text(description,
                        style: GoogleFonts.dmSans(
                          color: Colors.black,
                          fontSize: 14.2,
                          height: 1.45,
                        ),
                      ),
                      crossFadeState: !_isDescExpanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 280),
                    ),
                    if (isLongDesc)
                      GestureDetector(
                        onTap: () => setState(() => _isDescExpanded = !_isDescExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            _isDescExpanded ? "Tutup" : "Read More",
                            style: GoogleFonts.dmSans(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.2,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text("Pilih Varian",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colorInput,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: variants.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    child: ChoiceChip(
                      label: Text(
                        variants[i],
                        style: GoogleFonts.dmSans(
                          color: _selectedVariant == i ? Colors.white : colorPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      selected: _selectedVariant == i,
                      onSelected: (selected) {
                        setState(() => _selectedVariant = i);
                      },
                      showCheckmark: false,
                      selectedColor: colorPrimary,
                      backgroundColor: const Color(0xFFF2F2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 16,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isAddCartLoading ? null : _addToCart,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: colorPrimary, width: 1.3),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: isAddCartLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorPrimary),
                            )
                          : Text("+ Keranjang",
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                                fontSize: 16,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {}, // TODO: Beli langsung
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text("Beli Langsung",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback? onTap,
    Color? iconColor,
    double size = 44,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? colorPrimary, size: 22),
      ),
    );
  }
}

class _ProductImageWithBackButton extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onBackTap;
  const _ProductImageWithBackButton({
    required this.imageUrl,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPadding + 12),
          child: Center(
            child: Container(
              width: 240,
              height: 160,
              decoration: BoxDecoration(
                image: imageUrl == null || imageUrl!.isEmpty
                  ? const DecorationImage(
                      image: AssetImage("assets/images/image-placeholder.png"),
                      fit: BoxFit.contain)
                  : DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.contain,
                    ),
              ),
            ),
          ),
        ),
        Positioned(
          top: topPadding + 12,
          left: 16,
          child: GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _ProductDetailPageState.colorPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
