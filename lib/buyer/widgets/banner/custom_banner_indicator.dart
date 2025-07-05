import 'package:flutter/material.dart';

class CustomBannerIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const CustomBannerIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFFFFC727) : Color(0xFFF2F2F3),
            borderRadius: BorderRadius.circular(3),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Color(0x26FFC727), // 15% opacity yellow
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ]
                : [],
          ),
        );
      }),
    );
  }
}
