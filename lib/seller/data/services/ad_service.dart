import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/ad.dart';

class AdService {
  static final _adsApplicationCol = FirebaseFirestore.instance.collection('adsApplication');

  /// Upload image/file ke Cloud Storage, return url-nya.
  static Future<String> uploadImageToStorage(File file, String folder) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  /// Submit pengajuan iklan (seller)
  static Future<void> submitAdApplication(AdApplication ad) async {
    final now = DateTime.now();
    await _adsApplicationCol.add({
      ...ad.toJson(),
      'status': 'Menunggu',
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  /// Ambil semua pengajuan iklan (by sellerId)
  static Future<List<AdApplication>> getApplicationsBySeller(String sellerId) async {
    final snapshot = await _adsApplicationCol
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => AdApplication.fromFirestore(doc)).toList();
  }

  /// Ambil SEMUA pengajuan iklan (untuk admin, bisa filter status, store, dsb)
  static Future<List<AdApplication>> getAllApplications({
    String? status,
    String? storeId,
    String? sellerId,
  }) async {
    Query query = _adsApplicationCol.orderBy('createdAt', descending: true);

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    if (storeId != null && storeId.isNotEmpty) {
      query = query.where('storeId', isEqualTo: storeId);
    }
    if (sellerId != null && sellerId.isNotEmpty) {
      query = query.where('sellerId', isEqualTo: sellerId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => AdApplication.fromFirestore(doc)).toList();
  }

  /// Ambil detail pengajuan (by id)
  static Future<AdApplication?> getApplicationById(String id) async {
    final doc = await _adsApplicationCol.doc(id).get();
    if (!doc.exists) return null;
    return AdApplication.fromFirestore(doc);
  }

  /// Update status pengajuan (ADMIN, bisa tambah alasanReject jika ada)
  static Future<void> updateStatus({
    required String id,
    required String newStatus,
    String? rejectReason, // Optional
  }) async {
    final data = {
      'status': newStatus,
      'updatedAt': Timestamp.now(),
    };
    if (rejectReason != null && rejectReason.isNotEmpty) {
      data['rejectReason'] = rejectReason;
    }
    await _adsApplicationCol.doc(id).update(data);
  }

  /// Update data pengajuan (optional)
  static Future<void> updateAdApplication(String id, Map<String, dynamic> data) async {
    await _adsApplicationCol.doc(id).update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Listen real-time data (by sellerId)
  static Stream<List<AdApplication>> listenApplicationsBySeller(String sellerId) {
    return _adsApplicationCol
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AdApplication.fromFirestore(doc)).toList());
  }

  /// Listen real-time semua pengajuan (ADMIN)
  static Stream<List<AdApplication>> listenAllApplications({String? status}) {
    Query query = _adsApplicationCol.orderBy('createdAt', descending: true);
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AdApplication.fromFirestore(doc))
              .toList(),
        );
  }

  /// Listen real-time by store (opsional buat dashboard admin)
  static Stream<List<AdApplication>> listenApplicationsByStore(String storeId) {
    return _adsApplicationCol
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AdApplication.fromFirestore(doc)).toList());
  }
}
