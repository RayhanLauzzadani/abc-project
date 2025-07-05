import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final String storeName;
  final DateTime createdAt;
  final List<Map<String, dynamic>> addressList;
  final Map<String, List<String>>? favorites;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.storeName,
    required this.createdAt,
    required this.addressList,
    this.favorites,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'buyer',
      storeName: map['storeName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      addressList: List<Map<String, dynamic>>.from(map['addressList'] ?? []),
      favorites: map['favorites'] != null
          ? Map<String, List<String>>.from(
              (map['favorites'] as Map<String, dynamic>).map((key, value) =>
                  MapEntry(key, List<String>.from(value ?? []))))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'storeName': storeName,
      'createdAt': createdAt,
      'addressList': addressList,
      if (favorites != null) 'favorites': favorites,
    };
  }
}
