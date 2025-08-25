import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/data/models/address.dart';
import 'package:abc_e_mart/buyer/data/models/cart/cart_item.dart';
import 'package:abc_e_mart/buyer/features/cart/widgets/payment_method_page.dart';
import 'package:abc_e_mart/buyer/features/cart/widgets/order_success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/buyer/data/repositories/cart_repository.dart';

// ===== Helper: format rupiah =====
String formatRupiah(int v) {
  final s = v.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromRight = s.length - i;
    buffer.write(s[i]);
    if (idxFromRight > 1 && idxFromRight % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

class CheckoutSummaryPage extends StatefulWidget {
  final AddressModel address;
  final List<CartItem> cartItems;
  final String storeName;
  final int shippingFee;
  final int taxFee;

  const CheckoutSummaryPage({
    Key? key,
    required this.address,
    required this.cartItems,
    required this.storeName,
    this.shippingFee = 1500,
    this.taxFee = 650,
  }) : super(key: key);

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  String? selectedPaymentMethod; // null -> belum pilih
  bool isLoading = false;

  int get subtotal =>
      widget.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get total => subtotal + widget.shippingFee + widget.taxFee;

  Future<void> _handleCheckout() async {
    if (selectedPaymentMethod != 'ABC Payment') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran ABC Payment terlebih dahulu')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Anda belum login!')));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1) Ambil saldo wallet user
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final wallet = (userDoc.data()?['wallet'] as Map<String, dynamic>?) ?? {};
      final int available =
          wallet['available'] is num ? (wallet['available'] as num).toInt() : 0;

      if (available < total) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saldo ABC Payment tidak cukup. Total: Rp ${formatRupiah(total)}, Saldo: Rp ${formatRupiah(available)}',
            ),
          ),
        );
        return;
      }

      // 2) Ambil sellerId & storeId dari produk pertama (satu toko per checkout)
      final String firstProductId = widget.cartItems.first.id;
      final prodSnap = await FirebaseFirestore.instance
          .collection('products')
          .doc(firstProductId)
          .get();
      final prod = prodSnap.data() ?? {};
      final String sellerId = (prod['ownerId'] ?? '') as String;
      final String storeId = (prod['shopId'] ?? '') as String;

      // 3) Susun items untuk disimpan di orders
      final items = widget.cartItems.map((it) {
        return {
          'productId': it.id,
          'name': it.name,
          'imageUrl': it.image,
          'price': it.price,
          'qty': it.quantity,
          if (it.variant != null) 'variant': it.variant,
        };
      }).toList();

      // 4) Tulis dokumen order
      await FirebaseFirestore.instance.collection('orders').add({
        'buyerId': user.uid,
        'sellerId': sellerId,
        'storeId': storeId,
        'storeName': widget.storeName,
        'items': items,
        'amounts': {
          'subtotal': subtotal,
          'shipping': widget.shippingFee,
          'tax': widget.taxFee,
          'total': total,
        },
        'payment': {
          'method': 'abc_payment',
          'status': 'ESCROWED', // dana dianggap di-hold (UI saja dulu)
        },
        'status': 'PLACED',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // meta opsional — tanpa receiver/phone karena tidak ada di AddressModel
        'shippingAddress': {
          'label': widget.address.label,
          'address': widget.address.address,
        },
      });

      try {
        final cartRepo = CartRepository();
        for (final it in widget.cartItems) {
          await cartRepo.removeCartItem(
            userId: user.uid,
            storeId: storeId,
            productId: it.id,
          );
        }
      } catch (_) {
        // diamkan saja kalau gagal menghapus; pesanan sudah tercatat
      }

      setState(() => isLoading = false);

      // 5) Tampilkan animasi sukses (auto tutup) lalu keluar dari halaman ini
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const OrderSuccessDialog(
          message: 'Pesanan Anda berhasil dibuat!',
          lottiePath: 'assets/lottie/success_check.json',
          lottieSize: 120,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      Navigator.of(context).pop(); // tutup dialog
      Navigator.of(context).pop(); // kembali ke halaman sebelumnya (keranjang)

      // NOTE: kalau ingin mengosongkan keranjang setelah sukses, panggil repo di sini.
      // await CartRepository().clearStoreCart(userId: user.uid, storeId: storeId);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pesanan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 37, height: 37,
                      decoration: const BoxDecoration(color: Color(0xFF1C55C0), shape: BoxShape.circle),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text('Rangkuman Transaksi',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF373E3C))),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Alamat
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Alamat Pengiriman',
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 20, color: const Color(0xFF373E3C))),
                        ),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _AddressCard(address: widget.address),
                        ),
                        const SizedBox(height: 13),

                        // Produk
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Produk di Keranjang',
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 20, color: const Color(0xFF373E3C))),
                        ),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                            child: Column(
                              children: List.generate(
                                widget.cartItems.length,
                                (i) => Padding(
                                  padding: EdgeInsets.only(bottom: i < widget.cartItems.length - 1 ? 14 : 0),
                                  child: _ProductCheckoutItem(item: widget.cartItems[i]),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),

                        // Detail Tagihan
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Detail Tagihan',
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 20, color: const Color(0xFF373E3C))),
                        ),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            child: Column(
                              children: [
                                _SummaryRow(label: 'Subtotal', value: subtotal),
                                const SizedBox(height: 8),
                                _SummaryRow(label: 'Biaya Pengiriman', value: widget.shippingFee),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(thickness: 1, color: Color(0xFFE5E5E5), height: 1),
                                ),
                                _SummaryRow(label: 'Total', value: total, isTotal: true),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Metode Pembayaran (buka halaman pilih)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Metode Pembayaran',
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 20, color: const Color(0xFF373E3C))),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final result = await Navigator.push<String?>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentMethodPage(initialMethod: selectedPaymentMethod),
                                ),
                              );
                              if (result != null) {
                                setState(() => selectedPaymentMethod = result);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE5E5E5)),
                              ),
                              child: Row(
                                children: [
                                  if (selectedPaymentMethod == 'ABC Payment')
                                    Image.asset('assets/images/paymentlogo.png', width: 24, height: 24, fit: BoxFit.cover)
                                  else
                                    const Icon(Icons.credit_card_rounded, size: 21, color: Color(0xFF353A3F)),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Text(
                                      selectedPaymentMethod ?? 'Pilih Metode Pembayaran',
                                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 16, color: const Color(0xFF3B3B3B)),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD)),
                                ],
                              ),
                            ),
                          ),
                        ),

                        if (currentUser != null && selectedPaymentMethod == 'ABC Payment') ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .snapshots(),
                              builder: (context, snap) {
                                final data = snap.data?.data();
                                final wallet = (data?['wallet'] as Map<String, dynamic>?) ?? {};
                                final available = wallet['available'] is num
                                    ? (wallet['available'] as num).toInt()
                                    : 0;
                                final enough = available >= total;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Saldo ABC Payment',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13.5, color: Colors.grey[800], fontWeight: FontWeight.w500)),
                                    Row(
                                      children: [
                                        Text('Rp ${formatRupiah(available)}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black87)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: enough ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(
                                              color: enough ? const Color(0xFF66BB6A) : const Color(0xFFE57373),
                                            ),
                                          ),
                                          child: Text(enough ? 'Cukup' : 'Tidak cukup',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 11, fontWeight: FontWeight.w700,
                                              color: enough ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isLoading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, -2))],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C55C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              onPressed: isLoading ? null : _handleCheckout,
              child: isLoading
                  ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Pesan Sekarang',
                      style:
                          GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFFAFAFA))),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Widget pendukung (tetap) ---
