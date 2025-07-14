import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import 'package:another_flushbar/flushbar.dart';
import 'custom_camera_page.dart';
import 'package:abc_e_mart/seller/widgets/ktp_instruction_page.dart';

// Tambahkan
import 'package:provider/provider.dart';
import 'package:abc_e_mart/seller/providers/seller_registration_provider.dart';

class KtpUploadSection extends StatefulWidget {
  final VoidCallback? onShowInstruction;
  final Function(String? nik, String? nama)? onKtpOcrResult;

  const KtpUploadSection({
    super.key,
    this.onShowInstruction,
    this.onKtpOcrResult,
  });

  @override
  State<KtpUploadSection> createState() => _KtpUploadSectionState();
}

class _KtpUploadSectionState extends State<KtpUploadSection> {
  bool _loading = false;

  Future<void> _pickImageCustomCamera(BuildContext context) async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      _showPermissionDialog(context);
      return;
    }

    final file = await Navigator.push<XFile>(
      context,
      MaterialPageRoute(builder: (_) => const CustomCameraPage()),
    );
    if (file == null) return;

    final pickedImage = File(file.path);

    // Simpan ke provider!
    Provider.of<SellerRegistrationProvider>(context, listen: false)
        .setKtpFile(pickedImage);

    setState(() {
      _loading = true;
    });

    // OCR KTP
    final ocrResult = await _runKtpOcr(pickedImage);

    setState(() {
      _loading = false;
    });

    if ((ocrResult['nik'] == null || ocrResult['nik']!.length < 10) ||
        (ocrResult['nama'] == null || ocrResult['nama']!.length < 3)) {
      if (mounted) {
        Flushbar(
          message:
              "Data KTP tidak terdeteksi dengan jelas. Silakan isi Nama dan NIK secara manual.",
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red.shade600,
          icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
          animationDuration: const Duration(milliseconds: 500),
          isDismissible: true,
        ).show(context);
      }
    }

    widget.onKtpOcrResult?.call(ocrResult['nik'], ocrResult['nama']);
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Izin Kamera Dibutuhkan'),
        content: const Text(
          'Silakan izinkan akses kamera agar bisa mengambil foto KTP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(ctx).pop();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String?>> _runKtpOcr(File imgFile) async {
    final inputImage = InputImage.fromFile(imgFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    String? nik;
    String? nama;
    final lines = recognizedText.text.split('\n');
    final nikRegex = RegExp(r'\b\d{16}\b');
    final isUppercase = RegExp(r'^[A-Z\s]+$');

    final blacklist = [
      'NIK',
      'NAMA',
      'TEMPAT',
      'TANGGAL LAHIR',
      'JENIS KELAMIN',
      'ALAMAT',
      'RT',
      'RW',
      'KEL',
      'DESA',
      'KECAMATAN',
      'AGAMA',
      'PAUSE',
      'SHIFT',
      'PROVINSI',
      'KOTA',
      'GOL',
      'DARAH',
      'PEKERJAAN',
      'KEWARGANEGARAAN',
      'BERLAKU',
      'HINGGA',
      'STATUS',
      'PERKAWINAN',
      'PELAMAR',
      'MAHASISWA',
      'SEUMUR',
      'HIDUP',
      'JL',
      'NO',
      'ISI',
      'LAKI-LAKI',
      'PEREMPUAN',
      'ISLAM',
      'KRISTEN',
      'KATOLIK',
      'HINDU',
      'BUDDHA',
      'KONGHUCU',
      'WNI',
      'WNA',
      'BELUM',
      'KAWIN',
      'CERAI',
      'TIDAK',
      'TETAP',
    ];

    int? nikIdx;
    for (int i = 0; i < lines.length; i++) {
      if (nik == null && nikRegex.hasMatch(lines[i])) {
        nik = nikRegex.firstMatch(lines[i])?.group(0);
        nikIdx = i;
        break;
      }
    }

    if (nikIdx != null) {
      for (int i = nikIdx + 1; i < lines.length && i <= nikIdx + 3; i++) {
        String line = lines[i].trim();
        if (isUppercase.hasMatch(line) && line.length >= 5) {
          bool isBlacklisted = blacklist.any(
            (w) => line.toUpperCase().contains(w),
          );
          if (!isBlacklisted) {
            nama = line;
            break;
          }
        }
      }
    }

    if (nama == null) {
      for (var line in lines) {
        line = line.trim();
        if (isUppercase.hasMatch(line) && line.length >= 5) {
          bool isBlacklisted = blacklist.any(
            (w) => line.toUpperCase().contains(w),
          );
          if (!isBlacklisted) {
            nama = line;
            break;
          }
        }
      }
    }

    await textRecognizer.close();
    return {'nik': nik, 'nama': nama};
  }

  void _deleteImage(BuildContext context) {
    // Clear di Provider
    Provider.of<SellerRegistrationProvider>(context, listen: false)
        .setKtpFile(null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ktpFile =
        Provider.of<SellerRegistrationProvider>(context).ktpFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CARD abu-abu
        Container(
          width: double.infinity,
          color: const Color(0xFFF2F2F3),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Foto KTP",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(
                        color: Color(0xFFFF4D4D),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 26, bottom: 10, right: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: _loading ? null : () => _pickImageCustomCamera(context),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            color: const Color(0xFFD1D5DB),
                            dashPattern: const [6, 3],
                            strokeWidth: 1.4,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ktpFile == null
                                  ? _loading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/registration/plus.svg',
                                            width: 34,
                                            height: 34,
                                            color: const Color(0xFFBDBDBD),
                                          ),
                                        )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        ktpFile,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (ktpFile != null)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _deleteImage(context),
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
                    const SizedBox(width: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: KtpCardWithInstruction(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KtpInstructionPage(),
                            ),
                          );
                        },
                        width: 100,
                        height: 62,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Pastikan seluruh KTP berada dalam bingkai foto, informasi terlihat jelas, dan tidak buram.",
            style: GoogleFonts.dmSans(
              color: const Color(0xFF373E3C),
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class KtpCardWithInstruction extends StatelessWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const KtpCardWithInstruction({
    super.key,
    this.onTap,
    this.width = 100,
    this.height = 62,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/icons/registration/ktp.png',
                width: width,
                height: height,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Row(
                children: [
                  Text(
                    "Instruksi",
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
