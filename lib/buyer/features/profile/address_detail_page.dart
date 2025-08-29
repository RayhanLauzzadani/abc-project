import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:abc_e_mart/buyer/data/models/address.dart';
import 'package:abc_e_mart/buyer/data/services/address_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';
import 'package:abc_e_mart/buyer/widgets/address_success_dialog.dart';
// import 'package:abc_e_mart/buyer/features/profile/address_list_page.dart';
import 'package:abc_e_mart/buyer/features/profile/address_map_picker_page.dart';

class AddressDetailPage extends StatefulWidget {
  final String? fullAddress;
  final String? label;
  final String? name;
  final String? phone;
  final String? locationTitle;
  final double? latitude;
  final double? longitude;
  final String? addressId;
  final bool isEdit;
  final bool isPrimary;

  const AddressDetailPage({
    super.key,
    this.fullAddress,
    this.label,
    this.name,
    this.phone,
    this.locationTitle,
    this.latitude,
    this.longitude,
    this.addressId,
    this.isEdit = false,
    this.isPrimary = false,
  });

  @override
  State<AddressDetailPage> createState() => _AddressDetailPageState();
}

class _AddressDetailPageState extends State<AddressDetailPage> {
  late TextEditingController _labelController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  // Variabel lokal agar bisa diubah setelah balik dari picker
  late String? _fullAddress;
  late String? _locationTitle;
  late double? _latitude;
  late double? _longitude;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.label ?? '');
    _nameController = TextEditingController(text: widget.name ?? '');
    _phoneController = TextEditingController(text: widget.phone ?? '');
    _fullAddress = widget.fullAddress;
    _locationTitle = widget.locationTitle;
    _latitude = widget.latitude;
    _longitude = widget.longitude;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  OutlineInputBorder getInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    );
  }

  Widget buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9A9A9A),
        ),
      ),
    );
  }

  Widget buildMapPreview(LatLng markerLatLng) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AbsorbPointer(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: markerLatLng,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: markerLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            tiltGesturesEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            mapToolbarEnabled: false,
            liteModeEnabled: true,
          ),
        ),
      ),
    );
  }

  Future<void> saveAddress() async {
    // Validasi field
    if (_labelController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _fullAddress == null ||
        _fullAddress!.isEmpty ||
        _locationTitle == null ||
        _latitude == null ||
        _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data sebelum menyimpan.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kamu belum login!')));
        setState(() => _isLoading = false);
        return;
      }

      final address = AddressModel(
        id: widget.isEdit && widget.addressId != null
            ? widget.addressId!
            : const Uuid().v4(),
        label: _labelController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _fullAddress!,
        locationTitle: _locationTitle!,
        latitude: _latitude!,
        longitude: _longitude!,
        createdAt: DateTime.now(),
        isPrimary: widget.isEdit ? widget.isPrimary : false,
      );

      if (widget.isEdit && widget.addressId != null) {
        // UPDATE di sini
        await AddressService().updateAddress(
          userId,
          widget.addressId!,
          address,
        );
      } else {
        // CREATE: popup sukses muncul di halaman ini, setelah OK baru balik ke list
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const SuccessDialog(
              message: "Alamat berhasil disimpan",
              lottiePath: "assets/lottie/success_check.json",
              lottieSize: 100,
              buttonText: "OK",
            ),
          );
        }
        if (mounted) {
          Navigator.pop(context, address); // kirim AddressModel ke AddressList
        } else {
          // CREATE: JANGAN tulis ke DB di sini — kembalikan ke AddressList
          if (mounted) Navigator.pop(context, address);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? markerLatLng = (_latitude != null && _longitude != null)
        ? LatLng(_latitude!, _longitude!)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProfileAppBar(title: 'Detail Alamat'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD: Lokasi & Map Preview
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SvgPicture.asset(
                            'assets/icons/location.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF9A9A9A),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _locationTitle ?? "-",
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF373E3C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _fullAddress ?? "-",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: const Color(0xFF9A9A9A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddressMapPickerPage(
                                    addressId: widget.addressId,
                                    isEdit: widget.isEdit,
                                    label: _labelController.text,
                                    name: _nameController.text,
                                    phone: _phoneController.text,
                                  ),
                                ),
                              );
                              if (result != null && mounted) {
                                setState(() {
                                  _fullAddress = result['fullAddress'];
                                  _locationTitle = result['locationTitle'];
                                  _latitude = result['latitude'];
                                  _longitude = result['longitude'];
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C55C0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Ubah',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (markerLatLng != null) buildMapPreview(markerLatLng),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FIELD: Alamat Lengkap
            buildFieldLabel('Alamat Lengkap'),
            TextField(
              controller: TextEditingController(text: _fullAddress ?? ""),
              enabled: false,
              maxLines: 2,
              readOnly: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: getInputBorder(),
                enabledBorder: getInputBorder(),
                disabledBorder: getInputBorder(),
                focusedBorder: getInputBorder(),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 16),

            // FIELD: Label Alamat
            buildFieldLabel('Label Alamat'),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: getInputBorder(),
                enabledBorder: getInputBorder(),
                disabledBorder: getInputBorder(),
                focusedBorder: getInputBorder(),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 16),

            // FIELD: Nama Penerima
            buildFieldLabel('Nama Penerima'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: getInputBorder(),
                enabledBorder: getInputBorder(),
                disabledBorder: getInputBorder(),
                focusedBorder: getInputBorder(),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 16),

            // FIELD: Nomor HP
            buildFieldLabel('Nomor HP'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: getInputBorder(),
                enabledBorder: getInputBorder(),
                disabledBorder: getInputBorder(),
                focusedBorder: getInputBorder(),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF373E3C),
              ),
            ),
            const SizedBox(height: 32),

            // BUTTON: Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C55C0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.3,
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
