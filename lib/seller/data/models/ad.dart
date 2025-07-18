// seller/data/models/ad.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AdApplication {
  final String id;
  final String storeId;
  final String storeName;
  final String sellerId;
  final String bannerUrl;
  final String judul;
  final String deskripsi;
  final String productId;
  final String productName;
  final DateTime durasiMulai;
  final DateTime durasiSelesai;
  final String paymentProofUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdApplication({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.sellerId,
    required this.bannerUrl,
    required this.judul,
    required this.deskripsi,
    required this.productId,
    required this.productName,
    required this.durasiMulai,
    required this.durasiSelesai,
    required this.paymentProofUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// --- Factory from Firestore with robust error handling & debug ---
  factory AdApplication.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      // DEBUG: print all fields, so you can trace any missing data
      print('[DEBUG ad.dart] fromFirestore, docId: ${doc.id}');
      print('[DEBUG ad.dart] data: $data');

      return AdApplication(
        id: doc.id,
        storeId: data['storeId'] ?? '',
        storeName: data['storeName'] ?? '',
        sellerId: data['sellerId'] ?? '',
        bannerUrl: data['bannerUrl'] ?? '',
        judul: data['judul'] ?? '',
        deskripsi: data['deskripsi'] ?? '',
        productId: data['productId'] ?? '',
        productName: data['productName'] ?? '',
        durasiMulai: _timestampToDate(data['durasiMulai']),
        durasiSelesai: _timestampToDate(data['durasiSelesai']),
        paymentProofUrl: data['paymentProofUrl'] ?? '',
        status: data['status'] ?? 'Menunggu',
        createdAt: _timestampToDate(data['createdAt']),
        updatedAt: _timestampToDate(data['updatedAt']),
      );
    } catch (e, st) {
      print('!!! ERROR PARSING AdApplication: $e\n$st');
      // Fallback minimal data (supaya ga error ListView)
      return AdApplication(
        id: doc.id,
        storeId: '',
        storeName: '',
        sellerId: '',
        bannerUrl: '',
        judul: '[Parsing Error]',
        deskripsi: '',
        productId: '',
        productName: '',
        durasiMulai: DateTime.now(),
        durasiSelesai: DateTime.now(),
        paymentProofUrl: '',
        status: 'Menunggu',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  static DateTime _timestampToDate(dynamic ts) {
    if (ts == null) return DateTime.now();
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    // Bisa jadi string (iso8601) di Firestore, misal hasil migration manual
    return DateTime.tryParse(ts.toString()) ?? DateTime.now();
  }

  // --- To JSON (for Firestore) ---
  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'storeName': storeName,
        'sellerId': sellerId,
        'bannerUrl': bannerUrl,
        'judul': judul,
        'deskripsi': deskripsi,
        'productId': productId,
        'productName': productName,
        'durasiMulai': Timestamp.fromDate(durasiMulai),
        'durasiSelesai': Timestamp.fromDate(durasiSelesai),
        'paymentProofUrl': paymentProofUrl,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  // --- Copy With (optional, useful for update) ---
  AdApplication copyWith({
    String? id,
    String? storeId,
    String? storeName,
    String? sellerId,
    String? bannerUrl,
    String? judul,
    String? deskripsi,
    String? productId,
    String? productName,
    DateTime? durasiMulai,
    DateTime? durasiSelesai,
    String? paymentProofUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdApplication(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      sellerId: sellerId ?? this.sellerId,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      durasiMulai: durasiMulai ?? this.durasiMulai,
      durasiSelesai: durasiSelesai ?? this.durasiSelesai,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // --- Helper Getter (for UI) ---
  String get periodeLabel {
    final durasi = durasiSelesai.difference(durasiMulai).inDays + 1;
    return "$durasi Hari • "
        "${_tanggalLabel(durasiMulai)} - ${_tanggalLabel(durasiSelesai)}";
  }

  String get tanggalPengajuanLabel {
    return _tanggalJamLabel(createdAt);
  }

  String _tanggalLabel(DateTime d) {
    // Output: 21 Juli 2025
    return "${d.day} ${_bulanIndo(d.month)} ${d.year}";
  }

  String _tanggalJamLabel(DateTime d) {
    // Output: 30 April 2025, 16:21 WIB
    final m = d.minute.toString().padLeft(2, '0');
    return "${d.day} ${_bulanIndo(d.month)} ${d.year}, ${d.hour}:$m WIB";
  }

  String _bulanIndo(int month) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month < 1 || month > 12) return '';
    return bulan[month];
  }
}