class _AddressCard extends StatelessWidget {
  final AddressModel address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/location.svg', width: 32, height: 32, color: const Color(0xFF777777)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.label,
                    style:
                        GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF232323))),
                const SizedBox(height: 4),
                Text(address.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF979797))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF373E3C)),
        ],
      ),
    );
  }
}

class _ProductCheckoutItem extends StatelessWidget {
  final CartItem item;
  const _ProductCheckoutItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          Container(
            width: 89, height: 76,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: item.image.isNotEmpty
                ? Image.network(
                    item.image,
                    width: 89, height: 76, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 32, color: Colors.grey),
                  )
                : const Icon(Icons.image, size: 32, color: Colors.grey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF373E3C))),
                if (item.variant != null && item.variant!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.variant!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF777777))),
                ],
                const SizedBox(height: 8),
                // Harga & Qty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp ${formatRupiah(item.price)}',
                        style:
                            GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF373E3C))),
                    Text("x${item.quantity}",
                        style:
                            GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF373E3C))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: isTotal ? 17 : 15,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.black : Colors.grey[800])),
        Text("Rp ${formatRupiah(value)}",
            style: GoogleFonts.dmSans(
                fontSize: isTotal ? 17 : 15,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.black : Colors.grey[800])),
      ],
    );
  }
}