import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/buyer/features/chat/chat_detail_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
// ⬇️ popup sukses baru
import 'package:abc_e_mart/buyer/features/order/widgets/order_success_pop_up.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  bool _isAddressExpanded = false;
  final _scrollController = ScrollController();
  bool _completing = false; // ⬅️ untuk disable tombol + spinner

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Buyer menutup pesanan -> panggil CF completeOrder
  Future<void> _markAsCompleted() async {
    if (_completing) return;
    setState(() => _completing = true);
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'asia-southeast2');
      await functions.httpsCallable('completeOrder').call({'orderId': widget.orderId});

      if (!mounted) return;

      // Tampilkan animasi sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const OrderArrivedDialog(
          message: "Pesanan telah sampai. Selamat menikmati! 🎉",
          lottiePath: "assets/lottie/success_check.json",
          lottieSize: 120,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1300));
      if (!mounted) return;
      Navigator.of(context).pop(); // tutup dialog
      Navigator.of(context).pop(); // tutup halaman tracking (order pindah ke Riwayat)
    } on FirebaseFunctionsException catch (e) {
      final msg = e.message ?? 'Gagal menyelesaikan pesanan.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyelesaikan pesanan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  // Buat/ambil chat antara buyer & toko
  Future<void> _openChatToStore({
    required String storeId,
    required String storeName,
    required String storeLogoUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // profil buyer (untuk metadata chat)
    final buyerDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final buyerName = (buyerDoc.data()?['name'] ?? '') as String;
    final buyerAvatar = (buyerDoc.data()?['photoUrl'] ?? '') as String;

    // cek apakah thread sudah ada
    final existSnap = await FirebaseFirestore.instance
        .collection('chats')
        .where('buyerId', isEqualTo: user.uid)
        .where('shopId', isEqualTo: storeId)
        .limit(1)
        .get();

    String chatId;
    if (existSnap.docs.isNotEmpty) {
      chatId = existSnap.docs.first.id;
    } else {
      final ref = FirebaseFirestore.instance.collection('chats').doc();
      await ref.set({
        'shopId': storeId,
        'shopName': storeName,
        'shopAvatar': storeLogoUrl,   // dipakai di list buyer
        'logoUrl': storeLogoUrl,      // fallback jika widget lama pakai key ini
        'buyerId': user.uid,
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
        builder: (_) =>
            ChatDetailPage(chatId: chatId, shopId: storeId, shopName: storeName),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final docStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots();

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
              // spacing lebih rapat seperti halaman seller
              padding: const EdgeInsets.only(left: 20, top: 40, bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 37, height: 37,
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
            return Center(child: Text('Pesanan tidak ditemukan',
                style: GoogleFonts.dmSans()));
          }

          final data = snap.data!.data()!;
          final status = (data['status'] ?? 'PLACED') as String;
          final storeName = (data['storeName'] ?? '-') as String;
          final storeId = (data['storeId'] ?? '') as String;
          final orderId = snap.data!.id;

          final addressMap =
              (data['shippingAddress'] as Map<String, dynamic>?) ?? {};
          final addressLabel = (addressMap['label'] ?? '-') as String;
          final addressText = (addressMap['address'] ?? '-') as String;

          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          final stepIndex = _currentStepIndex(status);
          final step1Title = _step1Title(status);

          // ambil logo toko dari stores/{storeId}.logoUrl
          final Stream<DocumentSnapshot<Map<String, dynamic>>> storeStream =
            storeId.isEmpty
                ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
                : FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .snapshots();

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: storeStream,
            builder: (context, storeSnap) {
              final storeData = storeSnap.data?.data();
              final logoUrl = (storeData?['logoUrl'] ?? '') as String;

              return SingleChildScrollView(
                key: PageStorageKey('order-tracking-${widget.orderId}'),
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Status Pesanan',
                        style: GoogleFonts.dmSans(
                            fontSize: 22, fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 12),

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

                    // step 2: tanpa subjudul (lebih rapat)
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

                    _statusItem(
                      title: 'Produk Sampai Tujuan',
                      subtitle: storeName,
                      asset: 'assets/icons/circle_check.svg',
                      activeColor: const Color(0xFF28A745),
                      isReached: stepIndex >= 2,
                    ),

                    const SizedBox(height: 16),
                    _divider(),
                    const SizedBox(height: 16),

                    // ===== Detail Pesanan =====
                    Text('Detail Pesanan',
                        style: GoogleFonts.dmSans(
                            fontSize: 22, fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 12),

                    // Header toko: logo dari stores & tombol chat
                    _storeHeader(
                      storeName: storeName,
                      orderId: orderId,
                      logoUrl: logoUrl,
                      onChatTap: storeId.isEmpty
                          ? null
                          : () => _openChatToStore(
                                storeId: storeId,
                                storeName: storeName,
                                storeLogoUrl: logoUrl,
                              ),
                    ),

                    const SizedBox(height: 12),
                    _divider(),
                    const SizedBox(height: 12),

                    // Alamat Pengiriman
                    Text('Alamat Pengiriman',
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.bold,
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
                        _isAddressExpanded ? 'Lihat Lebih Sedikit' : 'Lihat Selengkapnya',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: const Color(0xFF1C55C0))),
                    ),

                    const SizedBox(height: 12),
                    _divider(),
                    const SizedBox(height: 12),

                    // Produk yang dipesan
                    Text('Produk yang Dipesan',
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.bold,
                            color: const Color(0xFF373E3C))),
                    const SizedBox(height: 12),

                    ...items.map((it) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _productRow(
                            name: (it['name'] ?? '-') as String,
                            subtitle: (it['variant'] ?? '') as String,
                            price: (it['price'] ?? 0) as num,
                            qty: (it['qty'] ?? 0) as num,
                            imageUrl: (it['imageUrl'] ?? '') as String,
                          ),
                        )),

                    const SizedBox(height: 14),
                    _divider(),
                    const SizedBox(height: 14),

                    // Nota Pesanan
                    _notaPesananCard(methodText: 'ABC Payment'),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),

      // Tombol muncul saat status = SHIPPED (seller sudah kirim)
      bottomNavigationBar: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snap) {
          final s = (snap.data?.data()?['status'] ?? '') as String;
          final showBtn = s.toUpperCase() == 'SHIPPED';
          if (!showBtn) return const SizedBox.shrink();
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                    elevation: 0),
                  onPressed: _completing ? null : _markAsCompleted,
                  child: _completing
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Produk Sudah Sampai',
                          style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: const Color(0xFFFAFAFA))),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- UI helpers ----------------
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
                    fontSize: 12, fontWeight: FontWeight.bold,
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

  Widget _moreIcon() => Row(
    children: [
      SvgPicture.asset('assets/icons/more.svg', width: 20, height: 20,
          color: const Color(0xFFBABABA)),
    ],
  );

  Widget _divider() => Container(color: const Color(0xFFF2F2F3), height: 1);

  // header toko: logo dari storage (via stores.logoUrl) + tombol chat
  Widget _storeHeader({
    required String storeName,
    required String orderId,
    required String logoUrl,
    required VoidCallback? onChatTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nama Toko',
          style: GoogleFonts.dmSans(
              fontSize: 16, fontWeight: FontWeight.bold,
              color: const Color(0xFF373E3C))),
        const SizedBox(height: 14),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      width: 89,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _storePlaceholder(),
                    )
                  : _storePlaceholder(),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(storeName,
                  style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C))),
              const SizedBox(height: 4),
              Text('#$orderId',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: const Color(0xFF9A9A9A))),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: onChatTap,
              child: Container(
                width: 40, height: 40,
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
      ],
    );
  }

  Widget _storePlaceholder() => Container(
        width: 89, height: 76,
        color: const Color(0xFFEDEDED),
        child: const Icon(Icons.store, color: Color(0xFF1C55C0), size: 28),
      );

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
          width: 95, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl.isNotEmpty
              ? Image.network(imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, color: Colors.grey))
              : const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.bold,
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
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C))),
            ],
          ),
        ),
        Text('x${qty.toInt()}',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: const Color(0xFF9A9A9A))),
      ],
    );
  }

  Widget _notaPesananCard({required String methodText}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Metode Pembayaran',
              style: GoogleFonts.dmSans(
                  fontSize: 16, color: const Color(0xFF777777))),
          Row(
            children: [
              Text(methodText,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: const Color(0xFF373E3C))),
              const SizedBox(width: 10),
              Image.asset('assets/images/paymentlogo.png', width: 32, height: 32),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromRight = s.length - i;
      b.write(s[i]);
      if (idxFromRight > 1 && idxFromRight % 3 == 1) b.write('.');
    }
    return b.toString();
  }
}
