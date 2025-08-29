import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_page.dart';
import 'forgot_password/forgot_password_page.dart';
import '../../widgets/custom_textfield.dart';
import '../../data/services/google_auth_service.dart';
import '../home/home_page_buyer.dart';
import '../../../admin/features/home/home_page_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  // --- Helpers --------------------------------------------------------------

  // Pastikan role selalu berupa List<String>
  List<String> _roleToList(dynamic role) {
    if (role is String) return [role];
    if (role is List) return role.cast<String>();
    return ['buyer'];
  }

  // Wallet default untuk self-heal
  Map<String, dynamic> _defaultWallet() => {
        'available': 0,
        'onHold': 0,
        'currency': 'IDR',
        'updatedAt': FieldValue.serverTimestamp(),
      };

  // Self-heal doc user: normalisasi role, inject wallet, set lastLogin & isOnline
  Future<void> _selfHealUserDoc(
    DocumentReference<Map<String, dynamic>> userDocRef,
    Map<String, dynamic> data, {
    bool ensureBuyerRole = false,
  }) async {
    final updates = <String, dynamic>{
      'lastLogin': FieldValue.serverTimestamp(),
      'isOnline': true,
    };

    // Role normalisasi → List<String>
    if (data['role'] == null || data['role'] is! List) {
      updates['role'] = _roleToList(data['role']);
    } else if (ensureBuyerRole) {
      // Untuk login Google: pastikan buyer ada
      final roles = _roleToList(data['role']);
      if (!roles.contains('buyer')) {
        roles.add('buyer');
        updates['role'] = roles;
      }
    }

    // Inject wallet jika belum ada
    if (data['wallet'] == null) {
      updates['wallet'] = _defaultWallet();
    }

    if (updates.isNotEmpty) {
      await userDocRef.set(updates, SetOptions(merge: true));
    }
  }

  // --- Email/Password login -------------------------------------------------

  Future<void> _handleLogin() async {
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    FocusScope.of(context).unfocus();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = "Email dan password wajib diisi";
        _isLoading = false;
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;

      final user = credential.user;
      if (user != null) {
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          setState(() {
            _errorText = "Data user tidak ditemukan di database.";
            _isLoading = false;
          });
          return;
        }

        final data = userDoc.data()!;
        final isActive = data['isActive'] ?? true;
        final roles = _roleToList(data['role']);

        // ✅ SELF-HEAL
        await _selfHealUserDoc(userDocRef, data);
        if (!mounted) return;

        if (!isActive) {
          setState(() {
            _errorText = "Akun Anda tidak aktif. Hubungi admin.";
            _isLoading = false;
          });
          return;
        }

        // Arahkan berdasarkan role
        if (roles.contains('admin')) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePageAdmin()),
          );
        } else {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Gagal login. Silakan coba lagi.";
      if (e.code == 'user-not-found') {
        message = "Email tidak ditemukan.";
      } else if (e.code == 'wrong-password') {
        message = "Password salah.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      }
      setState(() {
        _errorText = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorText = "Terjadi kesalahan: $e";
        _isLoading = false;
      });
    }
  }

  // --- Google login ---------------------------------------------------------

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final userCredential = await GoogleAuthService.signInWithGoogle();
      if (userCredential != null && mounted) {
        final user = userCredential.user;
        if (user != null) {
          final userDoc =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          final snapshot = await userDoc.get();

          if (!snapshot.exists) {
            // Buat dokumen user baru (termasuk wallet)
            await userDoc.set({
              'uid': user.uid,
              'email': user.email,
              'name': user.displayName ?? '',
              'role': ['buyer'], // ROLE ALWAYS LIST
              'createdAt': FieldValue.serverTimestamp(),
              'isActive': true,
              'isOnline': true,
              'lastLogin': FieldValue.serverTimestamp(),
              'wallet': _defaultWallet(),
            }, SetOptions(merge: true));
          } else {
            // ✅ SELF-HEAL untuk user lama
            final data = snapshot.data()!;
            await _selfHealUserDoc(
              userDoc,
              data,
              ensureBuyerRole: true,
            );
          }
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login dengan Google dibatalkan.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal login dengan Google: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const colorPlaceholder = Color(0xFF757575);
    const colorInput = Color(0xFF404040);
    const colorPrimary = Color(0xFF1C55C0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Selamat Datang!",
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Masukkan email Anda untuk mulai berbelanja dan mendapatkan penawaran menarik hari ini!",
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: colorPlaceholder,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Field
                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  iconPath: "assets/icons/mail.svg",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  focusNode: emailFocusNode,
                  nextFocusNode: passwordFocusNode,
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  iconPath: "assets/icons/lock-icon.svg",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  obscureText: _obscurePassword,
                  focusNode: passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => _handleLogin(),
                  suffixIcon: Tooltip(
                    message: _obscurePassword
                        ? "Tampilkan Password"
                        : "Sembunyikan Password",
                    child: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => setState(
                              () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context)
                            .push(_createRouteToForgotPassword()),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      "Lupa Password?",
                      style: GoogleFonts.dmSans(
                        color: colorPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol Masuk
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Masuk",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Divider "Atau"
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Atau",
                        style: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // Masuk dengan Google
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: Image.asset(
                      'assets/icons/google.png',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(
                      "Masuk dengan Google",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: colorPrimary,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: colorPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                  ),
                ),
                const SizedBox(height: 36),

                // Belum punya akun? Daftar
                Center(
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => Navigator.of(context).push(
                              _createRouteToSignUp(),
                            ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                        children: [
                          const TextSpan(text: "Belum punya akun? "),
                          TextSpan(
                            text: "Daftar",
                            style: TextStyle(
                              color: colorPrimary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Transisi ke Signup
Route _createRouteToSignUp() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

// Transisi ke Forgot Password
Route _createRouteToForgotPassword() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const ForgotPasswordPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
