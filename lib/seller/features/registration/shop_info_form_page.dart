import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:abc_e_mart/seller/widgets/registration_app_bar.dart';
import 'package:abc_e_mart/seller/widgets/registration_stepper.dart';
import 'package:abc_e_mart/seller/widgets/form_text_field.dart';
import 'package:abc_e_mart/seller/widgets/bottom_action_buttons.dart';
import 'package:abc_e_mart/seller/widgets/logo_instruction_page.dart';
import 'package:abc_e_mart/seller/widgets/shop_registration_success_page.dart';

class ShopInfoFormPage extends StatefulWidget {
  const ShopInfoFormPage({super.key});

  @override
  State<ShopInfoFormPage> createState() => _ShopInfoFormPageState();
}

class _ShopInfoFormPageState extends State<ShopInfoFormPage> {
  File? _logoFile;
  final _formKey = GlobalKey<FormState>();
  bool _isPicking = false; // <- untuk cegah double tap

  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  bool get _allFieldsFilled {
    return _logoFile != null &&
        _namaTokoController.text.trim().isNotEmpty &&
        _deskripsiController.text.trim().isNotEmpty &&
        _alamatController.text.trim().isNotEmpty &&
        _hpController.text.trim().isNotEmpty;
  }

  Future<void> _pickLogo() async {
    if (_isPicking) return; // <-- cegah double tap
    setState(() => _isPicking = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _logoFile = File(picked.path));
      }
    } catch (e) {
      // Optional: tampilkan error jika diperlukan
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Gagal mengakses gallery')),
      // );
    } finally {
      setState(() => _isPicking = false);
    }
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(79),
        child: RegistrationAppBar(title: "Informasi Toko"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: stepperPadding),
              child: const RegistrationStepper(currentStep: 1),
            ),
            const SizedBox(height: 32),

            // Card upload logo dengan garis putus-putus
            Container(
              width: double.infinity,
              color: const Color(0xFFF2F2F3),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 26),
                  GestureDetector(
                    onTap: _isPicking ? null : _pickLogo,
                    child: DottedBorder(
                      color: const Color(0xFFD1D5DB),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10),
                      dashPattern: [6, 3],
                      strokeWidth: 1.2,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _logoFile == null
                            ? Center(
                                child: _isPicking
                                    ? const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor: AlwaysStoppedAnimation(Color(0xFFBDBDBD)),
                                        ),
                                      )
                                    : Icon(
                                        Icons.add,
                                        color: const Color(0xFFBDBDBD),
                                        size: 34,
                                      ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _logoFile!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Label dan Button Instruksi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LogoInstructionPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 28,
                            margin: const EdgeInsets.only(top: 0),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9A9A9A).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Instruksi",
                                  style: GoogleFonts.dmSans(
                                    color: const Color(0xFF373E3C),
                                    fontSize: 13,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Color(0xFF373E3C),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            // Teks instruksi bawah logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Text(
                "Unggah logo resmi toko Anda. Pastikan logo jelas, tidak buram, dan tidak mengandung unsur yang melanggar kebijakan.",
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF373E3C),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ===== Form Fields Section =====
            FormTextField(
              label: "Nama Toko",
              requiredMark: true,
              maxLength: 30,
              controller: _namaTokoController,
              hintText: "Masukkan",
              onChanged: (v) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 20),
            FormTextField(
              label: "Deskripsi Singkat Toko",
              requiredMark: true,
              maxLength: 100,
              controller: _deskripsiController,
              hintText: "Masukkan",
              onChanged: (v) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 20),
            FormTextField(
              label: "Alamat Lengkap Toko",
              requiredMark: true,
              maxLength: 200,
              controller: _alamatController,
              hintText: "Masukkan",
              onChanged: (v) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 20),
            FormTextField(
              label: "Nomor HP",
              requiredMark: true,
              maxLength: 15,
              controller: _hpController,
              keyboardType: TextInputType.phone,
              hintText: "Masukkan",
              onChanged: (v) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                // Bisa tambahkan validasi nomor HP di sini jika mau
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Info bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "*Isi detail toko Anda dengan lengkap dan sesuai. Informasi ini akan digunakan untuk verifikasi dan memudahkan pelanggan mengenali toko Anda",
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF9A9A9A),
                  fontSize: 12,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Button Simpan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: BottomActionButton(
                text: "Simpan",
                onPressed: _allFieldsFilled
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShopRegistrationSuccessPage(),
                            ),
                          );
                          // Simpan / Submit logic
                        }
                      }
                    : null,
                enabled: _allFieldsFilled,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
