import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AdminSearchBar({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46, // fixed height 46px
      width: double.infinity, // bebas, ngikut parent
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF404040),
        ),
        decoration: InputDecoration(
          hintText: "Cari yang anda inginkan....",
          hintStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF777777), // sesuai request
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: SvgPicture.asset(
              'assets/icons/search-icon.svg',
              width: 22,
              height: 22,
              color: const Color(0xFF777777), // sesuai request
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          filled: true,
          fillColor: const Color(0xFFF2F2F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        ),
      ),
    );
  }
}
