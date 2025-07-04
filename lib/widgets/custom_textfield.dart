import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String iconPath;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Color colorPlaceholder;
  final Color colorInput;
  final ValueChanged<String>? onChanged;

  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final FocusNode? nextFocusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.iconPath,
    required this.colorPlaceholder,
    required this.colorInput,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.nextFocusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode? _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      _internalFocusNode!.addListener(() => setState(() {}));
    } else {
      widget.focusNode!.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    if (_internalFocusNode != null) {
      _internalFocusNode!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      onSubmitted: (_) {
        if (widget.nextFocusNode != null) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        } else {
          _focusNode.unfocus();
        }
      },
      style: GoogleFonts.dmSans(
        fontSize: 16,
        color: widget.controller.text.isEmpty
            ? widget.colorPlaceholder
            : widget.colorInput,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w500,
          color: widget.colorPlaceholder,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(widget.iconPath, width: 20, height: 20),
        ),
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onChanged: (text) {
        setState(() {});
        if (widget.onChanged != null) widget.onChanged!(text);
      },
    );
  }
}
