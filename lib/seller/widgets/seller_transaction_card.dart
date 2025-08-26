import 'package:flutter/material.dart';
import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';

class SellerTransactionCard extends StatelessWidget {
  final SellerTransactionCardData data;
  final VoidCallback onDetail; // Add onDetail parameter

  const SellerTransactionCard({Key? key, required this.data, required this.onDetail}) : super(key: key);

  Color get statusColor {
    switch (data.status) {
      case 'Sukses':
        return const Color(0xFF29B057);
      case 'Tertahan':
        return const Color(0xFFFFB800); // kuning pekat
      case 'Gagal':
        return const Color(0xFFFF6161);
      default:
        return const Color(0xFFD1D5DB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Invoice ID : ${data.invoiceId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF373E3C),
                  ),
                ),
              ),
              _StatusBubble(status: data.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            data.date,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Color(0xFF373E3C),
            ),
          ),
          const SizedBox(height: 11),
          ..._buildItemList(data.items),
          const Divider(color: Color(0xFFE5E7EB), height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rp ${_formatCurrency(data.total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF373E3C),
                  ),
                ),
              ),
              InkWell(
                onTap: onDetail, // Use onDetail here
                child: Row(
                  children: const [
                    Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1C55C0),
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1C55C0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemList(List<TransactionCardItem> items) {
    List<Widget> widgets = [];
    int displayCount = items.length > 2 ? 2 : items.length;
    for (int i = 0; i < displayCount; i++) {
      final item = items[i];
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFF373E3C),
                      ),
                    ),
                    if (item.note.isNotEmpty)
                      Text(
                        item.note,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 10,
                          color: Color(0xFF777777),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${item.qty}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF373E3C),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (items.length > 2) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.5),
          child: Text(
            'Lainnya ....',
            style: TextStyle(fontSize: 10, color: Color(0xFF9A9A9A)),
          ),
        ),
      );
    }
    return widgets;
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _StatusBubble extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBubble({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status, // Removing the dot from status
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}
