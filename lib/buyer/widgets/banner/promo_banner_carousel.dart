import 'dart:async';
import 'package:flutter/material.dart';
import 'promo_banner_card.dart';
import 'custom_banner_indicator.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  final List<Map<String, String>> promoBanners = [
    {
      'title': 'Beli Ayam Geprek',
      'subtitle': 'Sub Judul',
      'imagePath': 'assets/images/geprek.png',
      'buttonText': 'Click Me',
      // Tambahkan parameter lain jika perlu
    },
    {
      'title': 'Diskon Spesial',
      'subtitle': 'Berlaku hari ini',
      'imagePath': 'assets/images/geprek.png',
      'buttonText': 'Cek Promo',
    },
    {
      'title': 'Menu Baru!',
      'subtitle': 'Cobain yuk!',
      'imagePath': 'assets/images/geprek.png',
      'buttonText': 'Pesan',
    },
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
  //     if (promoBanners.isEmpty) return;
  //     int nextPage = (_currentIndex + 1) % promoBanners.length;
  //     _controller.animateToPage(
  //       nextPage,
  //       duration: const Duration(milliseconds: 800),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 40; // padding 20 kiri kanan
    cardWidth = cardWidth.clamp(0, 390);

    return Column(
      children: [
        SizedBox(
          height: 160,
          width: cardWidth,
          child: PageView.builder(
            controller: _controller,
            itemCount: promoBanners.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final data = promoBanners[index];
              return PromoBannerCard(
                title: data['title'] ?? '',
                subtitle: data['subtitle'] ?? '',
                imagePath: data['imagePath'] ?? '',
                buttonText: data['buttonText'] ?? '',
                logoPath: data['logoPath'] ?? 'assets/images/logo.png',
                onPressed: () {
                  // TODO: aksi jika button ditekan
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        CustomBannerIndicator(
          count: promoBanners.length,
          activeIndex: _currentIndex,
        ),
      ],
    );
  }
}
