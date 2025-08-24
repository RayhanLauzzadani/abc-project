import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodPage extends StatefulWidget {
  final String? initialMethod;
  const PaymentMethodPage({this.initialMethod, Key? key}) : super(key: key);

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? selectedMethod;

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, selectedMethod),
                    child: Container(
                      width: 37, height: 37,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C55C0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Metode Pembayaran',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF373E3C))),
                ],
              ),
            ),

            // PILIHAN (hanya ABC Payment)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AbcPaymentOption(
                    selected: selectedMethod == 'ABC Payment',
                    onTap: () {
                      setState(() {
                        selectedMethod = selectedMethod == 'ABC Payment' ? null : 'ABC Payment';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // FOOTER
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, -2))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C55C0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
            onPressed: selectedMethod == null ? null : () => Navigator.pop(context, selectedMethod),
            child: Text('Simpan',
                style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFFAFAFA))),
          ),
        ),
      ),
    );
  }
}

class AbcPaymentOption extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;

  const AbcPaymentOption({Key? key, this.selected = false, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Text('ABC Payment',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF373E3C))),
          ),
          // Garis putus-putus
          // BENAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: SizedBox(
              height: 1,
              width: double.infinity,
              child: CustomPaint(
                painter: DashedLinePainter(),
              ),
            ),
          ),
          // Pilihan ABC Payment
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Image.asset('assets/images/paymentlogo.png', height: 24),
                  const SizedBox(width: 10),
                  Text('ABC Payment',
                      style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF373E3C))),
                  const Spacer(),
                  CustomRadioSmall(selected: selected),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======= util UI dari kode lama (tetap dipakai) =======
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6, dashSpace = 4, startX = 0;
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomRadioSmall extends StatelessWidget {
  final bool selected;
  const CustomRadioSmall({Key? key, required this.selected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2563EB), width: 2.2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
