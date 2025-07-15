import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EditProfilePageSeller extends StatefulWidget {
  final String storeId;
  final String logoPath;
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

  // Google Places Autocomplete
  List<dynamic> _addressPredictions = [];
  static const String _googleApiKey = 'AIzaSyDBdLKjiFM1Hg41D4NtN295IKeR3m7S8X8'; // Ganti dengan API key-mu!
  double? _shopLat;
  double? _shopLng;

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
      _shopLat = data?['latitude'] != null ? (data?['latitude'] as num).toDouble() : null;
      _shopLng = data?['longitude'] != null ? (data?['longitude'] as num).toDouble() : null;

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

  // ================= AUTOCOMPLETE LOGIC ===================
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

  Future<void> _selectPrediction(Map prediction) async {
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
      // Update field controller dan lat lng
      _addressController.text = formattedAddress;
      _shopLat = location['lat'];
      _shopLng = location['lng'];
      setState(() {});
      _detectChange();
    }
  }
  // =======================================================

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
        'latitude': _shopLat,
        'longitude': _shopLng,
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
                          // Kalau mau implement ganti logo, tambahkan logic upload di sini.
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
                    // -------- AUTOCOMPLETE FIELD --------
                    Column(
                      children: [
                        _EditProfileBox(
                          controller: _addressController,
                          icon: Icons.location_on_rounded,
                          labelText: "Alamat Toko",
                          onChanged: (v) {
                            _shopLat = null;
                            _shopLng = null;
                            _searchAddress(v);
                            _detectChange();
                          },
                        ),
                        if (_addressController.text.isNotEmpty && _addressPredictions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 0, left: 4, right: 4, bottom: 10),
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
                                  onTap: () => _selectPrediction(pred),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    // -------- END AUTOCOMPLETE FIELD --------
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
  final ValueChanged<String>? onChanged;

  const _EditProfileBox({
    required this.controller,
    required this.icon,
    required this.labelText,
    this.keyboardType,
    this.onChanged,
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
                  onChanged: onChanged,
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

// ------------- Custom Dialogs -------------
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
