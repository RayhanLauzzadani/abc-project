import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  static const Color colorPlaceholder = Color(0xFF757575);
  static const Color colorInput = Color(0xFF404040);
  static const Color colorPrimary = Color(0xFF1C55C0);

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
              // Tombol back manual
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
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
              const SizedBox(height: 24), // Spacer bawah tombol back
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
              _CustomTextField(
                controller: emailController,
                label: "Email",
                iconPath: "assets/icons/mail-icon.png",
                colorPlaceholder: colorPlaceholder,
                colorInput: colorInput,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Tombol Kirim Kode
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordOtpPage(email: emailController.text),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Kirim Kode",
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
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
}

// Widget untuk textfield
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String iconPath;
  final TextInputType? keyboardType;
  final Color colorPlaceholder;
  final Color colorInput;

  const _CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.iconPath,
    required this.colorPlaceholder,
    required this.colorInput,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        color: controller.text.isEmpty ? colorPlaceholder : colorInput,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w500,
          color: colorPlaceholder,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(iconPath, width: 20, height: 20),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintText: label,
        hintStyle: GoogleFonts.dmSans(color: colorPlaceholder),
      ),
      onChanged: (_) {
        (context as Element).markNeedsBuild();
      },
    );
  }
}
