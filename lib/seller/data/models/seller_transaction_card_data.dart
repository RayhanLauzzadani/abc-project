import 'package:flutter/material.dart';

class SellerTransactionCardData {
  final String invoiceId;
  final String date;
  final String status;
  final List<TransactionCardItem> items;
  final int total;
  final VoidCallback onDetail;

  SellerTransactionCardData({
    required this.invoiceId,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    required this.onDetail,
  });
}

class TransactionCardItem {
  final String name;
  final String note;
  final int qty;

  TransactionCardItem({
    required this.name,
    required this.note,
    required this.qty,
  });
}
