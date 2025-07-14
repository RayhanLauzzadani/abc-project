import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final List<String> role;
  final String storeName;
  final String? storeId; // <--- tambah ini
  final DateTime createdAt;
  final List<Map<String, dynamic>> addressList;
  final Map<String, List<String>>? favorites;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.storeName,
    required this.createdAt,
    required this.addressList,
    this.storeId,
    this.favorites,
    this.photoUrl,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    List<String> roleList = [];
    if (map['role'] is String) {
      roleList = [map['role']];
    } else if (map['role'] is List) {
      roleList = List<String>.from(map['role'] ?? []);
    }
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: roleList,
      storeName: map['storeName'] ?? '',
      storeId: map['storeId'], // <---
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      addressList: List<Map<String, dynamic>>.from(map['addressList'] ?? []),
      favorites: map['favorites'] != null
          ? Map<String, List<String>>.from(
              (map['favorites'] as Map<String, dynamic>).map(
                  (key, value) =>
                      MapEntry(key, List<String>.from(value ?? []))))
          : null,
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'storeName': storeName,
      'storeId': storeId, // <---
      'createdAt': createdAt,
      'addressList': addressList,
      if (favorites != null) 'favorites': favorites,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}
