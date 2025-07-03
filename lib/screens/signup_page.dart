import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'login_page.dart';
import '../data/services/auth_service.dart'; // Pastikan path benar

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Untuk validasi sederhana
  bool get _formValid =>
      firstNameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty;

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
                  "Buat Akun",
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorInput,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Lengkapi data Anda di bawah untuk mulai belanja dengan nyaman.",
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: colorPlaceholder,
                  ),
                ),
                const SizedBox(height: 32),

                // Nama Depan
                _CustomTextField(
                  controller: firstNameController,
                  label: "Nama Depan",
                  iconPath: "assets/icons/user-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Nama Belakang
                _CustomTextField(
                  controller: lastNameController,
                  label: "Nama Belakang",
                  iconPath: "assets/icons/user-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Email
                _CustomTextField(
                  controller: emailController,
                  label: "Email",
                  iconPath: "assets/icons/mail-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Password
                _CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  iconPath: "assets/icons/lock-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Terms & Privacy
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.dmSans(
                        color: colorPlaceholder,
                        fontSize: 13.5,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              "Dengan mengklik Buat Akun, Anda menyatakan telah membaca dan menyetujui ",
                        ),
                        TextSpan(
                          text: "Syarat Penggunaan",
                          style: const TextStyle(
                            color: colorPrimary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: Arahkan ke halaman syarat penggunaan
                            },
                        ),
                        const TextSpan(text: " dan "),
                        TextSpan(
                          text: "Kebijakan Privasi",
                          style: const TextStyle(
                            color: colorPrimary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: Arahkan ke halaman kebijakan privasi
                            },
                        ),
                        const TextSpan(text: " kami."),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol Buat Akun
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
                    onPressed: _isLoading || !_formValid
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            String? result = await _authService.signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                            );
                            setState(() => _isLoading = false);

                            if (result == null) {
                              // Sukses! Navigasi ke login
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Registrasi Berhasil"),
                                    content: const Text(
                                        "Akun berhasil dibuat! Silakan login."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                            ..pop()
                                            ..pushReplacement(_createRouteToLogin());
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              // Gagal! Show pesan error
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Registrasi Gagal"),
                                    content: Text(result),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Buat Akun",
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
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 32),

                // Already have an account? Login
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(_createRouteToLogin());
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Login",
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

// Custom TextField Widget sama seperti login page, kini support onChanged
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String iconPath;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Color colorPlaceholder;
  final Color colorInput;
  final ValueChanged<String>? onChanged;

  const _CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.iconPath,
    required this.colorPlaceholder,
    required this.colorInput,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
        suffixIcon: suffixIcon,
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
      onChanged: onChanged,
    );
  }
}

// Transisi animasi ke login page
Route _createRouteToLogin() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
