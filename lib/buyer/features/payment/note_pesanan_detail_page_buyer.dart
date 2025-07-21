import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotaPesananDetailPageBuyer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(left: 20, top: 40, bottom: 10),
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
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
                'Detail Transaksi',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF373E3C),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice ID and Status (one row)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Invoice ID Text
                Text(
                  'Invoice ID : NPNOO1',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C),
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  width: 110, // Width set to 110
                  height: 21, // Height set to 21
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A745).withOpacity(0.1), // Light background for status
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFF28A745), width: 1), // Border color: #28A745
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 4, color: const Color(0xFF28A745)), // Green dot
                      const SizedBox(width: 6),
                      Text(
                        "Selesai",
                        style: GoogleFonts.dmSans(
                          fontSize: 10, // Font size updated for better fit
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF28A745), // Font color: #28A745
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 23),

            // Total Pembayaran and Tanggal Transaksi
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp 24.750',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20), // Adjustable gap
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Transaksi',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '05/07/25',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Horizontal Line
            _buildHorizontalLine(),
            const SizedBox(height: 24),

            // Rincian Pengiriman and Metode Pembayaran (Row with gap)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment of the text to top
              children: [
                // Rincian Pengiriman
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian Pengiriman',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ahmad Nabil\nCendana Street 1, Adinata Housing Kemayoran, Jakarta, Indonesia\n62895621049433',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20), // Gap between Rincian Pengiriman and Metode Pembayaran
                // Metode Pembayaran
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align top
                    children: [
                      Text(
                        'Metode Pembayaran',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF373E3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Image.asset(
                        'assets/images/qris.png', // QRIS image
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Horizontal Line again
            _buildHorizontalLine(),
            const SizedBox(height: 24),

            // Rincian Pesanan
            Text(
              'Rincian Pesanan',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductDetail('Ayam Geprek Pedas', 'Rp15.000', 'x1'),
                const SizedBox(height: 7),
                _buildProductDetail('Beng - Beng', 'Rp7.500', 'x1'),
              ],
            ),
            const SizedBox(height: 16),
            _buildHorizontalLine(),
            const SizedBox(height: 16),

            // Ringkasan Pembayaran
            Text(
              'Ringkasan Pembayaran',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 8), // Gap before Subtotal
            _buildPaymentSummary('Subtotal', 'Rp22.500'),
            const SizedBox(height: 7), // Gap between Subtotal and other summaries
            _buildPaymentSummary('Biaya Pengiriman', 'Rp1.500'),
            const SizedBox(height: 7), // Gap between Biaya Pengiriman and Pajak
            _buildPaymentSummary('Pajak & Biaya Lainnya', 'Rp650'),
            const SizedBox(height: 7), // Gap between Pajak & Biaya Lainnya and Total Pembayaran
            _buildPaymentSummary('Total Pembayaran', 'Rp24.750'),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLine() {
    return Container(
      color: Color(0xFFF2F2F3),
      height: 1,
      width: double.infinity,
    );
  }

  Widget _buildProductDetail(String name, String price, String quantity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Product Name and Quantity
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF373E3C),
            ),
          ),
        ),
        // Quantity and Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$quantity',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF373E3C),
              ),
            ),
            Text(
              price,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF373E3C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF9A9A9A),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF373E3C),
          ),
        ),
      ],
    );
  }
}
