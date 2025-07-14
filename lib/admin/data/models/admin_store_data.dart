// lib/admin/models/admin_store_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Data class untuk informasi ajuan toko (store submission & approval)
class AdminStoreApprovalData {
  final String docId; // Firestore document ID
  final String imagePath; // logoUrl
  final String storeName;
  final String storeAddress;
  final String submitter;
  final String date; // sudah diformat (bukan Timestamp)
  final String status; // ex: "pending", "approved", "rejected"

  const AdminStoreApprovalData({
    required this.docId,
    required this.imagePath,
    required this.storeName,
    required this.storeAddress,
    required this.submitter,
    required this.date,
    required this.status,
  });

  /// Helper: bikin dari Firestore document
  factory AdminStoreApprovalData.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Format date (opsional: bisa custom sesuai kebutuhan)
    String formattedDate = "-";
    if (data['submittedAt'] != null && data['submittedAt'] is Timestamp) {
      final dt = (data['submittedAt'] as Timestamp).toDate();
      formattedDate =
          "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return AdminStoreApprovalData(
      docId: doc.id,
      imagePath: data['logoUrl'] ?? '',
      storeName: data['shopName'] ?? '-',
      storeAddress: data['address'] ?? '-',
      submitter: data['owner']?['nama'] ?? '-',
      date: formattedDate,
      status: data['status'] ?? 'pending',
    );
  }
}
