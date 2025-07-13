import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePageSeller extends StatelessWidget {
  final String logoPath;
  const EditProfilePageSeller({super.key, required this.logoPath});

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController(text: "Nihon Mart");
    final _descController = TextEditingController(text: "Menjual segala kebutuhan mahasiswa");
    final _addressController = TextEditingController(text: "Jl. Ika Hiu No 24, Surabaya");
    final _phoneController = TextEditingController(text: "089562104933");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              // Logo
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
                        child: Image.asset(logoPath, fit: BoxFit.cover),
                      ),
                    ),
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
              _EditProfileBox(
                controller: _addressController,
                icon: Icons.location_on_rounded,
                labelText: "Alamat Toko",
              ),
              const SizedBox(height: 16),
              _EditProfileBox(
                controller: _phoneController,
                icon: Icons.phone_rounded,
                labelText: "Nomor Telepon",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              // Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diubah (dummy)')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2056D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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

  const _EditProfileBox({
    required this.controller,
    required this.icon,
    required this.labelText,
    this.keyboardType,
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
