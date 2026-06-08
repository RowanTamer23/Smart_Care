import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class TrendsBar extends StatelessWidget {
  final double height;
  final bool isActive;

  const TrendsBar({
    super.key,
    required this.height,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 60 * height,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
