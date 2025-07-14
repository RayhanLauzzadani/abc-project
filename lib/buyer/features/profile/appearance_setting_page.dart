import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/buyer/widgets/profile_app_bar.dart';

class AppearanceSettingPage extends StatefulWidget {
  const AppearanceSettingPage({super.key});

  @override
  State<AppearanceSettingPage> createState() => _AppearanceSettingPageState();
}

class _AppearanceSettingPageState extends State<AppearanceSettingPage> {
  int _selected = 0;

  final List<_AppearanceOption> options = const [
    _AppearanceOption(
      icon: 'tampilan.svg',
      label: 'Device Settings',
      iconSize: 22,
      iconPadding: EdgeInsets.only(left: 3),
      enabled: true,
    ),
    _AppearanceOption(
      icon: 'sun.svg',
      label: 'Light Mode',
      iconSize: 25,
      iconPadding: EdgeInsets.only(left: 0, top: 1),
      enabled: true,
    ),
    _AppearanceOption(
      icon: 'moon.svg',
      label: 'Dark Mode',
      iconSize: 22,
      iconPadding: EdgeInsets.only(left: 2),
      enabled: false, // set ke false jika memang under development
    ),
  ];

  void _onSelect(int idx) {
    if (!options[idx].enabled) {
      _showUnderDevelopmentDialog();
      return;
    }
    setState(() => _selected = idx);
  }

  void _showUnderDevelopmentDialog() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProfileAppBar(title: 'Tampilan'),
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
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                  indent: 12,
                  endIndent: 12,
                ),
                itemBuilder: (context, idx) {
                  final opt = options[idx];
                  final isSelected = _selected == idx;
                  return _OptionTile(
                    option: opt,
                    selected: isSelected,
                    onTap: () => _onSelect(idx),
                  );
                },
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
                onPressed: () {}, // isi onPressed dengan logic simpan jika ada
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

// Data class untuk tiap option
class _AppearanceOption {
  final String icon;
  final String label;
  final double iconSize;
  final EdgeInsets iconPadding;
  final bool enabled;
  const _AppearanceOption({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.iconPadding,
    this.enabled = true,
  });
}

// Widget untuk tiap opsi
class _OptionTile extends StatelessWidget {
  final _AppearanceOption option;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = option.enabled ? const Color(0xFFB4B4B4) : Colors.grey.shade400;
    return InkWell(
      onTap: option.enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Padding(
                padding: option.iconPadding,
                child: SvgPicture.asset(
                  'assets/icons/${option.icon}',
                  width: option.iconSize,
                  height: option.iconSize,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.label,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF212121),
                ),
              ),
            ),
            _CustomRadio(selected: selected, activeColor: const Color(0xFF2056D3)),
          ],
        ),
      ),
    );
  }
}

class _CustomRadio extends StatelessWidget {
  final bool selected;
  final Color activeColor;
  const _CustomRadio({required this.selected, required this.activeColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? activeColor : const Color(0xFFB4B4B4),
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
