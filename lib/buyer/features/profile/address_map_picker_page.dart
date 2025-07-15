import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
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

  // Autocomplete
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _placePredictions = [];
  final String googleApiKey = "AIzaSyDBdLKjiFM1Hg41D4NtN295IKeR3m7S8X8";

  final double _sheetPadding = 20;
  final double _searchBarHeight = 46;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
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
    await _updateAddressFromLatLng(currentLatLng);
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Gabungkan city/provinsi lengkap tanpa duplikat
        List<String> parts = [
          place.street ?? "",
          place.subLocality ?? "",
          place.locality ?? "",
          place.subAdministrativeArea ?? "",
          place.administrativeArea ?? "",
          place.postalCode ?? "",
          place.country ?? ""
        ];
        final uniqueParts = <String>{};
        final addressString = parts
            .where((s) => s.trim().isNotEmpty && uniqueParts.add(s.trim()))
            .join(", ");

        setState(() {
          _streetName = place.street ?? '';
          _fullAddress = addressString;
        });
      }
    } catch (e) {
      print('Gagal reverse geocoding: $e');
    }
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$googleApiKey&language=id&components=country:id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        _placePredictions = json['predictions'];
      });
    }
  }

  Future<void> _selectPlace(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey&language=id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = json['result'];
      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];
      final address = result['formatted_address'];
      final addressComponents = result['address_components'] as List<dynamic>?;

      String? street, city, province, country, postalCode;
      if (addressComponents != null) {
        for (var comp in addressComponents) {
          List types = comp['types'] as List;
          if (types.contains('route')) street = comp['long_name'];
          if (types.contains('locality')) city = comp['long_name'];
          if (types.contains('administrative_area_level_1')) province = comp['long_name'];
          if (types.contains('country')) country = comp['long_name'];
          if (types.contains('postal_code')) postalCode = comp['long_name'];
        }
      }
      street ??= result['name'] ?? '';
      List<String> detailParts = [
        street ?? "",
        city ?? "",
        province ?? "",
        postalCode ?? "",
        country ?? "",
      ];
      final uniqueParts = <String>{};
      final addressDetailString = detailParts
          .where((s) => s.trim().isNotEmpty && uniqueParts.add(s.trim()))
          .join(", ");

      setState(() {
        _selectedLocation = LatLng(lat, lng);
        _center = LatLng(lat, lng);
        _fullAddress = addressDetailString.isNotEmpty ? addressDetailString : address;
        _streetName = street;
        _searchController.text = street ?? address;
        _placePredictions = [];
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }
  }

  void _handlePickLocation() {
    if (_selectedLocation != null && _fullAddress != null) {
      if (widget.isEdit) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressDetailPage(
              fullAddress: _fullAddress,
              locationTitle: _streetName,
              latitude: _selectedLocation!.latitude,
              longitude: _selectedLocation!.longitude,
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
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Map di atas, Flexible biar ikut sisa ruang
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
            // Bottom sheet info+button, aman responsif
            SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: _sheetPadding, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                // >>>>>> Mulai scroll di sini <<<<<<
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEARCH BAR
                      SizedBox(
                        height: _searchBarHeight,
                        child: TextField(
                          focusNode: _searchFocus,
                          controller: _searchController,
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
                      ),
                      // AUTOCOMPLETE DROPDOWN
                      if (_placePredictions.isNotEmpty && _searchFocus.hasFocus)
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 142,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _placePredictions.length,
                              itemBuilder: (context, index) {
                                final item = _placePredictions[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on, color: Color(0xFF1C55C0)),
                                  title: Text(
                                    item['structured_formatting']['main_text'] ?? '',
                                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    item['description'] ?? '',
                                    style: GoogleFonts.dmSans(fontSize: 13),
                                  ),
                                  onTap: () {
                                    _selectPlace(item['place_id']);
                                    FocusScope.of(context).unfocus();
                                  },
                                );
                              },
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
