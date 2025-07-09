import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure you have this package and the SVG asset

class AddressMapPickerPage extends StatefulWidget {
  const AddressMapPickerPage({super.key});

  @override
  State<AddressMapPickerPage> createState() => _AddressMapPickerPageState();
}

class _AddressMapPickerPageState extends State<AddressMapPickerPage> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(-7.2575, 112.7521); // Default center (Surabaya)
  LatLng? _selectedLocation; // Stores the currently selected location on the map

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Request location permission and get current position on init
  }

  /// Determines the current position of the device.
  /// Requests location permission if not granted.
  /// Updates the map center and selected location to the current position.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue.
      // You might want to show a dialog to the user here.
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could ask for permissions again
        // (this is also where the user might see the dialog for the first time).
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Request high accuracy for better results
    );

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _selectedLocation = _center; // Set selected location to current position
    });

    // Animate camera to the current location if map controller is available
    _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context), // Navigate back on tap
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF1C55C0), // Blue background for back button
                shape: BoxShape.circle,
              ),
              child: Center(
                // Ensure 'assets/icons/back.svg' exists in your project
                child: SvgPicture.asset(
                  'assets/icons/back.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), // Apply white color to SVG
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Titik Lokasi', // Page title
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF373E3C),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 16, // Initial zoom level
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Ensure camera animates to current location if it was determined before map creation
                    if (_selectedLocation != null) {
                      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
                    }
                  },
                  // Update _selectedLocation as the camera moves
                  onCameraMove: (position) {
                    setState(() {
                      _selectedLocation = position.target;
                    });
                  },
                  myLocationEnabled: true, // Show user's current location dot
                  myLocationButtonEnabled: false, // Hide default location button
                ),
                Center(
                  // Pin icon centered on the map to indicate selected location
                  // Ensure 'assets/icons/pin.svg' exists in your project
                  child: SvgPicture.asset(
                    'assets/icons/pin.svg',
                    width: 40,
                    height: 40,
                  ),
                ),
                Positioned(
                  bottom: 135, // Position above the bottom container
                  right: 20,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C55C0), // Blue button
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _determinePosition, // Recenter map to current location
                    icon: const Icon(Icons.my_location, size: 18, color: Colors.white),
                    label: Text(
                      'Gunakan Lokasi Saat Ini', // Button text
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
          // Bottom container for address details and selection button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9A9A9A)),
                    hintText: 'Cari lokasi', // Search input hint
                    hintStyle: GoogleFonts.dmSans(color: const Color(0xFF9A9A9A)),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Color(0xFF1C55C0)),
                    const SizedBox(width: 6),
                    // Displaying selected location's latitude and longitude
                    Text(
                      _selectedLocation != null
                          ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}'
                          : 'Loading...',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Displaying selected location's longitude
                Text(
                  _selectedLocation != null
                      ? 'Long: ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                      : 'Loading...',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
                // TODO: Implement reverse geocoding here to get actual address from LatLng
                // Example: You would use a geocoding package (e.g., geocoding) to convert
                // _selectedLocation to a human-readable address.
                // Text(
                //   'Kec. Pabean Cantikan, Kota SBY, Jawa Timur', // Placeholder for actual address
                //   style: GoogleFonts.dmSans(
                //     fontSize: 14,
                //     color: const Color(0xFF9A9A9A),
                //   ),
                // ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF9A9A9A)),
                    const SizedBox(width: 6),
                    Text(
                      'Lengkapi alamat kamu di halaman selanjutnya', // Info text
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action when "Pilih Lokasi Ini" button is pressed
                      // You would typically pass _selectedLocation back to the previous screen
                      // Navigator.pop(context, _selectedLocation);
                      print('Selected Location: $_selectedLocation');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C55C0), // Blue button
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Pilih Lokasi Ini', // Button text
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
