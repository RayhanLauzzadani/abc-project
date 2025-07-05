import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgot_password_success_page.dart';

class ForgotPasswordResetPage extends StatefulWidget {
  final String email;

  const ForgotPasswordResetPage({super.key, required this.email});

  @override
  State<ForgotPasswordResetPage> createState() => _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  static const colorPrimary = Color(0xFF1C55C0);
  static const colorPlaceholder = Color(0xFF757575);
  static const colorInput = Color(0xFF404040);

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_validateFields);
    confirmPasswordController.addListener(_validateFields);
  }

  void _validateFields() {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    final isValid = newPassword.length >= 8 &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;

    setState(() {
      _isButtonEnabled = isValid;
    });
  }

  Future<void> _handleResetPassword() async {
    final email = widget.email.trim();
    final newPassword = newPasswordController.text;

    setState(() => _isLoading = true);

    try {
      // Simpan password baru ke Firestore (bisa disesuaikan kalau pakai Firebase Auth)
      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'password': newPassword,
      });

      // Hapus dokumen OTP
      await FirebaseFirestore.instance.collection('otp_codes').doc(email).delete();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ForgotPasswordSuccessPage(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengatur ulang password: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordTooShort =
        newPasswordController.text.isNotEmpty && newPasswordController.text.length < 8;

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
                      InkWell(
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
                      const SizedBox(height: 24),

                      Text(
                        "Atur Ulang Password",
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorInput,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Buat kata sandi baru. Pastikan kata sandi tersebut berbeda dari yang sebelumnya demi keamanan.",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: colorPlaceholder,
                        ),
                      ),
                      const SizedBox(height: 32),

                      CustomTextField(
                        controller: newPasswordController,
                        label: "Password Baru",
                        iconPath: "assets/icons/lock-icon.png",
                        colorPlaceholder: colorPlaceholder,
                        colorInput: colorInput,
                        obscureText: _obscureNewPassword,
                        focusNode: newPasswordFocus,
                        nextFocusNode: confirmPasswordFocus,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => _obscureNewPassword = !_obscureNewPassword);
                          },
                        ),
                      ),

                      if (passwordTooShort)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "Password minimal 8 karakter",
                            style: GoogleFonts.dmSans(
                              color: Colors.red.shade600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: confirmPasswordController,
                        label: "Konfirmasi Password Baru",
                        iconPath: "assets/icons/lock-icon.png",
                        colorPlaceholder: colorPlaceholder,
                        colorInput: colorInput,
                        obscureText: _obscureConfirmPassword,
                        focusNode: confirmPasswordFocus,
                        textInputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled && !_isLoading ? _handleResetPassword : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isButtonEnabled ? colorPrimary : colorPrimary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Atur Ulang Password",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
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