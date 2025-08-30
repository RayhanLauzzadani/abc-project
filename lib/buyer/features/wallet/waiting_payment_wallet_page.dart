import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:abc_e_mart/buyer/features/wallet/success_top_up_page.dart';
import 'package:abc_e_mart/data/services/payment_application_service.dart';

class WaitingPaymentWalletPage extends StatefulWidget {
  final int amount;        // total dibayar (topup + fee + tax)
  final String orderId;
  final String methodLabel;
  final String qrisAssetPath;
  final Duration countdown;

  // NEW: breakdown
  final int serviceFee;
  final int tax;

  // kalau null, dihitung dari amount - (fee+tax)
  final int? topUpAmount;

  const WaitingPaymentWalletPage({
    super.key,
    required this.amount,
    required this.orderId,
    required this.methodLabel,
    required this.qrisAssetPath,
    this.countdown = const Duration(minutes: 8),
    required this.serviceFee,
    required this.tax,
    this.topUpAmount,
  });

  @override
  State<WaitingPaymentWalletPage> createState() =>
      _WaitingPaymentWalletPageState();
}

class _WaitingPaymentWalletPageState extends State<WaitingPaymentWalletPage> {
  late Duration _remaining;
  Timer? _timer;
  bool _showHowTo = true;
  int get _totalSeconds => _remaining.inSeconds;

  String get _timeText =>
      _totalSeconds >= 60 ? '$_mm:$_ss' : _totalSeconds.toString();

  String get _timeUnit => _totalSeconds >= 60 ? 'Menit' : 'Detik';

  final ImagePicker _picker = ImagePicker();
  XFile? _proof;

  int get _isiSaldo =>
      widget.topUpAmount ?? (widget.amount - widget.serviceFee - widget.tax);

