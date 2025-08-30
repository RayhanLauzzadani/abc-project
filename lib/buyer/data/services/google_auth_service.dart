import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // Wallet default
  static Map<String, dynamic> _defaultWallet() => {
        'available': 0,
        'onHold': 0,
        'currency': 'IDR',
        'updatedAt': FieldValue.serverTimestamp(),
      };

  // Normalisasi role -> selalu List<String> dan pastikan minimal buyer
  static List<String> _normalizeRoles(dynamic role, {bool ensureBuyer = true}) {
    List<String> roles;
    if (role is String) {
      roles = [role];
    } else if (role is List) {
      roles = role.cast<String>();
    } else {
      roles = ['buyer'];
    }
    if (ensureBuyer && !roles.contains('buyer')) {
      roles.add('buyer');
    }
    return roles;
  }

  // Self-heal dokumen user lama: role -> list, inject wallet, set lastLogin & isOnline.
  static Future<void> _selfHealUserDoc(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    final updates = <String, dynamic>{
      'lastLogin': FieldValue.serverTimestamp(),
      'isOnline': true,
    };

    // role → List<String> & pastikan mengandung 'buyer'
    updates['role'] = _normalizeRoles(data['role'], ensureBuyer: true);

    // wallet
    if (data['wallet'] == null) {
      updates['wallet'] = _defaultWallet();
    }

    await ref.set(updates, SetOptions(merge: true));
  }

  /// Sign-in dengan Google dan sinkronisasi ke Firestore
  static Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();

    // optional: paksa tampil pemilih akun
    try {
      await googleSignIn.signOut();
    } catch (_) {}

    // 1) Pilih akun Google
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // dibatalkan user

    // 2) Ambil token
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3) Credential Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      // 4) Login ke Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return userCredential;

      final userDocRef = _db.collection('users').doc(user.uid);
      final snap = await userDocRef.get();

      if (!snap.exists) {
        // 5a) User baru → buat dokumen lengkap (schema konsisten)
        await userDocRef.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'role': <String>['buyer'],
          'isActive': true,
          'isOnline': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'wallet': _defaultWallet(),
          // bid’ah lama (optional agnostic UI)
          'storeName': '',
          'addressList': [],
        }, SetOptions(merge: true));
      } else {
        // 5b) User lama → self-heal (role list + wallet + lastLogin/isOnline)
        await _selfHealUserDoc(userDocRef, snap.data() as Map<String, dynamic>);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Tangani akun sudah ada dengan credential berbeda
      if (e.code == 'account-exists-with-different-credential') {
        // Best effort UX note:
        // Kamu bisa fetch metode yang tersedia dan beri instruksi user untuk login dengan metode itu.
        // final email = e.email;
        // final methods = await _auth.fetchSignInMethodsForEmail(email!);
        // show UI → minta user login dengan metode tsb lalu link credential:
        // await (await _auth.signInWithEmailAndPassword(...)).user!.linkWithCredential(credential);
      }
      rethrow;
    }
  }
}
