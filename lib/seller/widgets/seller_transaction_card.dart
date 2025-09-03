import 'package:flutter/material.dart';
import 'package:abc_e_mart/seller/data/models/seller_transaction_card_data.dart';

class SellerTransactionCard extends StatelessWidget {
  final SellerTransactionCardData data;

  /// Optional: kalau diisi, pakai ini. Kalau null, fallback ke `data.onDetail`.
  final VoidCallback? onDetail;

  const SellerTransactionCard({
    Key? key,
    required this.data,
    this.onDetail,
  }) : super(key: key);

  Color get statusColor {
    switch (data.status) {
      case 'Sukses':
        return const Color(0xFF29B057);
      case 'Tertahan':
        return const Color(0xFFFFB800);
      case 'Gagal':
        return const Color(0xFFFF6161);
      default:
        return const Color(0xFFD1D5DB);
    }
  }

  VoidCallback? get _resolvedOnDetail => onDetail ?? data.onDetail;

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
          // ===== Header: Invoice + Status (dengan gap rapi) =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10), // ruang aman sebelum chip
                  child: Text(
                    'Invoice ID : ${data.invoiceId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF373E3C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 8), // gap eksplisit antara invoice & chip
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

          // dua item pertama + "Lainnya ..."
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
                onTap: _resolvedOnDetail, // fallback aman
                child: const Row(
                  children: [
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
    final widgets = <Widget>[];
    final displayCount = items.length > 2 ? 2 : items.length;

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
      (m) => '${m[1]}.',
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
        status,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}
