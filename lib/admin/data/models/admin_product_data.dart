import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/data/models/category_type.dart';

class AdminProductData {
  final String docId; // ID dokumen di productsApplication
  final String imagePath; // imageUrl produk
  final String productName;
  final CategoryType categoryType;
  final String storeName;
  final String date; // Sudah diformat
  final String status; // pending/approved/rejected
  final String description;
  final int price;
  final int stock;
  final String shopId;
  final String ownerId;

  // Untuk raw access kalau butuh
  final Map<String, dynamic> rawData;

  const AdminProductData({
    required this.docId,
    required this.imagePath,
    required this.productName,
    required this.categoryType,
    required this.storeName,
    required this.date,
    required this.status,
    required this.description,
    required this.price,
    required this.stock,
    required this.shopId,
    required this.ownerId,
    required this.rawData,
  });

  // Factory dari DocumentSnapshot Firestore
  factory AdminProductData.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Format tanggal dari createdAt
    String formattedDate = "-";
    if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      final dt = (data['createdAt'] as Timestamp).toDate();
      formattedDate =
          "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return AdminProductData(
      docId: doc.id,
      imagePath: data['imageUrl'] ?? '',
      productName: data['name'] ?? '-',
      categoryType: _parseCategory(data['category']),
      storeName: data['storeName'] ?? '-',
      date: formattedDate,
      status: data['status'] ?? 'pending',
      description: data['description'] ?? '-',
      price: (data['price'] is int)
          ? data['price']
          : (int.tryParse(data['price']?.toString() ?? '0') ?? 0),
      stock: (data['stock'] is int)
          ? data['stock']
          : (int.tryParse(data['stock']?.toString() ?? '0') ?? 0),
      shopId: data['shopId'] ?? '', // jika belum ada di productsApplication, isi ''
      ownerId: data['ownerId'] ?? '',
      rawData: data,
    );
  }

  static CategoryType _parseCategory(String? val) {
    // Mapping nama kategori ke enum CategoryType, sesuaikan dengan project kamu
    switch ((val ?? '').toLowerCase()) {
      case 'makanan': return CategoryType.makanan;
      case 'minuman': return CategoryType.minuman;
      case 'snacks': return CategoryType.snacks;
      case 'alat tulis': return CategoryType.alatTulis;
      case 'alat lab': return CategoryType.alatLab;
      case 'merchandise': return CategoryType.merchandise;
      case 'produk daur ulang': return CategoryType.produkDaurUlang;
      case 'produk kesehatan': return CategoryType.produkKesehatan;
      default: return CategoryType.lainnya;
    }
  }
}
