import 'package:flutter/material.dart';
import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';
import 'seller_transaction_card.dart';

class SellerTransactionSection extends StatelessWidget {
  final List<SellerTransactionCardData> transactions;
  final VoidCallback onSeeAll;

  const SellerTransactionSection({
    Key? key,
    required this.transactions,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 23),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaksi Baru',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF373E3C),
                  ),
                ),
              ),
              InkWell(
                onTap: onSeeAll,
                child: Row(
                  children: const [
                    Text(
                      'Lainnya',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF777777),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF777777)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Lihat transaksi baru saja terjadi di tokomu di sini!',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF373E3C),
            ),
          ),
          const SizedBox(height: 14),
          ...transactions
              .asMap()
              .entries
              .map((entry) {
                final isLast = entry.key == transactions.length - 1;
                return Column(
                  children: [
                    SellerTransactionCard(data: entry.value),
                    if (!isLast) const SizedBox(height: 15),
                  ],
                );
              })
              .toList(),
        ],
      ),
    );
  }
}
