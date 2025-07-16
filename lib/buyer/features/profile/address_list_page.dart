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
  late String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  // Fungsi untuk set address jadi utama
  Future<void> setAsPrimary(String addressId) async {
    if (userId == null) return;
    await AddressService().setPrimaryAddress(userId!, addressId);
  }

  // Callback saat tambah address baru, langsung jadikan utama jika belum ada address
  Future<void> onAddAddress(Map<String, dynamic> result, int addressCount) async {
    if (userId == null) return;
    final isFirst = addressCount == 0;
    // Setelah ambil lokasi, lanjut ke detail pengisian alamat (dari AddressDetailPage)
    final detailResult = await Navigator.push(
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
    if (detailResult != null && detailResult is AddressModel) {
      // Tambah ke Firestore
      await AddressService().addAddress(userId!, detailResult, setAsPrimary: isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              stream: AddressService().getAddresses(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final addresses = snapshot.data ?? [];
                String? primaryId;
                if (addresses.isNotEmpty) {
                  primaryId = addresses.firstWhere(
                    (a) => a.isPrimary,
                    orElse: () => addresses.first,
                  ).id;
                }

                if (addresses.isEmpty) {
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
                                color: const Color(0xFF828282),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tambah alamat untuk memudahkan pengiriman pesananmu.',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: const Color(0xFFBDBDBD),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddressMapPickerPage(),
                                  ),
                                );
                                if (result != null && mounted) {
                                  await onAddAddress(result, 0);
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
                                      color: const Color(0xFF9A9A9A),
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

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    const SizedBox(height: 10),
                    ...addresses.map((address) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAddressCard(
                            address: address,
                            isPrimary: address.isPrimary,
                            isPrimaryVisual: address.id == primaryId,
                            onEdit: () async {
                              final detailResult = await Navigator.push(
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
                                    isPrimary: address.isPrimary,
                                  ),
                                ),
                              );
                              // Jika hasil edit ingin dijadikan utama
                              if (detailResult != null &&
                                  detailResult is AddressModel &&
                                  detailResult.isPrimary &&
                                  !address.isPrimary) {
                                await setAsPrimary(address.id);
                              }
                            },
                            onSetPrimary: address.id == primaryId
                                ? null
                                : () async {
                                    await setAsPrimary(address.id);
                                  },
                          ),
                        )),
                    if (addresses.length < 3) ...[
                      const SizedBox(height: 28),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddressMapPickerPage(),
                              ),
                            );
                            if (result != null && mounted) {
                              await onAddAddress(result, addresses.length);
                            }
                          },
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/plus.svg',
                                width: 32,
                                height: 32,
                                colorFilter: const ColorFilter.mode(
                                    Color(0xFF9A9A9A), BlendMode.srcIn),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambah Alamat Baru',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9A9A9A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _buildAddressCard({
    required AddressModel address,
    required bool isPrimary,
    required bool isPrimaryVisual,
    required VoidCallback onEdit,
    required VoidCallback? onSetPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPrimaryVisual ? const Color(0xFF2056D3) : const Color(0xFFE0E0E0),
          width: isPrimaryVisual ? 2 : 1,
        ),
        boxShadow: isPrimaryVisual
            ? [
                BoxShadow(
                  color: const Color(0xFF2056D3).withOpacity(0.11),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Atas: label + tombol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF373E3C),
                ),
              ),
              Row(
                children: [
                  // Jika bukan utama, tombol 'Jadikan Utama'
                  if (!isPrimaryVisual && onSetPrimary != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ElevatedButton(
                        onPressed: onSetPrimary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2056D3),
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Jadikan Utama",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  // Jika utama, badge utama
                  if (isPrimaryVisual)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2056D3).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF2056D3), size: 17),
                          const SizedBox(width: 4),
                          Text(
                            "Utama",
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2056D3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Edit button selalu kanan
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onEdit,
                    child: SvgPicture.asset(
                      'assets/icons/edit.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF9A9A9A), BlendMode.srcIn),
                    ),
                  ),
                ],
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
            address.name,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF373E3C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address.phone,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF9A9A9A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address.address,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF9A9A9A),
            ),
          ),
        ],
      ),
    );
  }
}
