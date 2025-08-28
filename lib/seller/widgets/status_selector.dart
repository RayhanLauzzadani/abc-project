import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusSelector extends StatefulWidget {
  final List<String> labels;        // ['Semua','Sukses','Tertahan','Gagal']
  final int selectedIndex;          // 0 = 'Semua'
  final void Function(int) onSelected;
  final double height;
  final double gap;
  final EdgeInsetsGeometry? padding;

  const StatusSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 20,                          // << sama dengan CategorySelector
    this.gap = 10,                              // << sama
    this.padding,                               // default diset di build()
  });

  @override
  State<StatusSelector> createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<StatusSelector> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.labels.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant StatusSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels.length != widget.labels.length) {
      _itemKeys = List.generate(widget.labels.length, (_) => GlobalKey());
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients || widget.selectedIndex >= _itemKeys.length) return;
    final ctx = _itemKeys[widget.selectedIndex].currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final size = box.size;
    final pos = box.localToGlobal(Offset.zero, ancestor: null);

    final screenW = MediaQuery.of(ctx).size.width;
    final offset = _scrollController.offset;
    final center = pos.dx + size.width / 2 + offset;
    final target = center - screenW / 2;

    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // tinggi list ditambah 10 biar tak kepotong shadow — sama seperti CategorySelector
    return SizedBox(
      height: widget.height + 10,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: widget.padding ?? const EdgeInsets.only(left: 20, right: 20), // << sama
        itemCount: widget.labels.length,
        itemBuilder: (context, idx) {
          final isSelected = widget.selectedIndex == idx;
          final isLast = idx == widget.labels.length - 1;

          return Padding(
            key: _itemKeys[idx],
            padding: EdgeInsets.only(right: isLast ? 0 : widget.gap),
            child: GestureDetector(
              onTap: () => widget.onSelected(idx),
              child: Container(
                height: widget.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),         // << sama
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2066CF) : Colors.white, // << sama
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2066CF) : const Color(0xFF9A9A9A),
                  ),
                  borderRadius: BorderRadius.circular(100),                   // << sama
                ),
                child: Text(
                  widget.labels[idx],
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,                              // << sama
                    fontSize: 15,                                             // << sama
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
