import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tambah alamat baru ke subkoleksi user
  Future<void> addAddress(String userId, AddressModel address) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .add(address.toMap());
  }

  // Update alamat lama (by id)
  Future<void> updateAddress(String userId, String addressId, AddressModel address) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .update(address.toMap());
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
}
