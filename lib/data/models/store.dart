class StoreModel {
  final String id;
  final String storeName;
  final String storeImageUrl;
  final double rating;
  final double distance;
  final int deliveryTime;
  final bool isPopular;
  final String ownerId;
  final String address;
  final bool isActive;

  StoreModel({
    required this.id,
    required this.storeName,
    required this.storeImageUrl,
    required this.rating,
    required this.distance,
    required this.deliveryTime,
    required this.isPopular,
    required this.ownerId,
    required this.address,
    required this.isActive,
  });

  factory StoreModel.fromMap(String id, Map<String, dynamic> map) {
    return StoreModel(
      id: id,
      storeName: map['storeName'] ?? '',
      storeImageUrl: map['storeImageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      distance: (map['distance'] ?? 0).toDouble(),
      deliveryTime: map['deliveryTime'] ?? 0,
      isPopular: map['isPopular'] ?? false,
      ownerId: map['ownerId'] ?? '',
      address: map['address'] ?? '',
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'storeImageUrl': storeImageUrl,
      'rating': rating,
      'distance': distance,
      'deliveryTime': deliveryTime,
      'isPopular': isPopular,
      'ownerId': ownerId,
      'address': address,
      'isActive': isActive,
    };
  }
}
