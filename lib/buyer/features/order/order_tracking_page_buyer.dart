import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:abc_e_mart/buyer/features/payment/note_pesanan_detail_page_buyer.dart';

class OrderTrackingPage extends StatefulWidget {
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // Boolean to manage whether the address is expanded or not
  bool _isAddressExpanded = false;

  // Address text (long version)
  final String fullAddress =
      'Home, Kemayoran, Cendana Street 1, Adinata Housing, Blok B, No. 10, Jakarta, Indonesia, 12345';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white, // Ensure background is white
          elevation: 0, // No shadow on AppBar background
          automaticallyImplyLeading: false,
          primary: false, // Disable any background color change on scroll
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 40,
              bottom: 10,
            ), // Padding for header (40px top, 10px bottom)
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
                          color: Color(0xFF1C55C0), // Blue background
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
        // Scrollable body
        padding: const EdgeInsets.symmetric(horizontal: 20), // Padding for body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 33),
            // Status Pesanan
            Text(
              'Status Pesanan',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Produk disiapkan Toko',
              'assets/icons/store.svg',
              Colors.red,
              25,
              25,
              0xFFDC3545,
              'Nippon Mart',
            ),
            const SizedBox(height: 10),
            _buildMoreIcon(), // Icon more.svg under store
            const SizedBox(height: 10),
            _buildStatusItem(
              'Produk Sedang Dikirim',
              'assets/icons/deliver.svg',
              Colors.blue,
              26,
              26,
              0xFF1C55C0,
              'Nippon Mart',
            ),
            const SizedBox(height: 10),
            _buildMoreIcon(), // Icon more.svg under deliver
            const SizedBox(height: 10),
            _buildStatusItem(
              'Produk Sampai Tujuan',
              'assets/icons/circle_check.svg',
              Colors.green,
              26,
              26,
              0xFF28A745,
              'Nippon Mart',
            ),
            const SizedBox(height: 28), // Gap after last status
            _buildHorizontalLine(), // Horizontal line after circle_check
            const SizedBox(height: 28), // Gap before Detail Pesanan
            // Detail Pesanan
            Text(
              'Detail Pesanan',
              style: GoogleFonts.dmSans(
                fontSize: 22, // Same as Status Pesanan
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 28), // Gap before image
            _buildStoreImageWithInfo(), // Image and Store Info Section
            const SizedBox(height: 32),
            _buildHorizontalLine(), // Horizontal line after Produk Sudah Sampai
            const SizedBox(height: 28), // Gap before Alamat Pengiriman
            _buildAddressSection(), // Alamat Pengiriman
            const SizedBox(height: 28), // Gap before Produk yang Dipesan
            _buildHorizontalLine(), // Horizontal line after Alamat Pengiriman
            const SizedBox(height: 28), // Gap before Produk yang Dipesan text
            _buildProdukDipesanText(), // Text "Produk yang Dipesan"
            const SizedBox(height: 28), // Gap before product list
            _buildProductItem(
              'Ayam Geprek',
              'Pedas',
              'Rp 15.000',
              'x1',
              'assets/images/nihonmart.png',
            ),
            const SizedBox(height: 28), // Gap between product items
            _buildProductItem(
              'Beng - Beng',
              'Pedas',
              'Rp 7.500',
              'x1',
              'assets/images/nihonmart.png',
            ),
            const SizedBox(height: 28), // Gap after last product
            _buildHorizontalLine(), // Horizontal line after product list
            const SizedBox(height: 28), // Gap before Nota Pesanan card
            _buildNotaPesananCard(), // Nota Pesanan Card
          ],
        ),
      ),
    );
  }

  // Method to add "Nota Pesanan" card
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
              const SizedBox(height: 5),
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
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke halaman detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotaPesananDetailPageBuyer(), // Ganti dengan halaman baru
                        ),
                      );
                    },
                    child: Text(
                      'Lihat >',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF777777),
                      ),
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
                  Image.asset('assets/images/qris.png', width: 40, height: 40),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
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
          mainAxisAlignment: MainAxisAlignment.start, // Align items to the left
          children: [
            SvgPicture.asset(
              asset,
              width: iconWidth,
              height: iconHeight,
              color: Color(svgColor), // SVG icon color
            ),
            const SizedBox(width: 14), // Gap between icon and text
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
      mainAxisAlignment:
          MainAxisAlignment.start, // Align "more" icon to the left
      children: [
        SvgPicture.asset(
          'assets/icons/more.svg', // more.svg icon
          width: 25,
          height: 25,
          color: const Color(0xFFBABABA),
        ),
      ],
    );
  }

  Widget _buildHorizontalLine() {
    return Container(
      color: Color(0xFFF2F2F3), // Line color
      height: 1, // Stroke width of the line
      width: double.infinity,
    );
  }

  Widget _buildStoreImageWithInfo() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align Nama Toko to the left
      children: [
        Text(
          'Nama Toko',
          style: GoogleFonts.dmSans(
            fontSize: 16, // Same as other labels
            fontWeight: FontWeight.bold,
            color: const Color(0xFF373E3C),
          ),
        ),
        const SizedBox(height: 20), // Gap between text and image
        Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the left
          children: [
            Image.asset('assets/images/nihonmart.png', width: 89, height: 76),
            const SizedBox(width: 16), // Space between image and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nippon Mart',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C),
                  ),
                ),
                const SizedBox(height: 4), // Small gap between name and code
                Text(
                  '#2019482', // Kode Toko (ID toko)
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
            const Spacer(),
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
