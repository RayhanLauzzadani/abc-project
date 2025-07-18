import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';
import '../../widgets/custom_textfield.dart';
import 'package:abc_e_mart/buyer/widgets/change_pass_success.dart'; // <-- Import Success Dialog baru!

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorText;

  final _oldFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() {
        _errorText = "Semua field wajib diisi";
        _isLoading = false;
      });
      return;
    }
    if (newPass.length < 6) {
      setState(() {
        _errorText = "Password baru minimal 6 karakter";
        _isLoading = false;
      });
      return;
    }
    if (newPass != confirmPass) {
      setState(() {
        _errorText = "Konfirmasi password tidak sama";
        _isLoading = false;
      });
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) throw Exception("User tidak ditemukan");

      // 1. Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPass,
      );
      await user.reauthenticateWithCredential(cred);

      // 2. Update password
      await user.updatePassword(newPass);

      if (mounted) {
        setState(() => _isLoading = false);
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ChangePassSuccessDialog(),
        );
        if (mounted) Navigator.pop(context); // Pop ke halaman sebelumnya
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Gagal ganti password.";
      if (e.code == "wrong-password") {
        msg = "Password saat ini salah.";
      } else if (e.code == "weak-password") {
        msg = "Password baru terlalu lemah.";
      } else if (e.code == "requires-recent-login") {
        msg = "Sesi login sudah lama, silakan login ulang.";
      }
      setState(() {
        _errorText = msg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorText = "Terjadi error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required FocusNode focusNode,
    FocusNode? nextFocus,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      iconPath: "assets/icons/lock-icon.svg",
      colorPlaceholder: const Color(0xFF757575),
      colorInput: const Color(0xFF404040),
      obscureText: obscure,
      focusNode: focusNode,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      nextFocusNode: nextFocus,
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
        ),
        onPressed: onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(title: "Ganti Password"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 32),
              Text(
                "Silakan masukkan kata sandi Anda untuk mengganti password.",
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF757575),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 28),
              _buildPasswordField(
                label: "Password Saat Ini",
                controller: _oldPasswordController,
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
                focusNode: _oldFocus,
                nextFocus: _newFocus,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: "Password Baru",
                controller: _newPasswordController,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                focusNode: _newFocus,
                nextFocus: _confirmFocus,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: "Konfirmasi Password Baru",
                controller: _confirmPasswordController,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                focusNode: _confirmFocus,
              ),
              const SizedBox(height: 8),

              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushNamed('/forgot-password');
                        },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(
                    "Lupa Password?",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF1C55C0),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C55C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleChangePassword,
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
                          "Ganti Password",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
