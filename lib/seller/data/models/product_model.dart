import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String ownerId;
  final String name;
  final String imageUrl;
  final int price;
  final String category;
  final String description;
  final int stock;
  final int sold;
  final Timestamp createdAt;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.ownerId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.description,
    required this.stock,
    required this.sold,
    required this.createdAt,
  });

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: data['price'] ?? 0,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      stock: data['stock'] ?? 0,
      sold: data['sold'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
