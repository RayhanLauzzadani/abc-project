import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationStepper extends StatelessWidget {
  final int currentStep; // 0 = Verifikasi Data Diri, 1 = Informasi Toko

  const RegistrationStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1C55C0);
    const gray = Color(0xFFDFE4EA);
    const double columnWidth = 120;

    return SizedBox(
      height: 78,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Jarak dari tengah step 1 ke tengah step 2
          double lineStart = columnWidth / 2;
          double lineEnd = constraints.maxWidth - columnWidth / 2;

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // Garis tengah
              Positioned(
                top: 11,
                left: lineStart,
                right: constraints.maxWidth - lineEnd,
                child: Container(
                  height: 3,
                  color: currentStep > 0 ? blue : gray,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: columnWidth,
                    child: Column(
                      children: [
                        _StepCircle(
                          active: currentStep >= 0,
                          done: currentStep > 0,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Verifikasi Data Diri",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: Column(
                      children: [
                        _StepCircle(
                          active: currentStep >= 1,
                          done: false,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Informasi Toko",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF373E3C),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool active;
  final bool done;

  const _StepCircle({required this.active, this.done = false});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1C55C0);
    const gray = Color(0xFFE4E8EE);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: done ? blue : (active ? Colors.white : gray),
        border: Border.all(
          color: blue,
          width: 2,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          if (active)
            BoxShadow(
              color: blue.withOpacity(0.16),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: done
              ? Icon(Icons.check, color: Colors.white, size: 20, key: ValueKey('check'))
              : active
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: blue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox(width: 16, height: 16),
        ),
      ),
    );
  }
}
