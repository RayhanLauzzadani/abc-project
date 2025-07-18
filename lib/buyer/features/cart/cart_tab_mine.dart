import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_detector/focus_detector.dart';
import '../../widgets/cart_box.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/services/address_service.dart';
import '../cart/checkout_summary_page.dart';
import '../../data/models/address.dart';

class CartTabMine extends StatefulWidget {
  final Map<String, bool> storeChecked;
  final Function(String, bool) onStoreCheckedChanged;
  final void Function(List<String> storeIds)? onStoreListChanged;

  const CartTabMine({
    Key? key,
    required this.storeChecked,
    required this.onStoreCheckedChanged,
    this.onStoreListChanged,
  }) : super(key: key);

  @override
  State<CartTabMine> createState() => _CartTabMineState();
}

class _CartTabMineState extends State<CartTabMine> {
  final cartRepo = CartRepository();
  List<StoreCart> storeCarts = [];
  bool isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    fetchCart();
  }

  Future<void> fetchCart() async {
    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() => isLoading = true);
    final carts = await cartRepo.getCart(currentUser!.uid);
    setState(() {
      storeCarts = carts;
      isLoading = false;
    });
  }

  Future<void> _onQtyChanged(StoreCart store, int idx, int qty) async {
    if (currentUser == null) return;
    final item = store.items[idx];
    if (qty == 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini dari keranjang?'),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
                elevation: 0,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await cartRepo.removeCartItem(
          userId: currentUser!.uid,
          storeId: store.storeId,
          productId: item.id,
        );
        await fetchCart();
      }
    } else {
      await cartRepo.updateCartItemQuantity(
        userId: currentUser!.uid,
        storeId: store.storeId,
        productId: item.id,
        quantity: qty,
      );
      await fetchCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil hanya storeId yang dicentang
    final selectedStoreIds = widget.storeChecked.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    // Dapatkan StoreCart yang dicentang
    final selectedStores = storeCarts
        .where((store) => selectedStoreIds.contains(store.storeId))
        .toList();

    // Karena desainmu satu checkout = satu toko, ambil hanya satu
    final selectedStore = selectedStores.isNotEmpty ? selectedStores.first : null;
    final isCheckoutEnabled = selectedStore != null;

    return FocusDetector(
      onFocusGained: () => fetchCart(),
      child: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (storeCarts.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 110,
                    color: Colors.grey[350],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Keranjang Anda masih kosong",
                    style: GoogleFonts.dmSans(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Yuk, mulai tambahkan produk ke keranjang!",
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(bottom: isCheckoutEnabled ? 72 : 0),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: storeCarts.length,
                itemBuilder: (context, i) {
                  final store = storeCarts[i];
                  final checked = widget.storeChecked[store.storeId] ?? false;
                  return CartBox(
                    title: "Keranjang ${i + 1}",
                    storeName: store.storeName,
                    isChecked: checked,
                    onChecked: (v) => widget.onStoreCheckedChanged(store.storeId, v),
                    items: store.items,
                    onQtyChanged: (idx, qty) => _onQtyChanged(store, idx, qty),
                  );
                },
              ),
            ),
          if (isCheckoutEnabled)
            Positioned(
              left: 24,
              right: 24,
              bottom: 16,
              child: ElevatedButton(
                onPressed: () async {
                  if (currentUser == null) return;
                  // Ambil alamat utama user
                  final address = await AddressService().getPrimaryAddressOnce(currentUser!.uid);
                  if (address == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Alamat utama belum tersedia.")),
                    );
                    return;
                  }
                  // Navigasi ke halaman checkout, pass data yg sesuai + NAMA TOKO
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutSummaryPage(
                        address: address,
                        cartItems: selectedStore!.items,
                        storeName: selectedStore.storeName,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  backgroundColor: const Color(0xFF2979FF),
                  elevation: 0,
                ),
                child: Text(
                  "Checkout",
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
