import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:url_launcher/url_launcher.dart';

class AddAdsPage extends StatefulWidget {
  const AddAdsPage({super.key});

  @override
  State<AddAdsPage> createState() => _AddAdsPageState();
}

class _AddAdsPageState extends State<AddAdsPage> {
  File? _bannerImage;
  File? _buktiPembayaranImage;
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _produkIklan;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int _hargaIklan = 10000;

  final List<String> _produkList = ['Produk A', 'Produk B', 'Produk C'];
  List<DateTime> _pilihanTanggalSelesai = [];

  void _updateHarga() {
    if (_tanggalMulai != null && _tanggalSelesai != null) {
      int durasi = _tanggalSelesai!.difference(_tanggalMulai!).inDays + 1;
      if (durasi < 2) durasi = 2;
      int blok = (durasi / 2).ceil();
      if (mounted) {
        setState(() {
          _hargaIklan = blok * 10000;
        });
      }
    }
  }

  void _generateTanggalSelesaiPilihan() {
    _pilihanTanggalSelesai.clear();
    if (_tanggalMulai != null) {
      for (int i = 2; i <= 14; i += 2) {
        _pilihanTanggalSelesai.add(_tanggalMulai!.add(Duration(days: i - 1)));
      }
    }
  }

  Future<void> _pickImage(bool isBanner) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);

      if (isBanner) {
        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final img = frame.image;

        if (img.width != 390 || img.height != 160) {
          if (mounted) {
            _showAlert('Ukuran Banner Tidak Sesuai', 'Ukuran banner wajib **390x160 px**');
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          if (isBanner) {
            _bannerImage = file;
          } else {
            _buktiPembayaranImage = file;
          }
        });
      }
    }
  }

  Future<void> _selectDateMulai(BuildContext context) async {
    final now = DateTime.now();
    final besok = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final initial = _tanggalMulai != null && _tanggalMulai!.isAfter(besok)
        ? _tanggalMulai!
        : besok;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: besok,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2056D3),
            onPrimary: Colors.white,
            onSurface: Color(0xFF373E3C),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Color(0xFF2056D3)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _tanggalMulai = picked;
        _generateTanggalSelesaiPilihan();
        _tanggalSelesai = null; // reset
        _updateHarga();
      });
    }
  }

  String _formatTanggal(DateTime? tgl) {
    if (tgl == null) return '';
    return DateFormat('dd/MM/yyyy').format(tgl);
  }

  int _hitungDurasi(DateTime? mulai, DateTime? selesai) {
    if (mulai == null || selesai == null) return 0;
    return selesai.difference(mulai).inDays + 1;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_tanggalMulai == null || _tanggalSelesai == null) {
        _showAlert('Tanggal belum lengkap', 'Silakan pilih tanggal mulai dan selesai.');
        return;
      }
      int durasi = _tanggalSelesai!.difference(_tanggalMulai!).inDays + 1;
      if (durasi < 2 || durasi % 2 != 0) {
        _showAlert('Durasi Tidak Valid',
            'Durasi iklan hanya boleh kelipatan 2 hari (2, 4, 6, dst).');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mengajukan iklan!')),
      );
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text(msg, style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            child: Text('OK', style: GoogleFonts.dmSans(color: Color(0xFF2056D3))),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Color palette
    const colorBorder = Color(0xFFE0E0E0);
    const colorBorderBtn = Color(0xFFD5D7DA);
    const colorGreyText = Color(0xFF9A9A9A);
    const colorBlack = Color(0xFF373E3C);
    const colorBlue = Color(0xFF2056D3);
    const colorBgBtn = Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => Padding(
                padding: const EdgeInsets.only(top: 72, bottom: 72), // Ubah jadi 72 agar lebih rapat
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Jarak lebih rapat dari AppBar ke konten
                        const SizedBox(height: 12),

                        // Info + tombol akses template
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "Klik tombol untuk mengakses template banner iklan yang disediakan",
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: colorBlack,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 115,
                              height: 30,
                              child: OutlinedButton(
                              onPressed: () async {
                                final url = Uri.parse('https://www.canva.com/design/DAGs3I1z1RE/HE4nlWhUoVfEsCBNWV5kNw/edit');
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: colorBgBtn,
                                  side: const BorderSide(
                                      color: colorBorderBtn, width: 1.2),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: const Size(115, 30),
                                ),
                                child: Text(
                                  "Akses Template",
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: colorBlack,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Banner Iklan Card
                        Center(
                          child: Container(
                            width: 392,
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth > 400 ? 392 : constraints.maxWidth,
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: colorBorder,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Row(
                                  children: [
                                    Text(
                                      "Banner Iklan",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        color: colorBlack,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(
                                      " *",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                // Dotted area
                                Center(
                                  child: DottedBorder(
                                    color: colorGreyText,
                                    dashPattern: const [4, 3],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(6),
                                    strokeWidth: 1.2,
                                    child: InkWell(
                                      onTap: () => _pickImage(true),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        width: 356,
                                        height: 146,
                                        alignment: Alignment.center,
                                        color: Colors.transparent,
                                        child: _bannerImage == null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    LucideIcons.plus,
                                                    size: 14,
                                                    color: colorGreyText,
                                                  ),
                                                  const SizedBox(height: 7),
                                                  Text(
                                                    "Tambah Foto",
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 10,
                                                      color: colorGreyText,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: Image.file(
                                                  _bannerImage!,
                                                  width: 356,
                                                  height: 146,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Format yang Didukung : JPG, PNG, JPEG",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: colorGreyText,
                                        ),
                                      ),
                                      Text(
                                        "Ukuran file maksimum: 2 MB",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: colorGreyText,
                                        ),
                                      ),
                                      Text(
                                        "Ukuran banner wajib 390px X 160px",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: colorGreyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Judul Iklan
                        _CustomInputField(
                          label: "Judul Iklan",
                          required: true,
                          maxLength: 32,
                          controller: _judulController,
                          hint: "Masukkan Judul Iklan",
                        ),
                        const SizedBox(height: 22),

                        // Deskripsi Iklan
                        _CustomInputField(
                          label: "Deskripsi Iklan",
                          required: true,
                          maxLength: 120,
                          controller: _deskripsiController,
                          hint: "Masukkan Deskripsi Iklan",
                        ),
                        const SizedBox(height: 22),

                        // Produk Iklan Dropdown
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 22),
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Produk Iklan",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: colorBlack,
                                    ),
                                  ),
                                  const Text(
                                    " *",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField2<String>(
                                value: _produkIklan,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: colorBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: colorBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: colorBlue,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                hint: Text(
                                  "Pilih Produk Anda",
                                  style: GoogleFonts.dmSans(
                                    color: colorGreyText,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  elevation: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(color: colorBorder, width: 1.2),
                                  ),
                                ),
                                items: _produkList.map((prod) {
                                  return DropdownMenuItem(
                                    value: prod,
                                    child: Row(
                                      children: [
                                        Icon(Icons.shopping_bag_outlined, color: const Color.fromARGB(255, 153, 153, 153), size: 19),
                                        const SizedBox(width: 10),
                                        Text(
                                          prod,
                                          style: GoogleFonts.dmSans(fontSize: 15, color: colorBlack),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _produkIklan = val),
                                validator: (v) => v == null ? "Produk wajib dipilih" : null,
                              ),
                            ],
                          ),
                        ),

                        // Durasi Iklan (Mulai & Selesai)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 22),
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Durasi Iklan",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: colorBlack,
                                    ),
                                  ),
                                  const Text(
                                    " *",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tanggal Mulai
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectDateMulai(context),
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              hintText: "Mulai",
                                              hintStyle: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                color: colorGreyText,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.calendar_today_outlined,
                                                size: 18,
                                                color: colorGreyText,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 10),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: const BorderSide(color: colorBorder),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: const BorderSide(color: colorBorder, width: 1.2),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: const BorderSide(color: colorBlue, width: 1.2),
                                              ),
                                            ),
                                            controller: TextEditingController(
                                              text: _formatTanggal(_tanggalMulai),
                                            ),
                                            style: GoogleFonts.dmSans(fontSize: 14, color: colorBlack),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const VerticalDivider(width: 2, thickness: 0),
                                    const SizedBox(width: 10),
                                    //tanggal selesai
                                    Expanded(
                                      child: DropdownButtonFormField2<DateTime>(
                                        value: _tanggalSelesai,
                                        isExpanded: true,
                                        hint: Text(
                                          "Selesai",
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            color: colorGreyText,
                                          ),
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: "Tanggal Selesai",
                                          hintStyle: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: colorGreyText,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE0E0E0),
                                              width: 1.2,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(22),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE0E0E0),
                                              width: 1.2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(24),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF2056D3),
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          width: 180,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5), // <--- bikin curve menu
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 16,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          elevation: 3,
                                        ),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        items: _pilihanTanggalSelesai.map((tgl) {
                                          int durasi = _hitungDurasi(_tanggalMulai, tgl);
                                          return DropdownMenuItem(
                                            value: tgl,
                                            child: Text(
                                              "${_formatTanggal(tgl)} (${durasi} hari)",
                                              style: GoogleFonts.dmSans(
                                                fontSize: 15,
                                                color: colorBlack,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        selectedItemBuilder: (context) {
                                          return _pilihanTanggalSelesai.map((tgl) {
                                            int durasi = _hitungDurasi(_tanggalMulai, tgl);
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${_formatTanggal(tgl)} (${durasi} hari)",
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 15,
                                                  color: colorBlack,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList();
                                        },
                                        onChanged: (val) {
                                          if (mounted) {
                                            setState(() {
                                              _tanggalSelesai = val;
                                              _updateHarga();
                                            });
                                          }
                                        },
                                        validator: (v) => v == null ? "Tanggal selesai wajib dipilih" : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 11),
                              Text(
                                "• Ketentuan Durasi Iklan :",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: colorGreyText,
                                ),
                              ),
                              Text(
                                "• Durasi iklan: minimal 2 hari, hanya boleh kelipatan 2 hari (2, 4, dst)",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: colorGreyText,
                                ),
                              ),
                              Text(
                                "• Iklan akan tayang paling cepat 24 jam setelah pengajuan",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: colorGreyText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Harga Iklan Box
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 22),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                          decoration: BoxDecoration(
                            color: colorBgBtn,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: colorBorder, width: 1.1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Harga Iklan (Rp 10.000/2 hari)",
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorBlue,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                        locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                                    .format(_hargaIklan),
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorBlack,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bukti Pembayaran
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 22),
                          padding: const EdgeInsets.fromLTRB(14, 13, 14, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bukti Pembayaran :",
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: colorBlack,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                "Rekening Pembayaran :",
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: colorBlack,
                                ),
                              ),
                              Text(
                                "Seabank: 901789883126",
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: colorBlack,
                                ),
                              ),
                              Text(
                                "A.n. Marchenda Claudy Aura Widodo",
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: colorBlack,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DottedBorder(
                                color: colorGreyText,
                                dashPattern: const [4, 3],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(6),
                                strokeWidth: 1.2,
                                child: InkWell(
                                  onTap: () => _pickImage(false),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: double.infinity,
                                    height: 110,
                                    alignment: Alignment.center,
                                    color: Colors.transparent,
                                    child: _buktiPembayaranImage == null
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                LucideIcons.plus,
                                                size: 14,
                                                color: colorGreyText,
                                              ),
                                              const SizedBox(height: 7),
                                              Text(
                                                "Tambah Foto",
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 10,
                                                  color: colorGreyText,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.file(
                                              _buktiPembayaranImage!,
                                              width: double.infinity,
                                              height: 110,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                "Format yang Didukung : JPG, PNG, JPEG",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: colorGreyText,
                                ),
                              ),
                              Text(
                                "Ukuran file maksimum: 2 MB",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: colorGreyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Jarak untuk sticky tombol bawah
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ===== Sticky AppBar =====
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
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
                      "Ajukan Iklan",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Color(0xFF373E3C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ===== Sticky Button Bottom =====
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2056D3),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Ajukan Iklan",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen input dengan counter di kanan, label di atas
class _CustomInputField extends StatefulWidget {
  final String label;
  final int? maxLength;
  final TextEditingController? controller;
  final String? hint;
  final bool required;

  const _CustomInputField({
    required this.label,
    this.maxLength,
    this.controller,
    this.hint,
    this.required = false,
    Key? key,
  }) : super(key: key);

  @override
  State<_CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<_CustomInputField> {
  late TextEditingController _controller;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      if (widget.maxLength != null && mounted) {
        setState(() {
          _currentLength = _controller.text.characters.length;
        });
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
    const colorHint = Color(0xFF9A9A9A);
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Stack(
        children: [
          TextFormField(
            controller: _controller,
            maxLength: widget.maxLength,
            style: GoogleFonts.dmSans(fontSize: 15, color: Color(0xFF373E3C)),
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
                      color: Color(0xFF373E3C),
                    ),
                  ),
                  if (widget.required) const SizedBox(width: 4),
                  if (widget.required)
                    const Text(
                      "*",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2056D3),
                  width: 1.2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              hintText: widget.hint,
              hintStyle: GoogleFonts.dmSans(
                fontSize: 15,
                color: colorHint,
              ),
              counterText: "",
            ),
            onChanged: (_) {},
          ),
          if (widget.maxLength != null)
            Positioned(
              right: 14,
              bottom: 8,
              child: Text(
                "${_currentLength}/${widget.maxLength}",
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  color: Color(0xFF9A9A9A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
