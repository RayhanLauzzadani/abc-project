import 'package:flutter/material.dart';

class SellerTransactionCardData {
  final String invoiceId;
  final String date;                 // string untuk tampilan kartu
  final String status;
  final List<TransactionCardItem> items;
  final int total;

  /// Optional (biar TransactionDetailPage dapat nama & alamat)
  final String? buyerName;
  final String? buyerPhone;
  final Map<String, dynamic>? shipping; // { recipient, addressText, phone }
  final Map<String, dynamic>? amounts;  // { subtotal, shipping, tax, total }
  final String? paymentMethod;          // e.g. 'ABC_PAYMENT'
  final DateTime? dateTime;             // tanggal as DateTime untuk halaman detail
  final Map<String, dynamic>? store;    // { name, phone, address }

  /// Callback lama (boleh tetap diisi atau diabaikan—kartu support keduanya)
  final VoidCallback onDetail;

  SellerTransactionCardData({
    required this.invoiceId,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    required this.onDetail,
    this.buyerName,
    this.buyerPhone,
    this.shipping,
    this.amounts,
    this.paymentMethod,
    this.dateTime,
    this.store,
  });
}

class TransactionCardItem {
  final String name;
  final String note;
  final int qty;

  /// Optional: kalau kamu punya harga per item, isi di sini
  final int? price;

  TransactionCardItem({
    required this.name,
    required this.note,
    required this.qty,
    this.price,
  });
}
