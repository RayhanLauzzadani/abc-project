import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'forgot_password_otp_page.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../data/services/otp_service.dart';

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

  Future<void> _validateAndSendCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Email ditemukan, kirim kode OTP
        final success = await OtpService.sendOtpToEmail(email);

        if (success) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ForgotPasswordOtpPage(email: email),
            ),
          );
        } else {
          _showErrorDialog(
            title: "Gagal Mengirim Kode",
            message: "Terjadi kesalahan saat mengirim kode OTP.\nSilakan coba beberapa saat lagi.",
          );
        }
      } else {
        _showErrorDialog(
          title: "Email Tidak Ditemukan",
          message: "Kami tidak menemukan akun dengan email \"$email\".\nSilakan periksa kembali atau daftar akun baru.",
        );
      }
    } catch (e) {
      _showErrorDialog(
        title: "Terjadi Kesalahan",
        message: "Gagal memverifikasi email atau mengirim OTP.\n\nDetail: $e",
      );
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog({required String title, required String message}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message, style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
                        "Kami akan membantu Anda memulihkan akun Anda.",
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
                        iconPath: "assets/icons/mail-icon.png",
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
                          onPressed: _isLoading ? null : _validateAndSendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Kirim Kode",
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
