import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../widgets/custom_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  static const Color colorPlaceholder = Color(0xFF757575);
  static const Color colorInput = Color(0xFF404040);
  static const Color colorPrimary = Color(0xFF1C55C0);

  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Tampilkan dialog sukses
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Email Terkirim"),
            content: Text(
              "Link reset password sudah dikirim ke:\n\n$email\n\n"
              "Silakan cek email kamu (inbox atau spam) dan klik link tersebut untuk mengatur ulang password.",
              style: GoogleFonts.dmSans(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop(); // Kembali ke halaman login
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Gagal mengirim email reset password.";
      if (e.code == "user-not-found") {
        message = "Email tidak terdaftar.";
      } else if (e.code == "invalid-email") {
        message = "Format email tidak valid.";
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Gagal"),
          content: Text(message, style: GoogleFonts.dmSans()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Terjadi kesalahan: $e", style: GoogleFonts.dmSans()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tombol back
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: colorPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Judul
                      Text(
                        "Lupa Password",
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorInput,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Masukkan email akun kamu, kami akan kirimkan link untuk mengatur ulang password.",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: colorPlaceholder,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input email
                      CustomTextField(
                        controller: emailController,
                        label: "Email",
                        iconPath: "assets/icons/mail.svg",
                        colorPlaceholder: colorPlaceholder,
                        colorInput: colorInput,
                        focusNode: emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // Tombol kirim kode
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendResetEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Kirim Link Reset",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
