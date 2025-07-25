import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final String image;
  final int price;
  final int quantity;
  final String? variant;
  final DateTime? addedAt;
  final String? storeId; // field toko
  final String? ownerId; // field owner toko

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.variant,
    this.addedAt,
    this.storeId, // new
    this.ownerId, // new
  });

  factory CartItem.fromMap(Map<String, dynamic> data) => CartItem(
        id: data['id'] ?? '',
        name: data['name'] ?? '',
        image: data['image'] ?? '',
        price: data['price'] ?? 0,
        quantity: data['quantity'] ?? 1,
        variant: data['variant'],
        addedAt: data['addedAt'] != null
            ? (data['addedAt'] as Timestamp).toDate()
            : null,
        storeId: data['storeId'],   // ambil dari map (bisa null)
        ownerId: data['ownerId'],   // ambil dari map (bisa null)
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'image': image,
        'price': price,
        'quantity': quantity,
        'variant': variant,
        'addedAt': addedAt != null ? Timestamp.fromDate(addedAt!) : null,
        'storeId': storeId,
        'ownerId': ownerId,
      };

  CartItem copyWith({
    String? id,
    String? name,
    String? image,
    int? price,
    int? quantity,
    String? variant,
    DateTime? addedAt,
    String? storeId,
    String? ownerId,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      addedAt: addedAt ?? this.addedAt,
      storeId: storeId ?? this.storeId,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
