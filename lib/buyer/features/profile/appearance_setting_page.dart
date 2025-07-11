import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppearanceSettingPage extends StatefulWidget {
  const AppearanceSettingPage({super.key});

  @override
  State<AppearanceSettingPage> createState() => _AppearanceSettingPageState();
}

class _AppearanceSettingPageState extends State<AppearanceSettingPage> {
  int _selected = 0;

  void _onSelect(int idx) {
    if (idx == 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Oops!'),
          content: const Text('Opsi/fitur sedang dikembangkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            )
          ],
        ),
      );
      return;
    }
    setState(() => _selected = idx);
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'icon': 'tampilan.svg',
        'label': 'Device Settings',
        'iconSize': 8.0,
        'iconPadding': EdgeInsets.only(left: 3), // sedikit kekiri
      },
      {
        'icon': 'sun.svg',
        'label': 'Light Mode',
        'iconSize': 25.0,
        'iconPadding': EdgeInsets.only(left: 0, top: 1), // kekiri dikit biar rata
      },
      {
        'icon': 'moon.svg',
        'label': 'Dark Mode',
        'iconSize': 8.0,
        'iconPadding': EdgeInsets.only(left: 2), // adjust secukupnya
      },
    ];

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
                color: Color(0xFF2056D3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/back.svg',
                  width: 18,
                  height: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Tampilan',
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF212121),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: List.generate(options.length, (idx) {
                  final isSelected = _selected == idx;
                  final opt = options[idx];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _onSelect(idx),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              // Fixed icon slot, pakai padding per icon
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Padding(
                                  padding: opt['iconPadding'] as EdgeInsets,
                                  child: SvgPicture.asset(
                                    'assets/icons/${opt['icon']}',
                                    width: opt['iconSize'] as double,
                                    height: opt['iconSize'] as double,
                                    color: const Color(0xFFB4B4B4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  opt['label'] as String,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF212121),
                                  ),
                                ),
                              ),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF2056D3) : const Color(0xFFB4B4B4),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2056D3),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (idx < options.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                          indent: 12,
                          endIndent: 12,
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2056D3),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Text(
                  'Simpan',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
