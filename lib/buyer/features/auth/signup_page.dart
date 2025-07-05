import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'login_page.dart';
import '../../widgets/custom_textfield.dart';
import '../../data/services/auth_service.dart';

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

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get _isEmailValid {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegex.hasMatch(email);
  }

  bool get _formValid =>
      firstNameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty &&
      _isEmailValid &&
      passwordController.text.length >= 8;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

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
                CustomTextField(
                  controller: firstNameController,
                  label: "Nama Depan",
                  iconPath: "assets/icons/user-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  focusNode: firstNameFocus,
                  textInputAction: TextInputAction.next,
                  nextFocusNode: lastNameFocus,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Nama Belakang
                CustomTextField(
                  controller: lastNameController,
                  label: "Nama Belakang",
                  iconPath: "assets/icons/user-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  focusNode: lastNameFocus,
                  textInputAction: TextInputAction.next,
                  nextFocusNode: emailFocus,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  iconPath: "assets/icons/mail-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  keyboardType: TextInputType.emailAddress,
                  focusNode: emailFocus,
                  textInputAction: TextInputAction.next,
                  nextFocusNode: passwordFocus,
                  onChanged: (_) => setState(() {}),
                ),

                if (emailController.text.isNotEmpty && !_isEmailValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Format email tidak valid",
                      style: GoogleFonts.dmSans(
                        color: Colors.red.shade600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  iconPath: "assets/icons/lock-icon.png",
                  colorPlaceholder: colorPlaceholder,
                  colorInput: colorInput,
                  obscureText: _obscurePassword,
                  focusNode: passwordFocus,
                  textInputAction: TextInputAction.done,
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

                if (passwordController.text.isNotEmpty &&
                    passwordController.text.length < 8)
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
                    onPressed: () {
                      // TODO: Google auth
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Sudah punya akun? Login
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
                          const TextSpan(text: "Sudah punya akun? "),
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

// Transisi ke Login Page
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
