import 'package:cloud_firestore/cloud_firestore.dart';  // Pastikan ini ada
import '../models/address.dart';  // Pastikan ini ada

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tambah alamat baru ke subkoleksi user (otomatis primary jika address pertama)
  Future<void> addAddress(String userId, AddressModel address, {bool setAsPrimary = false}) async {
    final ref = _firestore.collection('users').doc(userId).collection('addresses');
    final snapshot = await ref.get();

    bool isFirst = snapshot.docs.isEmpty;
    bool isPrimary = setAsPrimary || isFirst;

    // Reset primary address lain kalau yang baru ini jadi primary
    if (isPrimary) {
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isPrimary': false});
      }
      await batch.commit();
    }

    await ref.add({
      ...address.toMap(),
      'isPrimary': isPrimary,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update alamat lama (by id, opsi set primary)
  Future<void> updateAddress(String userId, String addressId, AddressModel address, {bool setAsPrimary = false}) async {
    final ref = _firestore.collection('users').doc(userId).collection('addresses');
    if (setAsPrimary) {
      final snapshot = await ref.get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isPrimary': doc.id == addressId});
      }
      await batch.commit();
    }
    await ref.doc(addressId).update(address.toMap());
  }

  // Jadikan alamat utama
  Future<void> setPrimaryAddress(String userId, String addressId) async {
    final ref = _firestore.collection('users').doc(userId).collection('addresses');
    final snapshot = await ref.get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isPrimary': doc.id == addressId});
    }
    await batch.commit();
  }

  // Ambil list alamat user (stream)
  Stream<List<AddressModel>> getAddresses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Ambil alamat utama saja (misal untuk homepage)
  Stream<AddressModel?> getPrimaryAddress(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isPrimary', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final doc = snap.docs.first;
          return AddressModel.fromMap(doc.id, doc.data());
        });
  }

  // Menambahkan fungsi baru untuk mengambil alamat utama sekali saja (tidak stream)
  Future<AddressModel?> getPrimaryAddressOnce(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('isPrimary', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return AddressModel.fromMap(doc.id, doc.data());
    } catch (e) {
      print('Error fetching primary address: $e');
      return null;
    }
  }
}
