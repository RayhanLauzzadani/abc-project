import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/seller/widgets/registration_app_bar.dart';
import 'package:abc_e_mart/seller/widgets/registration_stepper.dart';
import 'package:abc_e_mart/seller/widgets/ktp_upload_section.dart';
import 'package:abc_e_mart/seller/widgets/form_text_field.dart';
import 'package:abc_e_mart/seller/widgets/terms_checkbox.dart';
import 'package:abc_e_mart/seller/widgets/bottom_action_buttons.dart';
import 'package:abc_e_mart/seller/features/registration/shop_info_form_page.dart';

class VerificationFormPage extends StatefulWidget {
  const VerificationFormPage({super.key});

  @override
  State<VerificationFormPage> createState() => _VerificationFormPageState();
}

class _VerificationFormPageState extends State<VerificationFormPage> {
  bool agreeTerms = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _rekController = TextEditingController();

  bool _allFieldsFilled() {
    return _namaController.text.trim().isNotEmpty &&
        _nikController.text.trim().isNotEmpty &&
        _bankController.text.trim().isNotEmpty &&
        _rekController.text.trim().isNotEmpty;
  }

  void _trySubmit() {
    if (_formKey.currentState?.validate() == true && agreeTerms) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const ShopInfoFormPage(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  void _onFieldChanged(String _) {
    setState(() {}); // Untuk update state button Lanjut
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _bankController.dispose();
    _rekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double stepperPadding = 63;
    if (screenWidth < 360) {
      stepperPadding = 16;
    } else if (screenWidth < 500) {
      stepperPadding = 24;
    }

    final formIsReady = _allFieldsFilled() && agreeTerms;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(79),
        child: RegistrationAppBar(title: "Verifikasi Data Diri"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: stepperPadding),
              child: const RegistrationStepper(currentStep: 0),
            ),
            const SizedBox(height: 32),
            KtpUploadSection(
              onKtpOcrResult: (String? nik, String? nama) {
                _nikController.text = nik ?? '';
                _namaController.text = nama ?? '';
                setState(() {}); // Update form
              },
            ),
            const SizedBox(height: 20),

            // --- Fields Section ---
            FormTextField(
              label: "Nama",
              requiredMark: true,
              maxLength: 40,
              hintText: "Masukkan",
              controller: _namaController,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? "Wajib diisi" : null,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 20),

            FormTextField(
              label: "NIK",
              requiredMark: true,
              maxLength: 16,
              hintText: "Masukkan",
              controller: _nikController,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return "Wajib diisi";
                if (val.length != 16) return "NIK harus 16 digit";
                return null;
              },
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 20),

            FormTextField(
              label: "Nama Bank",
              requiredMark: true,
              maxLength: 300,
              hintText: "Masukkan",
              controller: _bankController,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? "Wajib diisi" : null,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 20),

            FormTextField(
              label: "No. Rekening Bank",
              requiredMark: true,
              maxLength: 300,
              hintText: "Masukkan",
              controller: _rekController,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? "Wajib diisi" : null,
              onChanged: _onFieldChanged,
            ),
            const SizedBox(height: 28),

            // --- Terms & Conditions Checkbox ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TermsCheckbox(
                value: agreeTerms,
                onChanged: (checked) =>
                    setState(() => agreeTerms = checked ?? false),
                onTapLink: () {
                  // TODO: Navigasi ke halaman syarat & ketentuan
                },
              ),
            ),

            // --- Informasi tambahan bawah checkbox ---
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Dengan melengkapi formulir ini, Penjual telah menyatakan bahwa:\n"
                "• Semua info yang diberikan kepada ABC e-mart adalah akurat, valid, dan terbaru.\n"
                "• Penjual memiliki izin dan kekuasaan penuh sesuai hukum yang berlaku untuk menawarkan semua produk di ABC e-mart.\n"
                "• Semua tindakan yang dilakukan oleh Penjual telah sah, serta merupakan perjanjian yang berlaku bagi Penjual.",
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF373E3C),
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 40),

            BottomActionButton(
              text: "Lanjut",
              onPressed: formIsReady
                  ? () {
                      // validasi & submit
                      if (_formKey.currentState!.validate() && agreeTerms) {
                        _trySubmit();
                      }
                    }
                  : null,
              enabled: formIsReady,
            ),
          ],
        ),
      ),
    );
  }
}
