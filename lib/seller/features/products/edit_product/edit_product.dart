import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import '../add_product/variety_products.dart';
import '../../../widgets/custom_input_field.dart';
import 'package:abc_e_mart/seller/widgets/success_edit_product_dialog.dart';

class EditProductPage extends StatefulWidget {
  final String productId;

  const EditProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  File? _image;
  String? _imageUrl;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String? _name, _desc, _category;
  String _price = '';
  String _stock = '';
  String _minBuy = '1';
  List<String> _varieties = [];
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
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
    "Lainnya",
  ];

  bool _isFormattingPrice = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    final data = doc.data();
    if (data == null) return;

    setState(() {
      _imageUrl = data['imageUrl'];
      _name = data['name'];
      _desc = data['description'];
      _category = data['category'];
      _price = data['price']?.toString() ?? '';
      _stock = data['stock']?.toString() ?? '';
      _minBuy = data['minBuy']?.toString() ?? '1';
      _varieties = List<String>.from(data['varieties'] ?? []);
      _nameController.text = _name ?? "";
      _descController.text = _desc ?? "";
      _priceController.text = NumberFormat('#,###', 'id_ID').format(data['price'] ?? 0).replaceAll(',', '.');
      _stockController.text = _stock;
      _minBuyController.text = _minBuy;
    });
  }

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
      selection: TextSelection.collapsed(
        offset: formatted.replaceAll(',', '.').length,
      ),
    );
    setState(() => _price = raw);
    _isFormattingPrice = false;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      // 1. Cek ekstensi
      String ext = pickedFile.path.split('.').last.toLowerCase();
      if (!(ext == "jpg" || ext == "jpeg" || ext == "png")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format file harus JPG, JPEG, atau PNG')),
        );
        return;
      }

      // 2. Cek ukuran file
      final file = File(pickedFile.path);
      int fileSize = await file.length();
      if (fileSize > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file maksimal 2 MB')),
        );
        return;
      }

      setState(() {
        _image = file;
      });
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
      setState(() {
        _varieties = result;
      });
    }
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _imageUrl;
      if (_image != null) {
        // upload ke storage
        final ext = _image!.path.split('.').last;
        final storageRef = FirebaseStorage.instance.ref().child(
          'product_logos/${widget.productId}.$ext',
        );
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      }
      // Update data
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        "imageUrl": imageUrl ?? '',
        "name": _name,
        "description": _desc,
        "category": _category,
        "price": int.tryParse(_price) ?? 0,
        "stock": int.tryParse(_stock) ?? 0,
        "minBuy": int.tryParse(_minBuy) ?? 1,
        "varieties": _varieties,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SuccessEditProductDialog(),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context)
          ..pop() // pop dialog
          ..pop(true); // pop halaman edit, balik ke daftar, biar refresh
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
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
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2056D3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "Edit Produk",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: textColor,
                        ),
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
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: textColor,
                              ),
                              children: const [
                                TextSpan(text: "Foto Produk "),
                                TextSpan(
                                  text: "*",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Foto 1:1",
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Color(0xFF949494),
                            ),
                          ),
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
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      ),
                                    )
                                  : (_imageUrl != null && _imageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            _imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              LucideIcons.imagePlus,
                                              size: 38,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Tambah Foto",
                                              style: GoogleFonts.dmSans(
                                                fontSize: 15,
                                                color: Colors.grey[400],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )),
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
                            Text(
                              "• Rasio ukuran: 1:1 (persegi)",
                              style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              "• Format yang Didukung: JPG, PNG, JPEG",
                              style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              "• Ukuran file maksimum: 2 MB",
                              style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                color: Colors.grey[500],
                              ),
                            ),
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
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ),
                // NAMA PRODUK, DESKRIPSI, HARGA (counter kanan, border sama)
                CustomInputField(
                  label: "Nama Produk",
                  required: true,
                  maxLength: 255,
                  controller: _nameController,
                  onChanged: (v) => _name = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Nama produk wajib diisi" : null,
                  inputType: TextInputType.text,
                ),
                CustomInputField(
                  label: "Deskripsi Produk",
                  required: true,
                  maxLength: 3000,
                  minLines: 1,
                  maxLines: 8,
                  controller: _descController,
                  onChanged: (v) => _desc = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Deskripsi wajib diisi" : null,
                  inputType: TextInputType.text,
                ),
                CustomInputField(
                  label: "Harga Produk",
                  required: true,
                  controller: _priceController,
                  inputType: TextInputType.number,
                  onChanged: _onPriceChanged,
                  validator: (v) =>
                      (_price.isEmpty || int.tryParse(_price) == null)
                      ? "Harga wajib diisi"
                      : null,
                ),
                // KATEGORI
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                    hint: Row(
                      children: [
                        Icon(LucideIcons.list, color: Colors.grey[600], size: 21),
                        const SizedBox(width: 8),
                        Text(
                          "Kategori",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "*",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    isExpanded: true,
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: GoogleFonts.dmSans(fontSize: 15),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _category = val),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Pilih kategori" : null,
                  ),
                ),
                // CARD: VARIASI, STOK, MIN. PEMBELIAN
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 23),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Variasi
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.layers,
                            color: Colors.blue[800],
                            size: 21,
                          ),
                          const SizedBox(width: 11),
                          Text(
                            "Variasi",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _openVarietyPage,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _varieties.isEmpty
                                  ? "Tambah Variasi"
                                  : "${_varieties.length} Variasi",
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: const Color(0xFF2563EB),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.5),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                      ),
                      // Stok
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.box,
                            color: Colors.grey[700],
                            size: 21,
                          ),
                          const SizedBox(width: 11),
                          Text(
                            "Stok",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: textColor.withOpacity(0.95),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 64,
                            child: TextFormField(
                              controller: _stockController,
                              decoration: InputDecoration.collapsed(
                                hintText: "0",
                                hintStyle: GoogleFonts.dmSans(
                                  color: hintColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "Wajib" : null,
                              onChanged: (v) => _stock = v,
                              style: GoogleFonts.dmSans(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.5),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                      ),
                      // Min. Jumlah Pembelian
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.layers,
                            color: Colors.grey[700],
                            size: 21,
                          ),
                          const SizedBox(width: 11),
                          Text(
                            "Min. Jumlah Pembelian",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: textColor.withOpacity(0.95),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 64,
                            child: TextFormField(
                              controller: _minBuyController,
                              decoration: InputDecoration.collapsed(
                                hintText: "1",
                                hintStyle: GoogleFonts.dmSans(
                                  color: hintColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "Wajib" : null,
                              onChanged: (v) => _minBuy = v,
                              style: GoogleFonts.dmSans(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitEdit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Simpan",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
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
