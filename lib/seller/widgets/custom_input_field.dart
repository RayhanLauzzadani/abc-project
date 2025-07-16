import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextInputType inputType;
  final TextEditingController? controller;
  final bool required;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomInputField({
    required this.label,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.inputType = TextInputType.text,
    this.controller,
    this.required = false,
    this.initialValue,
    this.validator,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(() {
      if (widget.maxLength != null) {
        setState(() {
          _currentLength = _controller.text.characters.length;
        });
      }
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text);
      }
    });
    if (widget.maxLength != null) {
      _currentLength = _controller.text.characters.length;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Stack(
        children: [
          TextFormField(
            controller: _controller,
            maxLength: widget.maxLength,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            keyboardType: widget.inputType,
            validator: widget.validator,
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (widget.required) const SizedBox(width: 4),
                  if (widget.required)
                    const Text(
                      "*",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              hintText: "Masukkan ${widget.label}",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 15,
                color: Colors.grey[400],
              ),
              counterText: "",
            ),
            onChanged: null, // handled by controller listener
          ),
          if (widget.maxLength != null)
            Positioned(
              right: 14,
              bottom: 8,
              child: Text(
                "${_currentLength}/${widget.maxLength}",
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }
}