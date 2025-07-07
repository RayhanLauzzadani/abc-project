import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProduct {
  final String id; // Firestore documentId (productId atau autoId)
  final DateTime createdAt;
  final String name;
  final String image;
  final int price;
  final double rating;
  final String? storeId; // opsional

  FavoriteProduct({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    this.storeId,
  });

  factory FavoriteProduct.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FavoriteProduct(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: data['price'] ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      storeId: data['storeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'name': name,
      'image': image,
      'price': price,
      'rating': rating,
      'storeId': storeId,
    };
  }
}
