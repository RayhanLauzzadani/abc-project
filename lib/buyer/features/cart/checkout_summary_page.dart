import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/data/models/address.dart';
import 'package:abc_e_mart/buyer/data/models/cart/cart_item.dart';
import 'package:abc_e_mart/buyer/features/cart/widgets/payment_method_page.dart';
// Import page QRIS!
import 'package:abc_e_mart/buyer/features/payment/qris_waiting_page.dart';

class CheckoutSummaryPage extends StatefulWidget {
  final AddressModel address;
  final List<CartItem> cartItems;
  final int shippingFee;
  final int taxFee;

  const CheckoutSummaryPage({
    Key? key,
    required this.address,
    required this.cartItems,
    this.shippingFee = 1500,
    this.taxFee = 650,
  }) : super(key: key);

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  String? selectedPaymentMethod;

  int get subtotal =>
      widget.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get total => subtotal + widget.shippingFee + widget.taxFee;

  void _handleCheckout() async {
    if (selectedPaymentMethod == 'QRIS') {
      // Dummy: nanti replace dari backend atau order Firestore/Midtrans
      final String orderId = "ORDER12345";
      final String qrData = "https://qris-dummy.com/qr/ORDER12345";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QrisWaitingPage(
            total: total,
            orderId: orderId,
            qrData: qrData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C55C0),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Rangkuman Transaksi',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable content below
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION: ALAMAT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Alamat Pengiriman',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _AddressCard(address: widget.address),
                    ),
                    const SizedBox(height: 13),
                    // PRODUK
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Produk di Keranjang',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 18,
                        ),
                        child: Column(
                          children: List.generate(
                            widget.cartItems.length,
                            (i) => Padding(
                              padding: EdgeInsets.only(
                                bottom: i < widget.cartItems.length - 1 ? 14 : 0,
                              ),
                              child: _ProductCheckoutItem(item: widget.cartItems[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    // DETAIL TAGIHAN
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Detail Tagihan',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(label: 'Subtotal', value: subtotal),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Biaya Pengiriman',
                              value: widget.shippingFee,
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFFE5E5E5),
                                height: 1,
                              ),
                            ),
                            _SummaryRow(
                              label: 'Total',
                              value: total,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // METODE PEMBAYARAN
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Metode Pembayaran',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodPage(
                                initialMethod: selectedPaymentMethod,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              selectedPaymentMethod = result as String?;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E5E5)),
                          ),
                          child: Row(
                            children: [
                              selectedPaymentMethod == 'QRIS'
                                  ? Image.asset(
                                      'assets/images/qris.png',
                                      width: 24,
                                      height: 24,
                                    )
                                  : const Icon(
                                      Icons.credit_card_rounded,
                                      size: 21,
                                      color: Color(0xFF353A3F),
                                    ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  selectedPaymentMethod == null
                                      ? 'Pilih Metode Pembayaran'
                                      : selectedPaymentMethod!,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: const Color(0xFF3B3B3B),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFBDBDBD),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 14,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C55C0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
            onPressed: _handleCheckout,
            child: Text(
              'Pesan Sekarang',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFAFAFA),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Widget pendukung ---
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
          SvgPicture.asset(
            'assets/icons/location.svg',
            width: 32,
            height: 32,
            color: Color(0xFF777777),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF232323),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    color: const Color(0xFF979797),
                  ),
                ),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          Container(
            width: 89,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.image.isNotEmpty
                ? Image.network(
                    item.image,
                    width: 89,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 32, color: Colors.grey),
                  )
                : const Icon(Icons.image, size: 32, color: Colors.grey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C),
                  ),
                ),
                if (item.variant != null && item.variant!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variant!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Harga & Qty sejajar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${item.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    Row(
                      children: [
                        _QtyCircleButton(icon: Icons.remove, onPressed: () {}),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            item.quantity.toString(),
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF373E3C),
                            ),
                          ),
                        ),
                        _QtyCircleButton(icon: Icons.add, onPressed: () {}),
                      ],
                    ),
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

class _QtyCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QtyCircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: const Color(0xFF2056D3),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(child: Icon(icon, color: Colors.white, size: 16)),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: isTotal ? 17 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[800],
          ),
        ),
        Text(
          "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",
          style: GoogleFonts.dmSans(
            fontSize: isTotal ? 17 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
