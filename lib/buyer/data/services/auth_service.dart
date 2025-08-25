import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up (Register)
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // 1. Register ke Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // 2. Simpan data ke Firestore
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': '$firstName $lastName',
          'role': ['buyer'], // <-- WAJIB ARRAY agar fitur admin approval berjalan!
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'storeName': "",
          'addressList': [],
             'wallet': {
            'available': 0,
            'onHold': 0,
            'currency': 'IDR',
            'updatedAt': FieldValue.serverTimestamp(),
            }
        });
        return null; // sukses
      }
      return "Terjadi kesalahan, silakan coba lagi.";
    } on FirebaseAuthException catch (e) {
      return e.message; // tampilkan pesan error dari Firebase
    } catch (e) {
      return e.toString();
    }
  }

  // (Optional) Tambahan, untuk konversi data lama yang role-nya masih String:
  Future<void> fixRoleIfString(String uid) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    if (snap.exists && snap.data() != null && snap.data()!['role'] is String) {
      await ref.update({'role': [snap.data()!['role']]});
    }
  }
}