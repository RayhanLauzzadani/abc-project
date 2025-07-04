import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_textfield.dart';
import 'forgot_password_success_page.dart';

class ForgotPasswordResetPage extends StatefulWidget {
  const ForgotPasswordResetPage({super.key});

  @override
  State<ForgotPasswordResetPage> createState() =>
      _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  static const colorPrimary = Color(0xFF1C55C0);
  static const colorPlaceholder = Color(0xFF757575);
  static const colorInput = Color(0xFF404040);

  bool get isFormValid {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    return newPassword.length >= 8 &&
        confirmPassword.length >= 8 &&
        newPassword == confirmPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
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

              // Title
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

              // Password Baru
              CustomTextField(
                controller: newPasswordController,
                label: "Password Baru",
                iconPath: "assets/icons/lock-icon.png",
                obscureText: _obscureNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                colorPlaceholder: colorPlaceholder,
                colorInput: colorInput,
                focusNode: newPasswordFocus,
                nextFocusNode: confirmPasswordFocus,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              if (newPasswordController.text.isNotEmpty &&
                  newPasswordController.text.length < 8)
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

              // Konfirmasi Password Baru
              CustomTextField(
                controller: confirmPasswordController,
                label: "Konfirmasi Password Baru",
                iconPath: "assets/icons/lock-icon.png",
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                colorPlaceholder: colorPlaceholder,
                colorInput: colorInput,
                focusNode: confirmPasswordFocus,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 32),

              // Tombol Atur Ulang Password
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordSuccessPage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    disabledBackgroundColor: colorPrimary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Atur Ulang Password",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
    void dispose() {
      newPasswordController.dispose();
      confirmPasswordController.dispose();
      newPasswordFocus.dispose();
      confirmPasswordFocus.dispose();
      super.dispose();
    }
}
