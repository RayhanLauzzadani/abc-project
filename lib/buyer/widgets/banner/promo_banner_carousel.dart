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
      if (allBanners.isEmpty) return;
      int nextPage = (_currentIndex + 1) % allBanners.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _fetchBanners() async {
    setState(() {
      allBanners = [];
    });

    try {
      final now = DateTime.now();
      final snapshot = await FirebaseFirestore.instance
        .collection('adsApplication')
        .where('status', isEqualTo: 'disetujui')
        .get();

      List<Map<String, dynamic>> banners = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? mulaiTS = data['durasiMulai'];
        final Timestamp? selesaiTS = data['durasiSelesai'];
        if (mulaiTS != null && selesaiTS != null) {
          final mulai = mulaiTS.toDate();
          final selesai = selesaiTS.toDate();

          // Inclusive range!
          if (now.compareTo(mulai) >= 0 && now.compareTo(selesai) <= 0) {
            banners.add({
              'id': doc.id,
              'judul': data['judul'] ?? '',
              'deskripsi': data['deskripsi'] ?? '',
              'imageUrl': data['bannerUrl'] ?? '',
              'logoUrl': data['logoUrl'] ?? '', // optional
              'storeName': data['storeName'] ?? '',
              'buttonText': 'Kunjungi Toko',
              'productId': data['productId'] ?? '',
              'isAsset': false,
            });
          }
        }
      }

      // Fallback jika tidak ada banner aktif
      if (banners.isEmpty) {
        banners = [
          {
            'imageUrl': 'assets/images/banner1.jpg',
            'isAsset': true,
          },
          {
            'imageUrl': 'assets/images/banner2.jpg',
            'isAsset': true,
          },
        ];
      }

      setState(() {
        allBanners = banners;
      });
    } catch (e, st) {
      print('Firestore error: $e\n$st');
      setState(() {
        allBanners = [
          {
            'imageUrl': 'assets/images/banner1.jpg',
            'isAsset': true,
          },
          {
            'imageUrl': 'assets/images/banner2.jpg',
            'isAsset': true,
          },
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
    cardWidth = cardWidth.clamp(0, 390);

    return SizedBox(
      height: 160,
      width: cardWidth,
      child: allBanners.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: allBanners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final data = allBanners[index];
                    final bannerImage = ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: data['isAsset'] == true
                          ? Image.asset(
                              data['imageUrl'] ?? '',
                              width: cardWidth,
                              height: 160,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              data['imageUrl'] ?? '',
                              width: cardWidth,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                          child: CircularProgressIndicator(strokeWidth: 1.5),
                                        ),
                            ),
                    );

                    if (data['isAsset'] == true || widget.onBannerTap == null) {
                      return bannerImage;
                    }
                    return GestureDetector(
                      onTap: () => widget.onBannerTap!(data),
                      child: bannerImage,
                    );
                  },
                ),
                // Indicator
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
                          color: _currentIndex == i
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
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
}
