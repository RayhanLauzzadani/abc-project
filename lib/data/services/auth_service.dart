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
          'name': '$firstName $lastName',
          'email': email,
          'role': 'buyer',
          'storeName': "",
          'createdAt': FieldValue.serverTimestamp(),
          'addressList': [],
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
}
