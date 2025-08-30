import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromoBannerCarousel extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onBannerTap;
  const PromoBannerCarousel({super.key, this.onBannerTap});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _autoSlideTimer;
  List<Map<String, dynamic>> allBanners = [];

  @override
  void initState() {
    super.initState();
    _fetchBanners();

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (allBanners.isEmpty) return;
      if (!_controller.hasClients) return;
      final nextPage = (_currentIndex + 1) % allBanners.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  String _sanitize(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return s;
    // buang kutip nyasar dari data RC/Firestore
    return s.replaceAll('"', '').replaceAll("'", '');
  }

  Future<void> _fetchBanners() async {
    if (!mounted) return;
    setState(() => allBanners = []);

    try {
      final now = DateTime.now();
      final snapshot = await FirebaseFirestore.instance
          .collection('adsApplication')
          .where('status', isEqualTo: 'disetujui')
          .get();

      final List<Map<String, dynamic>> banners = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? mulaiTS = data['durasiMulai'];
        final Timestamp? selesaiTS = data['durasiSelesai'];
        if (mulaiTS == null || selesaiTS == null) continue;

        final mulai = mulaiTS.toDate();
        final selesai = selesaiTS.toDate();

        // inclusive
        if (now.compareTo(mulai) >= 0 && now.compareTo(selesai) <= 0) {
          final bannerUrl = _sanitize(data['bannerUrl']);
          banners.add({
            'id': doc.id,
            'judul': data['judul'] ?? '',
            'deskripsi': data['deskripsi'] ?? '',
            'imageUrl': bannerUrl,
            'logoUrl': _sanitize(data['logoUrl']),
            'storeName': data['storeName'] ?? '',
            'buttonText': 'Kunjungi Toko',
            'productId': _sanitize(data['productId']),
            'isAsset': bannerUrl.startsWith('assets/'), // kalau ada yang simpan path asset
          });
        }
      }

      if (!mounted) return;
      setState(() {
        // fallback konsisten .png
        allBanners = banners.isEmpty
            ? [
                {'imageUrl': 'assets/images/banner1.png', 'isAsset': true},
                {'imageUrl': 'assets/images/banner2.png', 'isAsset': true},
              ]
            : banners;
      });
    } catch (e, st) {
      // debug log
      // ignore: avoid_print
      print('Firestore banner error: $e\n$st');

      if (!mounted) return;
      setState(() {
        // JANGAN pakai .jpg di sini. Samakan dengan aset yang ada (.png)
        allBanners = [
          {'imageUrl': 'assets/images/banner1.png', 'isAsset': true},
          {'imageUrl': 'assets/images/banner2.png', 'isAsset': true},
        ];
      });
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 40;
    cardWidth = cardWidth.clamp(0.0, 390.0);

    if (allBanners.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 160,
      width: cardWidth,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: allBanners.length,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final data = allBanners[index];
              final isAsset = data['isAsset'] == true;
              final src = _sanitize(data['imageUrl']);

              final image = ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isAsset
                    ? Image.asset(
                        src,
                        width: cardWidth,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackBox(),
                      )
                    : Image.network(
                        src,
                        width: cardWidth,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackBox(),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 1.8),
                                    ),
                                  ),
                      ),
              );

              final clickable = !isAsset && widget.onBannerTap != null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: clickable
                    ? GestureDetector(onTap: () => widget.onBannerTap!(data), child: image)
                    : image,
              );
            },
          ),

          // Dots
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                allBanners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == i ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == i ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black12, width: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackBox() => Container(
        width: double.infinity,
        height: 160,
        color: const Color(0xFFEDEDED),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 36, color: Colors.grey),
      );
}
