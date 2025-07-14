import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';
import 'address_detail_page.dart';

class AddressMapPickerPage extends StatefulWidget {
  final String? addressId;
  final bool isEdit;
  final String? label;
  final String? name;
  final String? phone;

  const AddressMapPickerPage({
    super.key,
    this.addressId,
    this.isEdit = false,
    this.label,
    this.name,
    this.phone,
  });

  @override
  State<AddressMapPickerPage> createState() => _AddressMapPickerPageState();
}

class _AddressMapPickerPageState extends State<AddressMapPickerPage> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(-7.2575, 112.7521);
  LatLng? _selectedLocation;
  String? _streetName;
  String? _fullAddress;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
    }

    Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final currentLatLng = LatLng(position.latitude, position.longitude);

    if (!mounted) return;
    setState(() {
      _center = currentLatLng;
      _selectedLocation = currentLatLng;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
    _updateAddressFromLatLng(currentLatLng);
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _streetName = place.street ?? '';
          _fullAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
        });
      }
    } catch (e) {
      print('Gagal reverse geocoding: $e');
    }
  }

  void _handlePickLocation() {
    if (_selectedLocation != null && _fullAddress != null) {
      if (widget.isEdit) {
        // Mode EDIT: pop kembali ke detail dengan data baru
        Navigator.pop(context, {
          'fullAddress': _fullAddress,
          'locationTitle': _streetName,
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'addressId': widget.addressId,
          'isEdit': widget.isEdit,
          'label': widget.label,
          'name': widget.name,
          'phone': widget.phone,
        });
      } else {
        // Mode TAMBAH BARU: push ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressDetailPage(
              fullAddress: _fullAddress,
              locationTitle: _streetName,
              latitude: _selectedLocation!.latitude,
              longitude: _selectedLocation!.longitude,
              // label, name, phone: biar null (tambah baru)
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih lokasi terlebih dahulu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProfileAppBar(title: 'Titik Lokasi'),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _center, zoom: 16),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_selectedLocation != null) {
                      _mapController?.animateCamera(
                          CameraUpdate.newLatLng(_selectedLocation!));
                    }
                  },
                  onCameraMove: (position) {
                    _selectedLocation = position.target;
                  },
                  onCameraIdle: () {
                    if (_selectedLocation != null) {
                      _updateAddressFromLatLng(_selectedLocation!);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/pin.svg',
                    width: 40,
                    height: 40,
                    colorFilter: const ColorFilter.mode(Color(0xFFDC3545), BlendMode.srcIn),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C55C0),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _determinePosition,
                    icon: const Icon(Icons.my_location, size: 16, color: Colors.white),
                    label: Text(
                      'Gunakan Lokasi Saat Ini',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 7),
                    prefixIcon: SvgPicture.asset(
                      'assets/icons/search-icon.svg',
                      fit: BoxFit.scaleDown,
                      colorFilter: const ColorFilter.mode(Color(0xFF9A9A9A), BlendMode.srcIn),
                    ),
                    hintText: 'Cari lokasi',
                    hintStyle: GoogleFonts.dmSans(color: const Color(0xFF9A9A9A)),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/location.svg',
                      width: 18,
                      height: 18,
                      colorFilter:
                          const ColorFilter.mode(Color(0xFF9A9A9A), BlendMode.srcIn),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _streetName ?? 'Memuat...',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _fullAddress ?? '',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: Color(0xFF9A9A9A)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Lengkapi alamat kamu di halaman selanjutnya',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handlePickLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C55C0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Pilih Lokasi Ini',
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
        ],
      ),
    );
  }
}
