import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abc_e_mart/data/models/category_type.dart';

class CategorySelector extends StatefulWidget {
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
    this.height = 20,
    this.gap = 10,
    this.padding,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _initKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories.length != widget.categories.length) {
      _initKeys();
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _initKeys() {
    _itemKeys = List.generate(widget.categories.length + 1, (_) => GlobalKey());
  }

  void _scrollToSelected() {
    if (_scrollController.hasClients &&
        widget.selectedIndex < _itemKeys.length) {
      final context = _itemKeys[widget.selectedIndex].currentContext;
      if (context != null) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final position = renderBox.localToGlobal(Offset.zero, ancestor: null);

        final screenWidth = MediaQuery.of(context).size.width;
        final scrollOffset = _scrollController.offset;
        final itemCenter = position.dx + size.width / 2 + scrollOffset;
        final targetScroll = itemCenter - screenWidth / 2;

        _scrollController.animateTo(
          targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 350),
          curve: Curves.ease,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + 10, // extra biar ga kepotong shadow
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: widget.padding ?? const EdgeInsets.only(left: 20, right: 20),
        itemCount: widget.categories.length + 1, // +1 for 'Semua'
        itemBuilder: (context, idx) {
          final isSelected = widget.selectedIndex == idx;
          if (idx == 0) {
            // "Semua"
            return Padding(
              key: _itemKeys[0],
              padding: EdgeInsets.only(right: widget.gap),
              child: GestureDetector(
                onTap: () => widget.onSelected(0),
                child: Container(
                  height: widget.height,
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
          final type = widget.categories[realIdx];
          return Padding(
            key: _itemKeys[idx],
            padding: EdgeInsets.only(
              right: realIdx == widget.categories.length - 1 ? 0 : widget.gap,
            ),
            child: GestureDetector(
              onTap: () => widget.onSelected(realIdx + 1), // <<---- INI YANG +1 BRO!
              child: Container(
                height: widget.height,
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
