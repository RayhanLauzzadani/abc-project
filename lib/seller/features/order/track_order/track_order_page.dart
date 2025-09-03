import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:abc_e_mart/seller/features/chat/chat_detail_page.dart';
// Ganti path ini kalau lokasi file berbeda
import 'package:abc_e_mart/seller/features/transaction/transaction_detail_page.dart';

class TrackOrderPageSeller extends StatefulWidget {
  final String orderId;
  const TrackOrderPageSeller({super.key, required this.orderId});

  @override
  State<TrackOrderPageSeller> createState() => _TrackOrderPageSellerState();
}

class _TrackOrderPageSellerState extends State<TrackOrderPageSeller> {
  bool _isAddressExpanded = false;

  int _currentStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'SHIPPED':
        return 1;
      case 'DELIVERED':
      case 'COMPLETED':
      case 'SUCCESS':
        return 2;
      case 'PLACED':
      case 'ACCEPTED':
      default:
        return 0;
    }
  }

  String _step1Title(String status) {
    return status.toUpperCase() == 'PLACED'
        ? 'Menunggu Seller menerima pesanan'
        : 'Produk disiapkan Toko';
  }

  Future<void> _openChat({
    required String buyerId,
    required String buyerName,
    required String buyerAvatar,
  }) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) return;

    // Ambil storeId seller
    final sellerDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final storeId = (sellerDoc.data()?['storeId'] ?? '').toString();
    if (storeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toko anda belum terhubung.')),
      );
      return;
    }

    // Cek apakah chat sudah ada
    final existSnap = await FirebaseFirestore.instance
        .collection('chats')
        .where('shopId', isEqualTo: storeId)
        .where('buyerId', isEqualTo: buyerId)
        .limit(1)
        .get();

    String chatId;
    if (existSnap.docs.isNotEmpty) {
      chatId = existSnap.docs.first.id;
    } else {
      // Buat chat baru
      final ref = FirebaseFirestore.instance.collection('chats').doc();
      await ref.set({
        'shopId': storeId,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerAvatar': buyerAvatar,
        'lastMessage': '',
        'lastTimestamp': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      chatId = ref.id;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerChatDetailPage(
          chatId: chatId,
          buyerId: buyerId,
          buyerName: buyerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docStream =
        FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: false,
          primary: false,
          flexibleSpace: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 40, bottom: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: const BoxDecoration(
                          color: Color(0xFF1C55C0), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Lacak Pesanan',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return Center(
                child: Text('Pesanan tidak ditemukan', style: GoogleFonts.dmSans()));
          }

          final data = snap.data!.data()!;
          final status = (data['status'] ?? 'PLACED') as String;

          // === invoiceId tampilan (fallback ke doc.id)
          final realDocId = snap.data!.id;
          final rawInvoice = (data['invoiceId'] as String?)?.trim();
          final displayedInvoice =
              (rawInvoice != null && rawInvoice.isNotEmpty) ? rawInvoice : realDocId;

          final storeName = (data['storeName'] ?? '-') as String;
          final buyerId = (data['buyerId'] ?? '') as String;

          final addressMap = (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
          final addressLabel = (addressMap['label'] ?? '-') as String;
          final addressText =
              (addressMap['addressText'] ?? addressMap['address'] ?? '-') as String;

          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          final stepIndex = _currentStepIndex(status);
          final step1Title = _step1Title(status);

          // amounts + method dinamis
          final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
          final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
          final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();
          // final tax = ((amounts['tax'] as num?) ?? 0).toInt(); // tidak dipakai di seller
          // final total = ((amounts['total'] as num?) ?? (subtotal + shipping + tax)).toInt();

          final methodRaw =
              ((data['payment']?['method'] ?? 'abc_payment') as String).toUpperCase();
          final methodText = methodRaw == 'ABC_PAYMENT' ? 'ABC Payment' : methodRaw;

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: buyerId.isEmpty
                ? const Stream.empty()
                : FirebaseFirestore.instance.collection('users').doc(buyerId).snapshots(),
            builder: (context, buyerSnap) {
              final buyer = buyerSnap.data?.data();
              final buyerName = (buyer?['name'] ?? '-') as String;
              final buyerAvatar = (buyer?['photoUrl'] ?? '') as String;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Status Pesanan',
                        style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 12),

                    // 1) Disiapkan toko -> subjudul = nama toko
                    _statusItem(
                      title: step1Title,
                      subtitle: storeName,
                      asset: 'assets/icons/store.svg',
                      activeColor: const Color(0xFFDC3545),
                      isReached: stepIndex >= 0,
                    ),
                    const SizedBox(height: 6),
                    _moreIcon(),
                    const SizedBox(height: 6),

                    // 2) Sedang dikirim -> TANPA subjudul
                    _statusItem(
                      title: 'Produk Sedang Dikirim',
                      subtitle: '',
                      asset: 'assets/icons/deliver.svg',
                      activeColor: const Color(0xFF1C55C0),
                      isReached: stepIndex >= 1,
                    ),
                    const SizedBox(height: 6),
                    _moreIcon(),
                    const SizedBox(height: 6),

                    // 3) Sampai tujuan -> subjudul = nama buyer
                    _statusItem(
                      title: 'Produk Sampai Tujuan',
                      subtitle: buyerName,
                      asset: 'assets/icons/circle_check.svg',
                      activeColor: const Color(0xFF28A745),
                      isReached: stepIndex >= 2,
                    ),

                    const SizedBox(height: 16),
                    _divider(),
                    const SizedBox(height: 16),

                    // ===== Detail Pesanan (POV Seller) =====
                    Text('Detail Pesanan',
                        style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 12),

                    // Username Pembeli
                    Text('Username Pembeli',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // foto profil buyer
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: buyerAvatar.isNotEmpty
                              ? Image.network(
                                  buyerAvatar,
                                  width: 60,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _defaultAvatar(),
                                )
                              : _defaultAvatar(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(buyerName,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF373E3C))),
                              const SizedBox(height: 4),
                              // tampilkan invoice (fallback doc.id)
                              Text('#$displayedInvoice',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12, color: const Color(0xFF9A9A9A))),
                            ],
                          ),
                        ),
                        // tombol chat
                        GestureDetector(
                          onTap: () => _openChat(
                            buyerId: buyerId,
                            buyerName: buyerName,
                            buyerAvatar: buyerAvatar,
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                                color: Color(0xFF1C55C0), shape: BoxShape.circle),
                            child: Center(
                              child: SvgPicture.asset('assets/icons/chat.svg',
                                  width: 20, height: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _divider(),
                    const SizedBox(height: 12),

                    // Alamat Pengiriman
                    Text('Alamat Pengiriman',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 6),
                    Text(
                      _isAddressExpanded
                          ? '$addressLabel, $addressText'
                          : '$addressLabel, ${addressText.length > 38 ? "${addressText.substring(0, 38)}..." : addressText}',
                      style: GoogleFonts.dmSans(
                          fontSize: 14, color: const Color(0xFF9A9A9A))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () =>
                          setState(() => _isAddressExpanded = !_isAddressExpanded),
                      child: Text(
                        _isAddressExpanded
                            ? 'Lihat Lebih Sedikit'
                            : 'Lihat Selengkapnya',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: const Color(0xFF1C55C0))),
                    ),

                    const SizedBox(height: 12),
                    _divider(),
                    const SizedBox(height: 12),

                    // Produk yang Dipesan
                    Text('Produk yang Dipesan',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 12),

                    ...items.map((it) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _productRow(
                            name: (it['name'] ?? '-') as String,
                            subtitle: (it['variant'] ?? '') as String,
                            price: ((it['price'] as num?) ?? 0),
                            qty: ((it['qty'] as num?) ?? 0),
                            imageUrl:
                                (it['imageUrl'] ?? it['image'] ?? '') as String,
                          ),
                        )),

                    const SizedBox(height: 14),
                    _divider(),
                    const SizedBox(height: 14),

                    // Nota Pesanan (dinamis + tombol Lihat) — VERSI SELLER
                    _notaPesananCard(
                      methodText: methodText,
                      onView: () {
                        final txMap = _mapOrderToTransaction(
                          displayedId: displayedInvoice,
                          orderDocId: realDocId,
                          data: data,
                          buyerName: buyerName,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailPage(transaction: txMap),
                          ),
                        );
                      },
                      subtotal: subtotal,
                      shipping: shipping,
                      tax: 0, // seller tidak menampilkan pajak
                      total: subtotal + shipping, // total versi seller
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _statusItem({
    required String title,
    required String subtitle,
    required String asset,
    required Color activeColor,
    required bool isReached,
  }) {
    final color = isReached ? activeColor : const Color(0xFFBABABA);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(asset, width: 26, height: 26, color: color),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C))),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: const Color(0xFF9A9A9A))),
          ],
        ),
      ],
    );
  }

  Widget _defaultAvatar() => Container(
        width: 60,
        height: 50,
        color: const Color(0xFFEDEDED),
        child: const Icon(Icons.person, color: Color(0xFF1C55C0), size: 26),
      );

  Widget _moreIcon() => Row(
        children: [
          SvgPicture.asset('assets/icons/more.svg',
              width: 20, height: 20, color: const Color(0xFFBABABA)),
        ],
      );

  Widget _divider() => Container(color: const Color(0xFFF2F2F3), height: 1);

  Widget _productRow({
    required String name,
    required String subtitle,
    required num price,
    required num qty,
    required String imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 95,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, color: Colors.grey),
                )
              : const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C))),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: const Color(0xFF777777))),
              ],
              const SizedBox(height: 8),
              Text('Rp ${_formatRupiah(price.toInt())}',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C))),
            ],
          ),
        ),
        Text('x${qty.toInt()}',
            style:
                GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF9A9A9A))),
      ],
    );
  }

  Widget _notaPesananCard({
    required String methodText,
    required VoidCallback onView,
    required int subtotal,
    required int shipping,
    required int tax, // akan disembunyikan bila 0
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // header + tombol lihat
          Row(
            children: [
              Text('Nota Pesanan',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222))),
              const Spacer(),
              TextButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.receipt_long_rounded,
                    size: 18, color: Color(0xFF2056D3)),
                label: Text('Lihat',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.5, color: Color(0xFF2056D3))),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Metode Pembayaran',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: Color(0xFF828282))),
              Row(
                children: [
                  Text(methodText,
                      style: GoogleFonts.dmSans(
                          fontSize: 13.2, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Image.asset('assets/images/paymentlogo.png', height: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ringkasan singkat
          _feeRow('Subtotal', subtotal),
          const SizedBox(height: 4),
          _feeRow('Biaya Pengiriman', shipping),
          if (tax > 0) ...[
            const SizedBox(height: 4),
            _feeRow('Pajak & Biaya Lainnya', tax),
          ],
          const Divider(height: 16, color: Color(0xFFE5E5E5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.5, fontWeight: FontWeight.w700)),
              Text('Rp ${_formatRupiah(total)}',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.5, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _feeRow(String title, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF777777))),
        Text('Rp ${_formatRupiahStatic(amount)}',
            style: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF373E3C))),
      ],
    );
  }

  String _formatRupiah(int v) => _formatRupiahStatic(v);
  static String _formatRupiahStatic(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromRight = s.length - i;
      b.write(s[i]);
      if (idxFromRight > 1 && idxFromRight % 3 == 1) b.write('.');
    }
    return b.toString();
  }

  // Map dokumen order → map untuk TransactionDetailPage (VERSI SELLER)
  Map<String, dynamic> _mapOrderToTransaction({
    required String displayedId, // invoice tampilan
    required String orderDocId, // doc.id asli (opsional)
    required Map<String, dynamic> data,
    required String buyerName,
  }) {
    final rawStatus =
        ((data['status'] ?? data['shippingAddress']?['status'] ?? 'PLACED') as String)
            .toUpperCase();

    String labelStatus;
    if (rawStatus == 'COMPLETED' ||
        rawStatus == 'DELIVERED' ||
        rawStatus == 'SETTLED' ||
        rawStatus == 'SUCCESS') {
      labelStatus = 'Sukses';
    } else if (rawStatus == 'CANCELLED' ||
        rawStatus == 'CANCELED' ||
        rawStatus == 'REJECTED' ||
        rawStatus == 'FAILED') {
      labelStatus = 'Gagal';
    } else {
      labelStatus = 'Tertahan'; // PLACED / ACCEPTED / SHIPPED
    }

    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final amounts = (data['amounts'] as Map<String, dynamic>?) ?? {};
    final subtotal = ((amounts['subtotal'] as num?) ?? 0).toInt();
    final shipping = ((amounts['shipping'] as num?) ?? 0).toInt();

    // VERSI SELLER:
    final tax = 0;
    final total = subtotal + shipping;

    final createdAt =
        (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null;

    final ship = (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
    final addressLabel = (ship['label'] ?? '-') as String;
    final addressText = (ship['addressText'] ?? ship['address'] ?? '-') as String;
    final phone = (ship['phone'] ?? '-') as String;

    final method =
        ((data['payment']?['method'] ?? 'abc_payment') as String).toUpperCase();

    return {
      'invoiceId': displayedId,
      'orderDocId': orderDocId,
      'status': labelStatus,
      'date': createdAt,
      'buyerName': buyerName,
      'shipping': {
        'recipient': buyerName,
        'addressLabel': addressLabel,
        'addressText': addressText,
        'phone': phone,
      },
      'paymentMethod': method,
      'items': items
          .map((it) => {
                'name': (it['name'] ?? '-') as String,
                'qty': ((it['qty'] as num?) ?? 0).toInt(),
                'price': ((it['price'] as num?) ?? 0).toInt(),
                'variant': (it['variant'] ?? it['note'] ?? '') as String,
              })
          .toList(),
      'amounts': {
        'subtotal': subtotal,
        'shipping': shipping,
        'tax': tax, // 0
        'total': total, // subtotal + shipping
      },
    };
  }
}
