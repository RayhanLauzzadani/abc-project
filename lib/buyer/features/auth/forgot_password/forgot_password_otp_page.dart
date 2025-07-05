import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'forgot_password_reset_page.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpPage({super.key, required this.email});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 0;

  static const colorPrimary = Color(0xFF1C55C0);
  static const colorInput = Color(0xFF404040);
  static const colorPlaceholder = Color(0xFF757575);

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 120; // 2 menit
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode OTP tidak lengkap.")),
      );
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('otp_codes')
          .doc(widget.email)
          .get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kode OTP tidak ditemukan.")),
        );
        return;
      }

      final data = snapshot.data()!;
      final correctOtp = data['otp'];
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final now = DateTime.now();

      if (now.isAfter(expiresAt)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kode OTP telah kedaluwarsa.")),
        );
        return;
      }

      if (otp != correctOtp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kode OTP salah.")),
        );
        return;
      }

      // OTP valid
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForgotPasswordResetPage(email: widget.email),
        ),
      );
    } catch (e) {
      print("Error saat verifikasi OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan saat verifikasi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: colorPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        "Silahkan periksa email Anda.",
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorInput,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtext
                      Text(
                        "Kami telah mengirimkan kode ke\n${widget.email}",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: colorPlaceholder,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // OTP Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Focus(
                                onKey: (node, event) {
                                  if (event is RawKeyDownEvent &&
                                      event.logicalKey == LogicalKeyboardKey.backspace &&
                                      _otpControllers[index].text.isEmpty &&
                                      index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                    _otpControllers[index - 1].clear();
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _otpControllers[index].text.isNotEmpty
                                            ? Colors.white
                                            : const Color(0xFFD6D6D6),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                    if (value.isNotEmpty && index < 3) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Verifikasi Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Verifikasi",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Kirim ulang kode
                      Center(
                        child: GestureDetector(
                          onTap: _secondsRemaining == 0 ? _startTimer : null,
                          child: RichText(
                            text: TextSpan(
                              text: "Kirim ulang kode",
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _secondsRemaining == 0
                                    ? colorPrimary
                                    : colorPlaceholder,
                              ),
                              children: _secondsRemaining > 0
                                  ? [
                                      TextSpan(
                                        text: " ${_formatDuration(_secondsRemaining)}",
                                        style: GoogleFonts.dmSans(
                                          color: colorPlaceholder,
                                        ),
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
