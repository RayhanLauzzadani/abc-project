import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:abc_e_mart/seller/widgets/registration_app_bar.dart';
import 'package:abc_e_mart/seller/widgets/registration_stepper.dart';
import 'package:abc_e_mart/seller/widgets/form_text_field.dart';
import 'package:abc_e_mart/seller/widgets/bottom_action_buttons.dart';
import 'package:abc_e_mart/seller/widgets/logo_instruction_page.dart';
import 'package:abc_e_mart/seller/widgets/shop_registration_success_page.dart';

import 'package:abc_e_mart/seller/providers/seller_registration_provider.dart';

class ShopInfoFormPage extends StatefulWidget {
  const ShopInfoFormPage({super.key});

  @override
  State<ShopInfoFormPage> createState() => _ShopInfoFormPageState();
}

class _ShopInfoFormPageState extends State<ShopInfoFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPicking = false;
  bool _isSaving = false;

  late TextEditingController _namaTokoController;
  late TextEditingController _deskripsiController;
  late TextEditingController _alamatController;
  late TextEditingController _hpController;

  // Autocomplete alamat
  List<dynamic> _addressPredictions = [];
  static const String _googleApiKey = 'AIzaSyDBdLKjiFM1Hg41D4NtN295IKeR3m7S8X8';

  @override
  void initState() {
    final provider = Provider.of<SellerRegistrationProvider>(context, listen: false);
    _namaTokoController = TextEditingController(text: provider.shopName);
    _deskripsiController = TextEditingController(text: provider.shopDesc);
    _alamatController = TextEditingController(text: provider.shopAddress);
    _hpController = TextEditingController(text: provider.shopPhone);
    super.initState();
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  bool _allFieldsFilled(SellerRegistrationProvider provider) {
    return provider.logoFile != null &&
        provider.shopName.trim().isNotEmpty &&
        provider.shopDesc.trim().isNotEmpty &&
        provider.shopAddress.trim().isNotEmpty &&
        provider.shopPhone.trim().isNotEmpty;
  }

  Future<String> _uploadFileToStorage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _submitShopInfo() async {
    final provider = Provider.of<SellerRegistrationProvider>(context, listen: false);

    if (!_allFieldsFilled(provider) || provider.ktpFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dan upload KTP!')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      if (userId == null) throw 'User tidak ditemukan';

      // 1. Upload KTP file
      String ktpUrl = await _uploadFileToStorage(
        provider.ktpFile!,
        'seller_ktp/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 2. Upload logo toko
      String logoUrl = await _uploadFileToStorage(
        provider.logoFile!,
        'seller_logos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 3. Simpan ke Firestore (shopApplications)
      final shopData = {
        'owner': {
          'uid': userId,
          'nama': provider.nama,
          'nik': provider.nik,
          'bank': provider.bank,
          'rek': provider.rek,
        },
        'ktpUrl': ktpUrl,
        'logoUrl': logoUrl,
        'shopName': provider.shopName,
        'description': provider.shopDesc,
        'address': provider.shopAddress,
        'latitude': provider.shopLat,
        'longitude': provider.shopLng,
        'phone': provider.shopPhone,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('shopApplications')
          .doc(userId)
          .set(shopData);

      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'title': 'Pengajuan Toko Baru',
        'body': 'Ada pengajuan toko baru dari ${provider.nama}.',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'store_submission',
        'shopApplicationId': userId,
        'isRead': false,
        'status': 'pending',
      });

      provider.resetAll();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ShopRegistrationSuccessPage()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _deleteLogo(SellerRegistrationProvider provider) {
    provider.setLogoFile(null);
    setState(() {});
  }

  Future<void> _pickLogo(SellerRegistrationProvider provider) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        provider.setLogoFile(File(picked.path));
        setState(() {});
      }
    } catch (_) {} finally {
      setState(() => _isPicking = false);
    }
  }

  // --- Google Places Autocomplete Logic ---
  Future<void> _searchAddress(String input) async {
    if (input.isEmpty) {
      setState(() => _addressPredictions = []);
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$_googleApiKey&components=country:id',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        _addressPredictions = data['predictions'];
      });
    }
  }

  Future<void> _selectPrediction(Map prediction, SellerRegistrationProvider provider) async {
    final placeId = prediction['place_id'];
    setState(() {
      _addressPredictions = [];
    });

    // Ambil detail tempat (koordinat, alamat lengkap)
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,formatted_address&key=$_googleApiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final location = data['result']['geometry']['location'];
      final formattedAddress = data['result']['formatted_address'];
      // Update controller dan provider
      _alamatController.text = formattedAddress;
      provider.setShopAddress(formattedAddress);
      provider.setShopLatLng(location['lat'], location['lng']);
      setState(() {}); // untuk refresh field
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerRegistrationProvider>(context);

    // sinkronisasi controller <-> provider
    _namaTokoController.value = TextEditingValue(text: provider.shopName);
    _deskripsiController.value = TextEditingValue(text: provider.shopDesc);
    _alamatController.value = TextEditingValue(text: provider.shopAddress);
    _hpController.value = TextEditingValue(text: provider.shopPhone);

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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
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

              // === Upload Logo Section ===
              Container(
                width: double.infinity,
                color: const Color(0xFFF2F2F3),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 26),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: _isPicking || _isSaving ? null : () => _pickLogo(provider),
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
                              child: provider.logoFile == null
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
                                        provider.logoFile!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (provider.logoFile != null)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: _isSaving ? null : () => _deleteLogo(provider),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _isSaving
                                ? null
                                : () {
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
                                color: const Color.fromRGBO(154, 154, 154, 0.12),
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
                onChanged: (v) {
                  provider.setShopName(v);
                  setState(() {});
                },
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
                onChanged: (v) {
                  provider.setShopDesc(v);
                  setState(() {});
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ======= AUTOCOMPLETE ALAMAT =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    FormTextField(
                      label: "Alamat Lengkap Toko",
                      requiredMark: true,
                      maxLength: 200,
                      controller: _alamatController,
                      hintText: "Masukkan",
                      onChanged: (v) {
                        provider.setShopAddress(v);
                        provider.setShopLatLng(null, null); // reset lat/lng
                        _searchAddress(v);
                        setState(() {});
                      },
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                        return null;
                      },
                    ),
                    if (_alamatController.text.isNotEmpty && _addressPredictions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          maxHeight: 220,
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: _addressPredictions.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Color(0xFFF2F2F3)),
                          itemBuilder: (context, idx) {
                            final pred = _addressPredictions[idx];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: Icon(Icons.location_on_rounded, color: Color(0xFF1C55C0), size: 21),
                              title: Text(
                                pred['structured_formatting']?['main_text'] ?? pred['description'],
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                pred['description'],
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5,
                                  color: Color(0xFF9A9A9A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectPrediction(pred, provider),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // =======================================

              const SizedBox(height: 20),
              FormTextField(
                label: "Nomor HP",
                requiredMark: true,
                maxLength: 15,
                controller: _hpController,
                keyboardType: TextInputType.phone,
                hintText: "Masukkan",
                onChanged: (v) {
                  provider.setShopPhone(v);
                  setState(() {});
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 24),

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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: BottomActionButton(
                  text: _isSaving ? "Menyimpan..." : "Simpan",
                  onPressed: _allFieldsFilled(provider) && !_isSaving
                      ? () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await _submitShopInfo();
                          }
                        }
                      : null,
                  enabled: _allFieldsFilled(provider) && !_isSaving,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
