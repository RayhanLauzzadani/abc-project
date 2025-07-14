import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'variety_products.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'package:abc_e_mart/seller/widgets/product_submission_status_page.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String? _name, _desc, _category;
  String _price = '';
  String _stock = '';
  String _minBuy = '1';
  List<String> _varieties = [];
  bool _isLoading = false;

  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minBuyController = TextEditingController(text: '1');

  final List<String> _categories = [
    "Merchandise",
    "Alat Tulis",
    "Perlengkapan Lab",
    "Produk Daur Ulang",
    "Produk Kesehatan",
    "Makanan",
    "Minuman",
    "Snacks",
    "Lainnya"
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _minBuyController.dispose();
    super.dispose();
  }

  bool _isFormattingPrice = false;

  void _onPriceChanged(String value) {
    if (_isFormattingPrice) return;
    _isFormattingPrice = true;

    String raw = value.replaceAll('.', '').replaceAll(',', '');
    if (raw.isEmpty) {
      setState(() => _price = '');
      _priceController.value = const TextEditingValue(text: '');
      _isFormattingPrice = false;
      return;
    }
    final num? parsed = num.tryParse(raw);
    if (parsed == null) {
      _isFormattingPrice = false;
      return;
    }
    String formatted = NumberFormat('#,###', 'id_ID').format(parsed);
    _priceController.value = TextEditingValue(
      text: formatted.replaceAll(',', '.'),
      selection: TextSelection.collapsed(offset: formatted.replaceAll(',', '.').length),
    );
    setState(() => _price = raw);
    _isFormattingPrice = false;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto produk wajib diisi!')),
      );
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw "Kamu harus login dulu!";
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final storeId = userDoc.data()?['storeId'];
      if (storeId == null || storeId.isEmpty) throw "Kamu belum punya toko!";

      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
      final storeName = storeDoc.data()?['name'] ?? '-';

      final docRef = FirebaseFirestore.instance.collection('productsApplication').doc();
      final productId = docRef.id;

      final ext = _image!.path.split('.').last;
      final storageRef = FirebaseStorage.instance.ref().child('product_logos/$productId.$ext');
      await storageRef.putFile(_image!);
      final imgUrl = await storageRef.getDownloadURL();

      await docRef.set({
        "ownerId": uid,
        "storeId": storeId,
        "storeName": storeName,
        "imageUrl": imgUrl,
        "name": _name,
        "description": _desc,
        "category": _category,
        "price": int.tryParse(_price) ?? 0,
        "stock": int.tryParse(_stock) ?? 0,
        "minBuy": int.tryParse(_minBuy) ?? 1,
        "varieties": _varieties,
        "status": "Menunggu",
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() { _isLoading = false; });
      // BUKAN POP ATAU SNACKBAR, tapi PUSH PAGE Lottie sukses
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProductSubmissionStatusPage()),
      );
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  Future<void> _openVarietyPage() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => VarietyProductsPage(varieties: List.from(_varieties)),
      ),
    );
    if (result != null) {
      setState(() { _varieties = result; });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = const Color(0xFF232323);
    Color hintColor = Colors.grey[400]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2056D3), shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "Tambah Produk",
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
                      ),
                    ],
                  ),
                ),
                // FOTO PRODUK CARD
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                              children: const [
                                TextSpan(text: "Foto Produk "),
                                TextSpan(text: "*", style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text("Foto 1:1", style: GoogleFonts.dmSans(fontSize: 13, color: Color(0xFF949494))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: InkWell(
                          onTap: _pickImage,
                          child: DottedBorder(
                            color: const Color(0xFFC7C7C7),
                            strokeWidth: 1.5,
                            dashPattern: const [6, 4],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            child: Container(
                              width: 120,
                              height: 120,
                              alignment: Alignment.center,
                              child: _image == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(LucideIcons.imagePlus, size: 38, color: Colors.grey[400]),
                                        const SizedBox(height: 4),
                                        Text("Tambah Foto", style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(_image!, fit: BoxFit.cover, width: 120, height: 120),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 3, top: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("• Rasio ukuran: 1:1 (persegi)", style: GoogleFonts.dmSans(fontSize: 11.5, color: Colors.grey[500])),
                            Text("• Format yang Didukung: JPG, PNG, JPEG", style: GoogleFonts.dmSans(fontSize: 11.5, color: Colors.grey[500])),
                            Text("• Ukuran file maksimum: 2 MB", style: GoogleFonts.dmSans(fontSize: 11.5, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // KETERANGAN
                Padding(
                  padding: const EdgeInsets.only(bottom: 14, left: 2),
                  child: Text(
                    "Foto Produk Promosi akan digunakan di halaman promosi, hasil pencarian, rekomendasi, dll.",
                    style: GoogleFonts.dmSans(fontSize: 14.5, color: const Color(0xFF555555)),
                  ),
                ),
                // NAMA PRODUK, DESKRIPSI, HARGA (counter kanan, border sama)
                CustomInputField(
                  label: "Nama Produk",
                  required: true,
                  maxLength: 255,
                  onChanged: (v) => _name = v,
                  validator: (v) => v == null || v.isEmpty ? "Nama produk wajib diisi" : null,
                  inputType: TextInputType.text,
                ),
                CustomInputField(
                  label: "Deskripsi Produk",
                  required: true,
                  maxLength: 3000,
                  minLines: 1,
                  maxLines: 8,
                  onChanged: (v) => _desc = v,
                  validator: (v) => v == null || v.isEmpty ? "Deskripsi wajib diisi" : null,
                  inputType: TextInputType.text,
                ),
                CustomInputField(
                  label: "Harga Produk",
                  required: true,
                  controller: _priceController,
                  inputType: TextInputType.number,
                  onChanged: _onPriceChanged,
                  validator: (v) => (_price.isEmpty || int.tryParse(_price) == null) ? "Harga wajib diisi" : null,
                ),
                // KATEGORI
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6, bottom: 13),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.list, color: Colors.grey[600], size: 21),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration.collapsed(
                            hintText: "",
                          ),
                          isExpanded: true,
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: GoogleFonts.dmSans(fontSize: 15)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _category = val),
                          validator: (v) => v == null || v.isEmpty ? "Pilih kategori" : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 55,
                  top: 20,
                  child: Row(
                    children: [
                      Text("Kategori", style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.grey[600])),
                      const SizedBox(width: 4),
                      const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // CARD: VARIASI, STOK, MIN. PEMBELIAN
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 23),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      // Variasi
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.layers, color: Colors.blue[800], size: 21),
                          const SizedBox(width: 11),
                          Text("Variasi", style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
                          const SizedBox(width: 4),
                          const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                            onPressed: _openVarietyPage,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _varieties.isEmpty ? "Tambah Variasi" : "${_varieties.length} Variasi",
                              style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF2563EB), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.5),
                        child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                      ),
                      // Stok
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.box, color: Colors.grey[700], size: 21),
                          const SizedBox(width: 11),
                          Text("Stok", style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 15, color: textColor.withOpacity(0.95))),
                          const SizedBox(width: 4),
                          const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          SizedBox(
                            width: 64,
                            child: TextFormField(
                              controller: _stockController,
                              decoration: InputDecoration.collapsed(
                                hintText: "0",
                                hintStyle: GoogleFonts.dmSans(color: hintColor, fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              validator: (v) => (v == null || v.isEmpty) ? "Wajib" : null,
                              onChanged: (v) => _stock = v,
                              style: GoogleFonts.dmSans(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.5),
                        child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                      ),
                      // Min. Jumlah Pembelian
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.layers, color: Colors.grey[700], size: 21),
                          const SizedBox(width: 11),
                          Text("Min. Jumlah Pembelian", style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 15, color: textColor.withOpacity(0.95))),
                          const SizedBox(width: 4),
                          const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          SizedBox(
                            width: 64,
                            child: TextFormField(
                              controller: _minBuyController,
                              decoration: InputDecoration.collapsed(
                                hintText: "1",
                                hintStyle: GoogleFonts.dmSans(color: hintColor, fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              validator: (v) => (v == null || v.isEmpty) ? "Wajib" : null,
                              onChanged: (v) => _minBuy = v,
                              style: GoogleFonts.dmSans(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // TOMBOL SUBMIT
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text("Tambah Produk", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Input Field dengan counter kanan
class CustomInputField extends StatefulWidget {
  final String label;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextInputType inputType;
  final TextEditingController? controller;
  final bool required;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomInputField({
    required this.label,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.inputType = TextInputType.text,
    this.controller,
    this.required = false,
    this.validator,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      if (widget.maxLength != null) {
        setState(() {
          _currentLength = _controller.text.characters.length;
        });
      }
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text);
      }
    });
    if (widget.maxLength != null) {
      _currentLength = _controller.text.characters.length;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Stack(
        children: [
          TextFormField(
            controller: _controller,
            maxLength: widget.maxLength,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            keyboardType: widget.inputType,
            validator: widget.validator,
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (widget.required)
                    const SizedBox(width: 4),
                  if (widget.required)
                    const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              hintText: "Masukkan ${widget.label}",
              hintStyle: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[400]),
              counterText: "",
            ),
            onChanged: null, // handled by controller listener
          ),
          if (widget.maxLength != null)
            Positioned(
              right: 14,
              bottom: 8,
              child: Text(
                "${_currentLength}/${widget.maxLength}",
                style: GoogleFonts.dmSans(fontSize: 13.5, color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }
}
