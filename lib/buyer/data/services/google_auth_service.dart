import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // 🔁 Pastikan logout dulu agar bisa pilih akun lagi
    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in ke Firebase Auth
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // ⬇️ Tambahan: Simpan ke Firestore jika user baru
    final user = userCredential.user;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        // Buat dokumen user baru sesuai struktur Firestore-mu
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'buyer',
          'createdAt': DateTime.now(),
          'addressList': [],
          'storeName': "",
          // Tambah field lain sesuai kebutuhan (misal: phone/favorites dsb)
        });
      }
    }

    return userCredential;
  }
}
