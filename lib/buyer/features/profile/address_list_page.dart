import 'package:abc_e_mart/buyer/data/models/address.dart';
import 'package:abc_e_mart/buyer/data/services/address_service.dart';
import 'package:abc_e_mart/buyer/features/profile/address_map_picker_page.dart';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';
import 'package:abc_e_mart/buyer/features/profile/address_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProfileAppBar(title: 'Detail Alamat'),
      body: userId == null
          ? Center(
              child: Text(
                'Kamu belum login!',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: const Color(0xFF9A9A9A),
                ),
              ),
            )
          : StreamBuilder<List<AddressModel>>(
              stream: AddressService().getAddresses(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.mapPinOff,
                              size: 96,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Belum ada alamat',
                              style: GoogleFonts.dmSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF828282),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tambah alamat untuk memudahkan pengiriman pesananmu.',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Color(0xFFBDBDBD),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () async {
                                // --- MODIFIKASI DI SINI! ---
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddressMapPickerPage(),
                                  ),
                                );
                                if (result != null && mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddressDetailPage(
                                        fullAddress: result['fullAddress'],
                                        locationTitle: result['locationTitle'],
                                        latitude: result['latitude'],
                                        longitude: result['longitude'],
                                        // untuk tambah, label/dll biarkan null
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.plusCircle,
                                    size: 32,
                                    color: const Color(0xFF9A9A9A),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tambah Alamat Baru',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9A9A9A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                final addresses = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    const SizedBox(height: 10),
                    ...addresses.map((address) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAddressCard(
                            label: address.label,
                            name: address.name,
                            phone: address.phone,
                            address: address.address,
                            locationTitle: address.locationTitle,
                            latitude: address.latitude,
                            longitude: address.longitude,
                            onEdit: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddressDetailPage(
                                    fullAddress: address.address,
                                    label: address.label,
                                    name: address.name,
                                    phone: address.phone,
                                    locationTitle: address.locationTitle,
                                    latitude: address.latitude,
                                    longitude: address.longitude,
                                    addressId: address.id,
                                    isEdit: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          // --- MODIFIKASI JUGA DI SINI! ---
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressMapPickerPage(),
                            ),
                          );
                          if (result != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressDetailPage(
                                  fullAddress: result['fullAddress'],
                                  locationTitle: result['locationTitle'],
                                  latitude: result['latitude'],
                                  longitude: result['longitude'],
                                ),
                              ),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/plus.svg',
                              width: 32,
                              height: 32,
                              color: const Color(0xFF9A9A9A),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambah Alamat Baru',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9A9A9A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildAddressCard({
    required String label,
    required String name,
    required String phone,
    required String address,
    required String locationTitle,
    required double latitude,
    required double longitude,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF373E3C),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: SvgPicture.asset(
                  'assets/icons/edit.svg',
                  width: 18,
                  height: 18,
                  color: const Color(0xFF9A9A9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF373E3C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            phone,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Color(0xFF9A9A9A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Color(0xFF9A9A9A),
            ),
          ),
        ],
      ),
    );
  }
}
