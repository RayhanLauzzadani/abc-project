import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/data/models/category_type.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryType> categories;
  final int selectedIndex;
  final void Function(int) onSelected;
  final double height;
  final double gap;
  final EdgeInsetsGeometry? padding;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 30,
    this.gap = 10,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 10, // extra biar ga kepotong shadow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.only(left: 20, right: 20),
        itemCount: categories.length + 1, // +1 for 'Semua'
        itemBuilder: (context, idx) {
          // "Semua"
          if (idx == 0) {
            final isSelected = selectedIndex == 0;
            return Padding(
              padding: EdgeInsets.only(right: gap),
              child: GestureDetector(
                onTap: () => onSelected(0),
                child: Container(
                  height: height,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2066CF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2066CF) : const Color(0xFF9A9A9A),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Semua',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
                    ),
                  ),
                ),
              ),
            );
          }

          final realIdx = idx - 1;
          final type = categories[realIdx];
          final isSelected = selectedIndex == (realIdx + 1);
          return Padding(
            padding: EdgeInsets.only(
              right: realIdx == categories.length - 1 ? 0 : gap,
            ),
            child: GestureDetector(
              onTap: () => onSelected(realIdx + 1),
              child: Container(
                height: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2066CF) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2066CF) : const Color(0xFF9A9A9A),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  categoryLabels[type]!,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
