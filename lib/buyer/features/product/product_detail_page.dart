import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/cart/cart_item.dart';
import '../../data/repositories/cart_repository.dart';
import '../../widgets/success_add_cart_popup.dart';
import 'package:abc_e_mart/buyer/features/chat/chat_detail_page.dart';
import 'package:abc_e_mart/buyer/features/cart/checkout_summary_page.dart';
import 'package:abc_e_mart/buyer/data/models/address.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const colorPrimary = Color(0xFF1C55C0);
  static const colorInput = Color(0xFF404040);
  static const colorDivider = Color(0xFFE5E5E5);

  bool _isDescExpanded = false;
  int _selectedVariant = 0;
  bool isBuyNowLoading = false;

  List<String> variants = [];
  static const int descLimit = 160;

  bool isFavoritedProduct = false;
  bool favLoading = false;
  bool isAddCartLoading = false;

  final CartRepository cartRepo = CartRepository();

  String? _productImageUrl;

  @override
  void initState() {
    super.initState();
    _productImageUrl = widget.product['imageUrl'];
    // Ambil data varieties dari Firestore
    variants = List<String>.from(widget.product['varieties'] ?? []);
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

  Future<void> _goToChatDetail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda belum login!")),
      );
      return;
    }

    // Cegah chat ke toko sendiri
    if (user.uid == (widget.product['ownerId'] ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa chat ke toko sendiri!")),
      );
      return;
    }

    // shopId pada product sama dengan id toko tujuan
    final String shopId = widget.product['shopId'];
    final String shopName = widget.product['storeName'] ?? ''; // fallback jika kosong

    // Cari chat yang sudah ada
    final chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('buyerId', isEqualTo: user.uid)
        .where('shopId', isEqualTo: shopId)
        .limit(1)
        .get();

    String chatId;
    if (chatQuery.docs.isNotEmpty) {
      // Sudah ada chat
      chatId = chatQuery.docs.first.id;
    } else {
      // Belum ada chat, buat baru
      final newChat = await FirebaseFirestore.instance.collection('chats').add({
        'buyerId': user.uid,
        'buyerName': user.displayName ?? '',
        'shopId': shopId,
        'shopName': shopName,
        'shopAvatar': widget.product['shopAvatar'] ?? '', // opsional
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
      chatId = newChat.id;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          chatId: chatId,
          shopId: shopId,
          shopName: shopName,
        ),
      ),
    );
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

    final String storeId = widget.product['shopId'];
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
        ownerId: widget.product['ownerId'] ?? '',
      );

      if (!mounted) return;
      // --- POPUP LOTTIE SUCCESS, auto-close 2 detik ---
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SuccessPopup(
          message: "Produk berhasil ditambahkan ke keranjang!",
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // close popup

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

  Future<void> _buyNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda belum login!")),
      );
      return;
    }
    if (user.uid == (widget.product['ownerId'] ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa membeli produk dari toko sendiri!")),
      );
      return;
    }

    setState(() => isBuyNowLoading = true);

    try {
      final addrCol = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      QuerySnapshot<Map<String, dynamic>> q =
          await addrCol.where('isPrimary', isEqualTo: true).limit(1).get();
      if (q.docs.isEmpty) {
        q = await addrCol.where('isDefault', isEqualTo: true).limit(1).get();
      }
      if (q.docs.isEmpty) {
        q = await addrCol.limit(1).get();
      }
      if (q.docs.isEmpty) {
        setState(() => isBuyNowLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anda belum menambahkan alamat pengiriman.")),
        );
        return;
      }

      final addrDoc = q.docs.first;
      final address = AddressModel.fromMap(addrDoc.id, addrDoc.data());

      final item = CartItem(
        id: widget.product['id'],
        name: widget.product['name'],
        image: _productImageUrl ?? '',
        price: widget.product['price'],
        quantity: 1,
        variant: variants.isNotEmpty ? variants[_selectedVariant] : '',
      );

      final String storeName = widget.product['storeName'] ?? '';
      if (!mounted) return;

      // Buka checkout → saat sukses, checkout akan pop() dan kembali ke halaman ini
      await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => CheckoutSummaryPage(
            address: address,
            cartItems: [item],
            storeName: storeName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal membuka checkout: $e")));
    } finally {
      if (mounted) setState(() => isBuyNowLoading = false);
    }
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
    
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == (widget.product['ownerId'] ?? '');

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
                            _circleIcon(
                              icon: Icons.chat_bubble_outline,
                              iconColor: isOwner ? Colors.grey.shade400 : colorPrimary,
                              onTap: isOwner ? null : () => _goToChatDetail(context),
                            ),
                            const SizedBox(width: 8),
                            _circleIcon(
                              icon: isFavoritedProduct ? Icons.favorite : Icons.favorite_border,
                              iconColor: isOwner
                                  ? Colors.grey.shade400
                                  : (isFavoritedProduct ? Colors.red : colorPrimary),
                              onTap: (favLoading || isOwner) ? null : _toggleFavoriteProduct,
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
                child: variants.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text("Tidak ada varian untuk produk ini.",
                          style: GoogleFonts.dmSans(
                            color: Colors.grey,
                            fontSize: 13,
                          )),
                    )
                  : ListView.builder(
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
                        onPressed: (!isOwner && !isAddCartLoading) ? _addToCart : null,
                        style: ButtonStyle(
                          // Border
                          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return BorderSide(color: Colors.grey.shade300, width: 1.3);
                            }
                            return const BorderSide(color: colorPrimary, width: 1.3);
                          }),
                          // Text Color
                          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey.shade400;
                            }
                            return colorPrimary;
                          }),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey.shade100;
                            }
                            return Colors.transparent;
                          }),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        child: isAddCartLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorPrimary),
                            )
                          : Text(
                              "+ Keranjang",
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (!isOwner && !isBuyNowLoading) ? _buyNow : null, // ⟵ ganti
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        child: isBuyNowLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                "Beli Langsung",
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
    const imageHeight = 210.0;

    return SafeArea( // <-- ini yang bikin tidak nabrak status bar
      top: true,
      bottom: false,
      child: Stack(
        children: [
          // Kanvas + gambar contain (anti crop/zoom)
          Container(
            height: imageHeight,
            width: double.infinity,
            color: const Color(0xFFF5F7FB),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image,
                          size: 100,
                          color: _ProductDetailPageState.colorPrimary,
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 100,
                        color: _ProductDetailPageState.colorPrimary,
                      ),
              ),
            ),
          ),

          // tombol back – cukup jarak 12 dari padding SafeArea
          Positioned(
            top: 12,
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
      ),
    );
  }
}
