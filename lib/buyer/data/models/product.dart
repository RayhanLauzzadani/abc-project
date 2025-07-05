import 'package:cloud_firestore/cloud_firestore.dart';


class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String storeId;
  final String categoryId;
  final bool isAvailable;
  final String description;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.storeId,
    required this.categoryId,
    required this.isAvailable,
    required this.description,
    required this.createdAt,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      storeId: map['storeId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'description': description,
      'createdAt': createdAt,
    };
  }
}
