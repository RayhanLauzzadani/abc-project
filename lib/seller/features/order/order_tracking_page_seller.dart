import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderTrackingPageSeller extends StatefulWidget {
  @override
  _OrderTrackingPageSellerState createState() =>
      _OrderTrackingPageSellerState();
}

class _OrderTrackingPageSellerState extends State<OrderTrackingPageSeller> {
  bool _isAddressExpanded = false;
  final String fullAddress =
      'Home, Kemayoran, Cendana Street 1, Adinata Housing, Blok B, No. 10, Jakarta, Indonesia, 12345';
  String countdownText = "Selesai Otomatis: 16 Jul, 23:59";
  String buyerUsername = "nabyyll12312"; // Placeholder for buyer's username

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(left: 20, top: 40, bottom: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1C55C0),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Lacak Pesanan',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 33),
            // Status Pesanan Seller
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Pesanan',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C),
                  ),
                ),
                Text(
                  countdownText,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF28A745),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Produk Disiapkan Toko',
              'assets/icons/store.svg',
              Colors.red,
              25,
              25,
              0xFFDC3545,
              'Nippon Mart',
            ),
            const SizedBox(height: 10),
            _buildMoreIcon(),
            const SizedBox(height: 10),
            _buildStatusItem(
              'Produk Sedang Diantar',
              'assets/icons/deliver.svg',
              Colors.blue,
              26,
              26,
              0xFF1C55C0,
              'Nippon Mart',
            ),
            const SizedBox(height: 28),
            _buildHorizontalLine(),
            const SizedBox(height: 28),
            // Detail Pesanan Seller
            Text(
              'Detail Pesanan',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 28),
            // Username Pembeli and Chat Icon in 1 row (1 Column + 1 Icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Username Pembeli and Buyer username in column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username Pembeli',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    Text(
                      buyerUsername,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ),
                // Chat Icon aligned to the right
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1C55C0),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/chat.svg',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildHorizontalLine(),
            const SizedBox(height: 28),
            _buildAddressSection(),
            const SizedBox(height: 28),
            _buildHorizontalLine(),
            const SizedBox(height: 28),
            _buildProdukDipesanText(),
            const SizedBox(height: 28),
            _buildProductItem(
              'Ayam Geprek',
              'Pedas',
              'Rp 15.000',
              'x1',
              'assets/images/nihonmart.png',
            ),
            const SizedBox(height: 28),
            _buildProductItem(
              'Beng - Beng',
              'Pedas',
              'Rp 7.500',
              'x1',
              'assets/images/nihonmart.png',
            ),
            const SizedBox(height: 28),
            _buildHorizontalLine(),
            const SizedBox(height: 28),
            _buildNotaPesananCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    String text,
    String asset,
    Color iconColor,
    double iconWidth,
    double iconHeight,
    int svgColor,
    String subtitle,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              asset,
              width: iconWidth,
              height: iconHeight,
              color: Color(svgColor),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/more.svg',
          width: 25,
          height: 25,
          color: const Color(0xFFBABABA),
        ),
      ],
    );
  }

  Widget _buildHorizontalLine() {
    return Container(
      color: Color(0xFFF2F2F3),
      height: 1,
      width: double.infinity,
    );
  }

  Widget _buildNotaPesananCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nota Pesanan',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF373E3C),
                    ),
                  ),
                  Text(
                    'Lihat >',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Metode Pembayaran',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  Image.asset(
                    'assets/images/qris.png',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Pengiriman',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF373E3C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isAddressExpanded
              ? fullAddress
              : 'Home, Kemayoran, Cendana Street 1, Adinata Housing ...',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF9A9A9A),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              _isAddressExpanded = !_isAddressExpanded;
            });
          },
          child: Text(
            _isAddressExpanded ? 'Lihat Lebih Sedikit' : 'Lihat Selengkapnya',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF1C55C0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProdukDipesanText() {
    return Text(
      'Produk yang Dipesan',
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF373E3C),
      ),
    );
  }

  Widget _buildProductItem(
    String name,
    String description,
    String price,
    String quantity,
    String imagePath,
  ) {
    return Row(
      children: [
        Image.asset(imagePath, width: 95, height: 80),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          quantity,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF9A9A9A),
          ),
        ),
      ],
    );
  }
}
