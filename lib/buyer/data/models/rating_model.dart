import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String orderId;
  final String storeId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final int rating;
  final String review;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.orderId,
    required this.storeId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map, String id) {
    return RatingModel(
      id: id,
      orderId: map['orderId'] ?? '',
      storeId: map['storeId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      rating: map['rating'] ?? 0,
      review: map['review'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'storeId': storeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'review': review,
      'createdAt': createdAt,
    };
  }
}

