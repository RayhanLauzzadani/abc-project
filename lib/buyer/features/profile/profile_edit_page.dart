import 'dart:io';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _email;
  String? _storeName;
  String? _photoUrl;
  File? _pickedImage;
  bool _loading = false;
  bool _hasChanged = false;

  // Original values for change detection
  String _originalFirstName = '';
  String _originalLastName = '';
  String _originalPhone = '';
  String? _originalPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _listenChanges();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _listenChanges() {
    _firstNameController.addListener(_detectChange);
    _lastNameController.addListener(_detectChange);
    _phoneController.addListener(_detectChange);
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final fullName = (data['name'] ?? '').toString().split(' ');
      _firstNameController.text = fullName.isNotEmpty ? fullName.first : '';
      _lastNameController.text = fullName.length > 1 ? fullName.sublist(1).join(' ') : '';
      _phoneController.text = data['phone'] ?? '';
      _email = data['email'] ?? '';
      _storeName = data['storeName'] ?? '';
      _photoUrl = data['photoUrl'] ?? null;

      // Save original values
      _originalFirstName = _firstNameController.text;
      _originalLastName = _lastNameController.text;
      _originalPhone = _phoneController.text;
      _originalPhotoUrl = _photoUrl;

      setState(() {});
    }
  }

  void _detectChange() {
    final isChanged =
        _firstNameController.text != _originalFirstName ||
        _lastNameController.text != _originalLastName ||
        _phoneController.text != _originalPhone ||
        _photoUrl != _originalPhotoUrl ||
        _pickedImage != null;

    if (_hasChanged != isChanged) {
      setState(() {
        _hasChanged = isChanged;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _hasChanged = true;
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      final ref = _storage.ref().child('user_profiles/$uid.jpg');
      await ref.putFile(file, SettableMetadata(contentType: "image/jpeg"));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }

  Future<void> _deleteProfilePhoto() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _storage.ref().child('user_profiles/$uid.jpg');
    try {
      await ref.delete();
    } catch (_) {
      // ignore
    }
  }

  Future<void> _showDeletePhotoDialog() async {
    await showDialog(
      context: context,
      builder: (_) => _CustomConfirmDialog(
        icon: Icons.delete,
        iconColor: Colors.red,
        title: "Hapus Foto?",
        subtitle: "Apakah anda yakin ingin menghapus foto profil?",
        cancelText: "Batal",
        confirmText: "Hapus",
        confirmColor: Colors.red,
        onConfirm: () async {
          Navigator.pop(context);
          await _deleteProfilePhoto();
          setState(() {
            _pickedImage = null;
            _photoUrl = "";
            _hasChanged = true;
          });
        },
      ),
    );
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

  Future<void> _saveProfile() async {
    if (!_hasChanged) return;
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama depan wajib diisi.')),
      );
      return;
    }

    final confirmed = await _showConfirmSaveDialog();
    if (!confirmed) return;

    setState(() => _loading = true);
    String? newPhotoUrl = _photoUrl;
    if (_pickedImage != null) {
      newPhotoUrl = await _uploadImage(_pickedImage!);
    }
    final name = _lastNameController.text.trim().isNotEmpty
        ? "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}"
        : _firstNameController.text.trim();
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': _phoneController.text.trim(),
        'photoUrl': newPhotoUrl ?? "",
      });
      _originalFirstName = _firstNameController.text;
      _originalLastName = _lastNameController.text;
      _originalPhone = _phoneController.text;
      _originalPhotoUrl = newPhotoUrl;
      _pickedImage = null;
      _hasChanged = false;

      await _showSuccessDialog();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProfileAppBar(title: 'Edit Profil'), // <--- GANTI INI
      body: _email == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildAvatar(),
                  const SizedBox(height: 26),
                  _buildInputFloatingLabel(
                    controller: _firstNameController,
                    label: "Nama Depan",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildInputFloatingLabel(
                    controller: _lastNameController,
                    label: "Nama Belakang",
                    icon: Icons.person_2_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInputFloatingLabel(
                    controller: _phoneController,
                    label: "Nomor Telepon",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildInputFloatingLabel(
                    enabled: false,
                    label: "Email",
                    icon: Icons.email_outlined,
                    controller: TextEditingController(text: _email ?? ""),
                  ),
                  const SizedBox(height: 16),
                  _buildInputFloatingLabel(
                    enabled: false,
                    label: "Nama Toko",
                    icon: Icons.store_mall_directory_outlined,
                    controller: TextEditingController(
                        text: (_storeName?.isEmpty ?? true) ? "Tidak ada toko" : _storeName ?? "-"),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!_hasChanged || _loading) ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasChanged
                            ? const Color(0xFF1C55C0)
                            : const Color(0xFFB5B5B5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.3))
                          : Text(
                              'Simpan Perubahan',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    final double avatarRadius = 48;
    ImageProvider? imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl!);
    }
    return Stack(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Icon(Icons.person, size: 55, color: Colors.grey[500])
              : null,
        ),
        Positioned(
          right: 2,
          bottom: 4,
          child: GestureDetector(
            onTap: () async {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 15),
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: const Text('Ambil dari Kamera'),
                          onTap: () async {
                            Navigator.pop(context);
                            await _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Pilih dari Galeri'),
                          onTap: () async {
                            Navigator.pop(context);
                            await _pickImage(ImageSource.gallery);
                          },
                        ),
                        if ((_photoUrl != null && _photoUrl!.isNotEmpty) || _pickedImage != null)
                          ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Hapus Foto'),
                            onTap: () {
                              Navigator.pop(context);
                              _showDeletePhotoDialog();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 1.1),
                  borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.edit, size: 18, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  // Input dengan floating label (label di dalam box, move ke atas saat fokus/isi)
  Widget _buildInputFloatingLabel({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: (_) => _detectChange(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFB5B5B5)),
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF404040),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1C55C0), width: 1.3),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          filled: true,
          fillColor: enabled ? const Color(0xFFF5F5F5) : const Color(0xFFF3F3F3),
        ),
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: enabled ? const Color(0xFF373E3C) : const Color(0xFFB5B5B5),
        ),
      ),
    );
  }
}

// Custom dialog pop up
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

// Dialog sukses otomatis tertutup
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
