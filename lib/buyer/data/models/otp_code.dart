import 'package:cloud_firestore/cloud_firestore.dart';

class OtpCode {
  final String email;
  final String otp;
  final DateTime createdAt;
  final DateTime expiresAt;

  OtpCode({
    required this.email,
    required this.otp,
    required this.createdAt,
    required this.expiresAt,
  });

  factory OtpCode.fromMap(Map<String, dynamic> map) {
    return OtpCode(
      email: map['email'],
      otp: map['otp'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'otp': otp,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
    };
  }
}
