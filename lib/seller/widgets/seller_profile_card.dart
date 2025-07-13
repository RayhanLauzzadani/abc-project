import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerProfileCard extends StatelessWidget {
  final String storeName;
  final String description;
  final String address;
  final String logoPath;
  final VoidCallback? onEditProfile;

  const SellerProfileCard({
    super.key,
    required this.storeName,
    required this.description,
    required this.address,
    required this.logoPath,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profil Toko",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: onEditProfile,
                child: Text(
                  "Edit Profil",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Color(0xFF777777),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // CARD
          SizedBox(
            width: width - 40, // Adjust padding width
            height: 160,
            child: Stack(
              children: [
                // BACKGROUND CARD WITH BORDER
                Container(
                  width: width - 40,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2), // Background color
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF9A9A9A),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // LOGO
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 20),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEDEDED),
                          ),
                          child: ClipOval(
                            child: Image.asset(logoPath, fit: BoxFit.cover),
                          ),
                        ),
                        // INFO
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storeName,
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ICONS (Manually positioned)
                Positioned(
                  left: 10,
                  top: 10,
                  child: SvgPicture.asset(
                    'assets/icons/box.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  left: 300,
                  top: 50,
                  child: SvgPicture.asset(
                    'assets/icons/box.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  left: 70,
                  top: 5,
                  child: SvgPicture.asset(
                    'assets/icons/money.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  left: 250,
                  top: 5,
                  child: SvgPicture.asset(
                    'assets/icons/money.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  left: 130,
                  top: 10,
                  child: SvgPicture.asset(
                    'assets/icons/store.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  left: 180,
                  top: 15,
                  child: SvgPicture.asset(
                    'assets/icons/store.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: SvgPicture.asset(
                    'assets/icons/star.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: SvgPicture.asset(
                    'assets/icons/chat.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  right: 150,
                  bottom: 10,
                  child: SvgPicture.asset(
                    'assets/icons/chat.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  right: 190,
                  bottom: 20,
                  child: SvgPicture.asset(
                    'assets/icons/star.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  right: 250,
                  bottom: 5,
                  child: SvgPicture.asset(
                    'assets/icons/box.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  right: 80,
                  bottom: 25,
                  child: SvgPicture.asset(
                    'assets/icons/store.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 10,
                  child: SvgPicture.asset(
                    'assets/icons/money.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2056D3),
                      BlendMode.srcIn,
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
