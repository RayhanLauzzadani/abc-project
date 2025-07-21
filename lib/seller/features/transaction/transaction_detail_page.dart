import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final invoiceId = transaction['invoiceId'] ?? 'No ID';
    final status = transaction['status'] ?? 'Unknown';
    final total = transaction['total'] ?? 0;
    final items = transaction['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice ID : $invoiceId',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF373E3C),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Status : $status',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF373E3C),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Items',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF373E3C),
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: items.map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] ?? 'No Name',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF373E3C),
                          ),
                        ),
                      ),
                      Text(
                        '${item['qty']} x ${item['note']}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text(
              'Total: Rp $total',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF373E3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
