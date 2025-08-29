import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_page.dart';
import 'home_page_buyer.dart';
import '../../../admin/features/home/home_page_admin.dart';

/// Gate reaktif: menentukan halaman tanpa navigasi imperative.
/// Menghindari flicker/stack wipe karena tidak menggunakan push/pop dari Splash.
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  Future<bool> _isAdmin(User user) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snap.data() ?? {};
    final role = data['role'];
    final roles = role is List ? role.cast<String>() : [if (role != null) '$role'];
    return roles.contains('admin');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.active) {
          return const _SplashLogo();
        }

        final user = snap.data;
        if (user == null) return const LoginPage();

        return FutureBuilder<bool>(
          future: _isAdmin(user),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState != ConnectionState.done) {
              return const _SplashLogo();
            }
            return roleSnap.data == true
                ? const HomePageAdmin()
                : const HomePage();
          },
        );
      },
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Image(
            image: AssetImage('assets/images/logo.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
