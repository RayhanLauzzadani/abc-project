import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteStore {
  final String id; // Firestore documentId (storeId atau autoId)
  final DateTime createdAt;
  final String name;
  final String image;
  final String distance;
  final String duration;
  final double rating;

  FavoriteStore({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.image,
    required this.distance,
    required this.duration,
    required this.rating,
  });

  factory FavoriteStore.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FavoriteStore(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      distance: data['distance'] ?? '',
      duration: data['duration'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'name': name,
      'image': image,
      'distance': distance,
      'duration': duration,
      'rating': rating,
    };
  }
}