  // flag agar sheet timeout tidak tampil berkali-kali
  bool _expiredDialogShown = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.countdown;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining -= const Duration(seconds: 1));
      } else {
        t.cancel();
        if (!_expiredDialogShown) {
          _expiredDialogShown = true;
          _showExpiredSheet();
        }
      }
    });
  }

  Future<void> _showExpiredSheet() async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: 18 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E9EF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Icon(Icons.timer_off_rounded,
                  size: 42, color: Color(0xFF1C55C0)),
              const SizedBox(height: 10),
              Text('Waktu Pembayaran Habis',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                'Sesi pembayaran kamu telah berakhir. Silakan ulangi proses pembayaran.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 14.5, color: Color(0xFF5B5F62), height: 1.45),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Kembali',
                          style:
                              GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _remaining = widget.countdown;
                          _expiredDialogShown = false;
                        });
                        _startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C55C0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text('Ulangi',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[s.length - 1 - i]);
      if ((i + 1) % 3 == 0 && i != s.length - 1) buf.write('.');
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String get _mm =>
      _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
  String get _ss =>
      _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

  Future<void> _pickProof() async {
    try {
      final XFile? x =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (x == null) return;

      final ext = x.name.split('.').last.toLowerCase();
      const allowed = ['jpg', 'jpeg', 'png'];
      if (!allowed.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Format tidak didukung. Gunakan JPG, JPEG, atau PNG.',
              style: GoogleFonts.dmSans()),
        ));
        return;
      }

      final size = await x.length();
      if (size > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Ukuran file maksimal 2 MB.', style: GoogleFonts.dmSans()),
        ));
        return;
      }

      setState(() => _proof = x);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memilih gambar: $e', style: GoogleFonts.dmSans()),
      ));
    }
  }

  void _removeProof() => setState(() => _proof = null);

  Future<void> _saveQrisToGallery() async {
    try {
      final bytes = await rootBundle.load(widget.qrisAssetPath);
      final name =
          'QRIS_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}';

      dynamic result = await ImageGallerySaverPlus.saveImage(
        bytes.buffer.asUint8List(),
        quality: 100,
        name: name,
      );
      bool ok = _saveResultOk(result);

      if (!ok && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isPermanentlyDenied) {
          await _showOpenSettingsDialog(
              title: 'Izin Dibutuhkan',
              message:
                  'Aktifkan izin Penyimpanan agar bisa menyimpan QR ke galeri.');
          return;
        }
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Izin penyimpanan dibutuhkan untuk mengunduh.',
                style: GoogleFonts.dmSans()),
          ));
          return;
        }
        result = await ImageGallerySaverPlus.saveImage(
          bytes.buffer.asUint8List(),
          quality: 100,
          name: name,
        );
        ok = _saveResultOk(result);
      } else if (!ok && Platform.isIOS) {
        final st = await Permission.photosAddOnly.request();
        if (st.isPermanentlyDenied) {
          await _showOpenSettingsDialog(
              title: 'Akses Foto Dibutuhkan',
              message:
                  'Aktifkan akses Foto (Add Only) agar bisa menyimpan QR ke Galeri.');
          return;
        }
        if (!st.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Izin Foto dibutuhkan untuk menyimpan.',
                style: GoogleFonts.dmSans()),
          ));
          return;
        }
        result = await ImageGallerySaverPlus.saveImage(
          bytes.buffer.asUint8List(),
          quality: 100,
          name: name,
        );
        ok = _saveResultOk(result);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            ok ? 'QR berhasil disimpan ke galeri.' : 'Gagal menyimpan QR.',
            style: GoogleFonts.dmSans()),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menyimpan: $e', style: GoogleFonts.dmSans()),
      ));
    }
  }

  bool _saveResultOk(dynamic result) {
    if (result is Map) {
      final isSuccess =
          result['isSuccess'] == true || result['isSuccess'] == 'true';
      final filePath =
          result['filePath'] ?? result['fileUri'] ?? result['savedFilePath'];
      return isSuccess || (filePath != null && filePath.toString().isNotEmpty);
    }
    return result != null;
  }

  Future<void> _showOpenSettingsDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text(message, style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Buka Pengaturan',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<T?> _withLoading<T>(Future<T> Function() block) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      return await block();
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _submitTopUp() async {
    if (_proof == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unggah bukti pembayaran terlebih dahulu.',
            style: GoogleFonts.dmSans()),
      ));
      return;
    }

    if (_remaining.inSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sesi pembayaran telah berakhir. Ulangi pembayaran.',
            style: GoogleFonts.dmSans()),
      ));
      return;
    }

    try {
      await _withLoading(() async {
        final proof = await PaymentApplicationService.instance.uploadProof(
          file: File(_proof!.path),
          filenameHint:
              'topup_${widget.orderId}.${_proof!.name.split('.').last}',
        );

        await PaymentApplicationService.instance.createTopUpApplication(
          orderId: widget.orderId,
          amountTopUp: _isiSaldo,
          serviceFee: widget.serviceFee, // NEW
          tax: widget.tax,               // NEW
          totalPaid: widget.amount,
          methodLabel: widget.methodLabel,
          proof: proof,
        );
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessTopUpPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Gagal mengirim pengajuan: $e', style: GoogleFonts.dmSans()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.09),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.only(bottom: 13, top: 13, left: 16),
          child: SafeArea(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Menunggu Pembayaran',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        color: const Color(0xFF232323))),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Center(
              child: Text(
                'Selesaikan pembayaran dengan\nQRIS sebelum waktu habis',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF373E3C)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Text(_timeText,
                    style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                        letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(_timeUnit,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2563EB))),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Rincian Top Up
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rincian Top Up',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: const Color(0xFF373E3C))),
                        const SizedBox(height: 2),
                        Text(_formatRupiah(widget.amount),
                            style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C55C0))),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      builder: (_) => _OrderDetailSheetWallet(
                        isiSaldo: _isiSaldo,
                        serviceFee: widget.serviceFee,
                        tax: widget.tax,
                        total: widget.amount,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Text('Detail',
                          style: GoogleFonts.dmSans(
                              color: const Color(0xFF1C55C0),
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kartu QR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E5E5)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 2),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(widget.qrisAssetPath,
                        height: 280, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 7),
                      const Text('Powered by ',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF232323))),
                      Image.asset('assets/images/qris.png', height: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: _saveQrisToGallery,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Unduh QR'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      foregroundColor: const Color(0xFF1C55C0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Cara Pembayaran
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: _Accordion(
              title: 'Cara pembayaran QRIS',
              expanded: _showHowTo,
              onToggle: () => setState(() => _showHowTo = !_showHowTo),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Bullet('1. Buka aplikasi pembayaran berlogo QRIS yang telah dipilih.'),
                    SizedBox(height: 8),
                    _Bullet('2. Pindai / unggah gambar QR di atas, cek nominal, lalu tekan Bayar.'),
                    SizedBox(height: 8),
                    _Bullet('3. Masukkan PIN Anda untuk konfirmasi.'),
                    SizedBox(height: 8),
                    _Bullet('4. Setelah sukses, kembali ke halaman ini.'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bukti Pembayaran
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Bukti Pembayaran ',
                          style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF232323))),
                      Text('*',
                          style: GoogleFonts.dmSans(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _DashedBorder(
                    radius: 14,
                    color: const Color(0xFFBFC7DA),
                    strokeWidth: 2.0,
                    dashWidth: 7,
                    dashGap: 5,
                    child: GestureDetector(
                      onTap: _proof == null ? _pickProof : null,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFDFDFD),
                            borderRadius: BorderRadius.circular(14)),
                        child: _proof == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add,
                                        size: 24, color: Color(0xFF6B7280)),
                                    const SizedBox(height: 6),
                                    Text('Tambah Foto',
                                        style: GoogleFonts.dmSans(
                                            color: const Color(0xFF6B7280),
                                            fontSize: 14.5)),
                                  ],
                                ),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(File(_proof!.path),
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Row(
                                      children: [
                                        _IconAction(
                                            icon: Icons.delete_rounded,
                                            onTap: _removeProof,
                                            tooltip: 'Hapus'),
                                        const SizedBox(width: 8),
                                        _IconAction(
                                            icon: Icons.swap_horiz_rounded,
                                            onTap: _pickProof,
                                            tooltip: 'Ganti'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Format yang Didukung: JPG, PNG, JPEG\n• Ukuran file maksimum: 2 MB',
                    style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        color: const Color(0xFF6B7280),
                        height: 1.45),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, -2)),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C55C0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: Text('Saya sudah bayar',
                  style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Bottom sheet: ringkasan top up =====
class _OrderDetailSheetWallet extends StatelessWidget {
  final int isiSaldo;
  final int serviceFee;
  final int tax;
  final int total;

  const _OrderDetailSheetWallet({
    required this.isiSaldo,
    required this.serviceFee,
    required this.tax,
    required this.total,
  });

  String _rp(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[s.length - 1 - i]);
      if ((i + 1) % 3 == 0 && i != s.length - 1) buf.write('.');
    }
    return 'Rp${buf.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: 18 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE6E9EF),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Detail Top Up',
              style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 14),

          _MiniCardRow(label: 'Jumlah Isi Saldo', value: _rp(isiSaldo)),
          const SizedBox(height: 8),
          _MiniCardRow(label: 'Biaya Layanan', value: _rp(serviceFee)),
          const SizedBox(height: 8),
          _MiniCardRow(label: 'Pajak (1%)', value: _rp(tax)),
          const SizedBox(height: 8),
          _MiniCardRow(label: 'Total', value: _rp(total), boldValue: true),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C55C0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('OK',
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCardRow extends StatelessWidget {
  final String label;
  final String value;
  final bool boldValue;
  const _MiniCardRow(
      {required this.label, required this.value, this.boldValue = false});

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.dmSans(
        fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF373E3C));
    final valueStyle = GoogleFonts.dmSans(
        fontSize: 13.5,
        fontWeight: boldValue ? FontWeight.w800 : FontWeight.w600,
        color: const Color(0xFF232323));
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E9EF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(label,
                  style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _Accordion extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  const _Accordion(
      {required this.title,
      required this.expanded,
      required this.onToggle,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE0E0E0))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 7, 10),
            child: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child:
                        const Icon(Icons.keyboard_arrow_up_rounded, size: 32),
                  ),
                ),
              ],
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: expanded
                    ? const BoxConstraints()
                    : const BoxConstraints(maxHeight: 0.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 15),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Util kecil
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.dmSans(
            fontSize: 15, color: const Color(0xFF373E3C), height: 1.5),
      );
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _IconAction(
      {required this.icon, required this.onTap, required this.tooltip});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.45),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: Colors.white, size: 18)),
        ),
      ),
    );
  }
}

