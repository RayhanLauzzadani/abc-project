// Tetap pakai import yang sama
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/search_bar.dart' as custom_widgets;
import 'package:abc_e_mart/buyer/widgets/store_product_card.dart';

class StoreDetailPage extends StatefulWidget {
  const StoreDetailPage({super.key});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  final TextEditingController _searchController = TextEditingController();

  static const colorPrimary = Color(0xFF1C55C0);
  static const colorInput = Color(0xFF404040);
  static const colorPlaceholder = Color(0xFF757575);

  final List<String> categories = [
    "Semua",
    "Makanan",
    "Minuman",
    "Snacks",
    "Lainnya",
  ];
  int selectedCategory = 0;

  final List<Map<String, String>> allProducts = [
    {
      "name": "Buku Tulis",
      "price": "Rp 12.000",
      "image": "assets/images/geprek.png",
      "category": "Lainnya",
    },
    {
      "name": "Pulpen Sarasa",
      "price": "Rp 18.000",
      "image": "assets/images/geprek.png",
      "category": "Lainnya",
    },
    {
      "name": "Es Doger",
      "price": "Rp 5.000",
      "image": "assets/images/geprek.png",
      "category": "Minuman",
    },
    {
      "name": "Club 500ml",
      "price": "Rp 3.500",
      "image": "assets/images/geprek.png",
      "category": "Minuman",
    },
    {
      "name": "Roti Aoka",
      "price": "Rp 5.000",
      "image": "assets/images/geprek.png",
      "category": "Makanan",
    },
    {
      "name": "Oreo Mini",
      "price": "Rp 2.000",
      "image": "assets/images/geprek.png",
      "category": "Snacks",
    },
  ];

  String searchQuery = '';

  List<Map<String, String>> get filteredProducts {
    final activeCategory = categories[selectedCategory];
    return allProducts.where((prod) {
      final matchCategory = (activeCategory == "Semua") || (prod["category"] == activeCategory);
      final matchQuery = prod["name"]!.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BACK + LOGO (diperbesar)
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 240,
                            height: 160, // <-- diperbesar
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 20,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: colorPrimary,
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
                  const SizedBox(height: 16), // Tambah jarak bawah logo

                  // --- Info Toko, Rating, Chat, Favorit
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nippon Mart",
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colorInput,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "4 km • 15 mins",
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.5,
                                  color: colorPlaceholder,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 17),
                                  const SizedBox(width: 2),
                                  Text(
                                    "4.8 ",
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  Text(
                                    "(435 Ratings)",
                                    style: GoogleFonts.dmSans(
                                      color: Colors.orange[700],
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _circleIcon(icon: Icons.chat_bubble_outline, onTap: () {}),
                            const SizedBox(width: 8),
                            _circleIcon(icon: Icons.favorite_border, onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: custom_widgets.SearchBar(
                      controller: _searchController,
                      onChanged: _handleSearch,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- Katalog Title
                  Padding(
                    padding: const EdgeInsets.only(left: 18, bottom: 1),
                    child: Text(
                      "Katalog",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorInput,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // --- Kategori Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: categories.length,
                        itemBuilder: (context, i) => Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 6,
                            right: i == categories.length - 1 ? 0 : 6,
                          ),
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: Text(
                              categories[i],
                              style: GoogleFonts.dmSans(
                                color: selectedCategory == i ? Colors.white : colorPlaceholder,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            selected: selectedCategory == i,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = i;
                              });
                            },
                            selectedColor: colorPrimary,
                            backgroundColor: const Color(0xFFF2F2F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // --- Grid Produk Responsif
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];
                    return StoreProductCard(
                      name: product["name"]!,
                      price: product["price"]!,
                      imagePath: product["image"]!,
                    );
                  },
                  childCount: filteredProducts.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: colorPrimary,
          size: 21,
        ),
      ),
    );
  }
}
