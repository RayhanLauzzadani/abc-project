import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String label; 
  final String name;  
  final String phone; 
  final String address; 
  final String locationTitle; 
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
    required this.locationTitle,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  // Factory fromMap (Firestore)
  factory AddressModel.fromMap(String id, Map<String, dynamic> map) {
    return AddressModel(
      id: id,
      label: map['label'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      locationTitle: map['locationTitle'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // toMap (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'name': name,
      'phone': phone,
      'address': address,
      'locationTitle': locationTitle,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }
}
