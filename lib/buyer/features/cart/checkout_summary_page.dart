import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/data/models/address.dart';
import 'package:abc_e_mart/buyer/data/models/cart/cart_item.dart';
import 'package:abc_e_mart/buyer/features/cart/widgets/payment_method_page.dart';
import 'package:abc_e_mart/buyer/features/payment/qris_waiting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? selectedPaymentMethod;
  bool isLoading = false;

  int get subtotal => widget.cartItems.fold(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
  int get total => subtotal + widget.shippingFee + widget.taxFee;

  // GANTI URL INI SESUAI punyamu!
  static const String cloudFunctionUrl =
      'https://createqristransaction-glfq7sg2la-uc.a.run.app';

  Future<Map<String, dynamic>> createQrisTransactionHttp({
    required int amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
  }) async {
    final response = await http.post(
      Uri.parse(cloudFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'orderId': orderId,
        'customerName': customerName,
        'customerEmail': customerEmail,
      }),
    );

    // Sukses Midtrans: status 201, kadang 200 juga.
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      try {
        final err = jsonDecode(response.body);
        throw Exception(
          "QRIS Error: ${err['status_message'] ?? err['message'] ?? response.body}",
        );
      } catch (_) {
        throw Exception("QRIS Error: ${response.body}");
      }
    }
  }

  Future<void> _handleCheckout() async {
    if (selectedPaymentMethod == 'QRIS') {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Anda belum login!')));
        return;
      }

      setState(() => isLoading = true);

      final String orderId = "ORDER${DateTime.now().millisecondsSinceEpoch}";
      try {
        final qrisResult = await createQrisTransactionHttp(
          amount: total,
          orderId: orderId,
          customerName: user.displayName ?? "Nama Pengguna",
          customerEmail: user.email ?? "user@email.com",
        );

        // --- Parsing Midtrans QRIS
        String? qrString;
        if (qrisResult['actions'] != null &&
            qrisResult['actions'] is List &&
            (qrisResult['actions'] as List).isNotEmpty) {
          try {
            final qrAction = (qrisResult['actions'] as List).firstWhere(
              (a) => a['name'] == 'generate-qr-code',
              orElse: () => null,
            );
            if (qrAction != null && qrAction['url'] != null) {
              qrString = qrAction['url'] as String?;
            }
          } catch (_) {}
        }
        // Fallback ke qr_string jika ada
        qrString ??= qrisResult['qr_string'];

        if (qrString == null || qrString.isEmpty) {
          print("== Full QRIS response ==");
          print(jsonEncode(qrisResult));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal mendapatkan QRIS: ${qrisResult['status_message'] ?? ''}',
              ),
            ),
          );
          setState(() => isLoading = false);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrisWaitingPage(
              total: total,
              orderId: orderId,
              qrData: qrString!,
              jumlahPesanan: widget.cartItems.length,
              namaToko: widget.storeName,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat transaksi QRIS: $e')),
        );
      }
      setState(() => isLoading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
        ),
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
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    bottom: i < widget.cartItems.length - 1
                                        ? 14
                                        : 0,
                                  ),
                                  child: _ProductCheckoutItem(
                                    item: widget.cartItems[i],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
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
                                border: Border.all(
                                  color: const Color(0xFFE5E5E5),
                                ),
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
                  if (isLoading)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
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
              onPressed: isLoading ? null : _handleCheckout,
              child: isLoading
                  ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
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
      ),
    );
  }
}

// --- Widget pendukung, TIDAK ADA YANG DIUBAH kecuali bagian qty product ---
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
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
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
                // Harga & Qty sejajar (tanpa tombol plus/minus)
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
                    Text(
                      "x${item.quantity}",
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      ),
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

// _QtyCircleButton dihapus, tidak dipakai lagi

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
