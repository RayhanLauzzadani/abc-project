import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:abc_e_mart/seller/providers/seller_registration_provider.dart';

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
  final _formKey = GlobalKey<FormState>();

  TextEditingController? _namaController;
  TextEditingController? _nikController;
  TextEditingController? _bankController;
  TextEditingController? _rekController;
  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized) {
      final provider = Provider.of<SellerRegistrationProvider>(context);
      _namaController = TextEditingController(text: provider.nama);
      _nikController = TextEditingController(text: provider.nik);
      _bankController = TextEditingController(text: provider.bank);
      _rekController = TextEditingController(text: provider.rek);
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _namaController?.dispose();
    _nikController?.dispose();
    _bankController?.dispose();
    _rekController?.dispose();
    super.dispose();
  }

  void _onFieldChanged(BuildContext context) {
    final provider = Provider.of<SellerRegistrationProvider>(context, listen: false);
    provider.setNama(_namaController?.text ?? '');
    provider.setNik(_nikController?.text ?? '');
    provider.setBank(_bankController?.text ?? '');
    provider.setRek(_rekController?.text ?? '');
    setState(() {});
  }

  bool _allFieldsFilled(SellerRegistrationProvider provider) {
    return provider.nama.trim().isNotEmpty &&
        provider.nik.trim().isNotEmpty &&
        provider.bank.trim().isNotEmpty &&
        provider.rek.trim().isNotEmpty &&
        provider.ktpFile != null &&
        provider.agreeTerms;
  }

  void _trySubmit(BuildContext context, SellerRegistrationProvider provider) {
    if (!_allFieldsFilled(provider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dan upload KTP!')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ShopInfoFormPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerRegistrationProvider>(context);

    // Selalu sync controller jika data di provider berubah dari luar
    _namaController?.value = TextEditingValue(
      text: provider.nama,
      selection: _namaController?.selection ?? const TextSelection.collapsed(offset: 0),
    );
    _nikController?.value = TextEditingValue(
      text: provider.nik,
      selection: _nikController?.selection ?? const TextSelection.collapsed(offset: 0),
    );
    _bankController?.value = TextEditingValue(
      text: provider.bank,
      selection: _bankController?.selection ?? const TextSelection.collapsed(offset: 0),
    );
    _rekController?.value = TextEditingValue(
      text: provider.rek,
      selection: _rekController?.selection ?? const TextSelection.collapsed(offset: 0),
    );

    final double screenWidth = MediaQuery.of(context).size.width;
    double stepperPadding = 63;
    if (screenWidth < 360) {
      stepperPadding = 16;
    } else if (screenWidth < 500) {
      stepperPadding = 24;
    }

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

            // --- KTP Upload Section (langsung pakai provider)
            KtpUploadSection(
              onKtpOcrResult: (String? nik, String? nama) {
                if (nik != null) {
                  _nikController?.text = nik;
                  provider.setNik(nik);
                }
                if (nama != null) {
                  _namaController?.text = nama;
                  provider.setNama(nama);
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 20),

            // === FORM FIELDS ===
            FormTextField(
              label: "Nama",
              requiredMark: true,
              maxLength: 40,
              hintText: "Masukkan",
              controller: _namaController!,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Wajib diisi"
                  : null,
              onChanged: (_) => _onFieldChanged(context),
            ),
            const SizedBox(height: 20),

            FormTextField(
              label: "NIK",
              requiredMark: true,
              maxLength: 16,
              hintText: "Masukkan",
              controller: _nikController!,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return "Wajib diisi";
                if (val.length != 16) return "NIK harus 16 digit";
                return null;
              },
              onChanged: (_) => _onFieldChanged(context),
            ),
            const SizedBox(height: 20),

            FormTextField(
              label: "Nama Bank",
              requiredMark: true,
              maxLength: 300,
              hintText: "Masukkan",
              controller: _bankController!,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Wajib diisi"
                  : null,
              onChanged: (_) => _onFieldChanged(context),
            ),
            const SizedBox(height: 20),

            FormTextField(
              label: "No. Rekening Bank",
              requiredMark: true,
              maxLength: 300,
              hintText: "Masukkan",
              controller: _rekController!,
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Wajib diisi"
                  : null,
              onChanged: (_) => _onFieldChanged(context),
            ),
            const SizedBox(height: 28),

            // --- Terms & Conditions Checkbox (provider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TermsCheckbox(
                value: provider.agreeTerms,
                onChanged: (checked) {
                  provider.setAgreeTerms(checked ?? false);
                  setState(() {});
                },
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
              onPressed: _allFieldsFilled(provider)
                  ? () {
                      if (_formKey.currentState!.validate() &&
                          provider.agreeTerms) {
                        _onFieldChanged(context); // sync last value
                        _trySubmit(context, provider);
                      }
                    }
                  : null,
              enabled: _allFieldsFilled(provider),
            ),
          ],
        ),
      ),
    );
  }
}
