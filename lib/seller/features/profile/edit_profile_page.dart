import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePageSeller extends StatefulWidget {
  final String storeId;
  final String logoPath; // ini url logo, bukan asset
  const EditProfilePageSeller({
    super.key,
    required this.storeId,
    required this.logoPath,
  });

  @override
  State<EditProfilePageSeller> createState() => _EditProfilePageSellerState();
}

class _EditProfilePageSellerState extends State<EditProfilePageSeller> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _originalName = "";
  String _originalDesc = "";
  String _originalAddress = "";
  String _originalPhone = "";
  String? _logoUrl;

  bool _hasChanged = false;
  bool _loading = false;
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _listenChanges();
  }

  /// Ambil data toko dari Firestore
  Future<void> _fetchData() async {
    setState(() => _loading = true);

    try {
      final storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .get();
      final data = storeDoc.data();

      _originalName = data?['name'] ?? "-";
      _originalDesc = data?['description'] ?? "";
      _originalAddress = data?['address'] ?? "";
      _originalPhone = data?['phone'] ?? "";
      _logoUrl = data?['logoUrl'] ?? widget.logoPath;

      _nameController.text = _originalName;
      _descController.text = _originalDesc;
      _addressController.text = _originalAddress;
      _phoneController.text = _originalPhone;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _firstLoad = false;
          _loading = false;
        });
      }
    }
  }

  void _listenChanges() {
    _nameController.addListener(_detectChange);
    _descController.addListener(_detectChange);
    _addressController.addListener(_detectChange);
    _phoneController.addListener(_detectChange);
  }

  void _detectChange() {
    final isChanged =
        _nameController.text != _originalName ||
        _descController.text != _originalDesc ||
        _addressController.text != _originalAddress ||
        _phoneController.text != _originalPhone;

    if (_hasChanged != isChanged) {
      setState(() {
        _hasChanged = isChanged;
      });
    }
  }

  Future<bool> _showConfirmSaveDialog() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _CustomConfirmDialog(
        icon: Icons.edit,
        iconColor: Colors.blue,
        title: "Simpan Perubahan?",
        subtitle: "Apakah anda yakin ingin menyimpan perubahan profil?",
        cancelText: "Tidak",
        confirmText: "Iya",
        confirmColor: Colors.blue,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CustomSuccessDialog(
        icon: Icons.check_circle,
        iconColor: Colors.blue,
        title: "Berhasil!",
        subtitle: "Perubahan profil berhasil disimpan.",
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Save/update data toko by storeId
  Future<void> _saveProfile() async {
    if (!_hasChanged) return;
    final confirmed = await _showConfirmSaveDialog();
    if (!confirmed) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .update({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      _originalName = _nameController.text;
      _originalDesc = _descController.text;
      _originalAddress = _addressController.text;
      _originalPhone = _phoneController.text;
      _hasChanged = false;

      await _showSuccessDialog();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan profil: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _firstLoad
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            "Edit Profil",
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2056D3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Logo toko
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: ClipOval(
                              child: _logoUrl != null && _logoUrl!.isNotEmpty
                                  ? Image.network(_logoUrl!, fit: BoxFit.cover)
                                  : Image.asset('assets/your_default_logo.png', fit: BoxFit.cover),
                            ),
                          ),
                          // Kalau mau implement ganti logo, tinggal tambahkan logic upload di sini.
                          Positioned(
                            bottom: -12,
                            right: -12,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                              ),
                              child: const Icon(Icons.edit, size: 20, color: Color(0xFF232323)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Box input
                    _EditProfileBox(
                      controller: _nameController,
                      icon: Icons.store_rounded,
                      labelText: "Nama Toko",
                    ),
                    const SizedBox(height: 16),
                    _EditProfileBox(
                      controller: _descController,
                      icon: Icons.notes_rounded,
                      labelText: "Deskripsi Toko",
                    ),
                    const SizedBox(height: 16),
                    _EditProfileBox(
                      controller: _addressController,
                      icon: Icons.location_on_rounded,
                      labelText: "Alamat Toko",
                    ),
                    const SizedBox(height: 16),
                    _EditProfileBox(
                      controller: _phoneController,
                      icon: Icons.phone_rounded,
                      labelText: "Nomor Telepon",
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (!_hasChanged || _loading) ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasChanged ? const Color(0xFF2056D3) : const Color(0xFFB5B5B5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.3))
                            : Text(
                                "Simpan Perubahan",
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _EditProfileBox extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String labelText;
  final TextInputType? keyboardType;

  const _EditProfileBox({
    required this.controller,
    required this.icon,
    required this.labelText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E3E3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(icon, size: 22, color: const Color(0xFF9B9B9B)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelText,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF232323)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------
// Custom Pop Up
// -----------------
class _CustomConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _CustomConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.cancelText,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: iconColor.withOpacity(0.12),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF8D8D8D))),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF232323),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Text(cancelText, style: const TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(confirmText,
                        style: const TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CustomSuccessDialog extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Duration duration;

  const _CustomSuccessDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.duration,
  });

  @override
  State<_CustomSuccessDialog> createState() => _CustomSuccessDialogState();
}

class _CustomSuccessDialogState extends State<_CustomSuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: widget.iconColor.withOpacity(0.13),
              child: Icon(widget.icon, color: widget.iconColor, size: 34),
            ),
            const SizedBox(height: 16),
            Text(widget.title,
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 6),
            Text(widget.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF8D8D8D))),
          ],
        ),
      ),
    );
  }
}
