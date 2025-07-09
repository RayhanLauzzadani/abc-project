import 'package:abc_e_mart/buyer/features/profile/address_map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SizedBox(height: 10),
          _buildAddressCard(
            label: 'Rumah',
            name: 'Ahmad Nabil',
            phone: '+62 895 6210 49433',
            address: 'Jl. Johor, Kec. Pabean Cantikan, Kota SBY, Jawa Timur',
            onEdit: () {},
          ),
          const SizedBox(height: 16),
          _buildAddressCard(
            label: 'Kantor',
            name: 'Rayhan Lauzzadani',
            phone: '+62 888 1234 5678',
            address:
                'Kemang, Sudirman Central Business District, Jakarta, Indonesia',
            onEdit: () {},
          ),
          const SizedBox(height: 28),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
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
          ),
        ],
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