class _DashedBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Color color;
  const _DashedBorder({
    required this.child,
    required this.radius,
    this.strokeWidth = 2.0,
    this.dashWidth = 7,
    this.dashGap = 5,
    this.color = const Color(0xFFBFC7DA),
  });
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
          radius: radius,
          color: color,
          strokeWidth: strokeWidth,
          dashWidth: dashWidth,
          dashGap: dashGap),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final double radius, strokeWidth, dashWidth, dashGap;
  final Color color;
  _DashedRRectPainter(
      {required this.radius,
      required this.color,
      required this.strokeWidth,
      required this.dashWidth,
      required this.dashGap});
  @override
  void paint(Canvas canvas, Size size) {
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(rrect);
    final dashed = _dashPath(path, dashWidth: dashWidth, dashGap: dashGap);
    canvas.drawPath(dashed, paint);
  }

  Path _dashPath(Path source, {required double dashWidth, required double dashGap}) {
    final Path dest = Path();
    for (final m in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < m.length) {
        final double start = distance;
        final double end =
            (distance + dashWidth) > m.length ? m.length : (distance + dashWidth);
        dest.addPath(m.extractPath(start, end), Offset.zero);
        distance += dashWidth + dashGap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashGap != dashGap ||
      old.dashWidth != dashWidth;
}
