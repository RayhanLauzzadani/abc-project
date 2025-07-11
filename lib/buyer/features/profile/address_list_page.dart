import 'package:abc_e_mart/buyer/data/models/address.dart';
import 'package:abc_e_mart/buyer/data/services/address_service.dart';
import 'package:abc_e_mart/buyer/features/profile/address_map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF1C55C0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/back.svg',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Detail Alamat',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF373E3C),
          ),
        ),
        centerTitle: true,
      ),
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
                // Handle jika data kosong, tampilkan tombol tambah tetap ada
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Belum ada alamat.\nTambah dulu ya!',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: const Color(0xFF9A9A9A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddressMapPickerPage(),
                                  ),
                                );
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
                            onEdit: () {
                              // TODO: Buka halaman edit alamat kalau mau (optional)
                            },
                          ),
                        )),
                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressMapPickerPage(),
                            ),
                          );
                          // Tidak perlu setState, StreamBuilder auto update
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
