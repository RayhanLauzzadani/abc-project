import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> SuccessDeleteDialog({
  required BuildContext context,
  required String title,
  String? message,
  String? lottieAsset,
  Duration duration = const Duration(milliseconds: 1600),
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              lottieAsset ?? 'assets/lottie/success_check.json',
              width: 92,
              height: 92,
              repeat: false,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 5),
              Text(
                message,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF707070),
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    ),
  );

  await Future.delayed(duration);
  if (Navigator.canPop(context)) Navigator.of(context, rootNavigator: true).pop();
}
