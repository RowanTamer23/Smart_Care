import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class VitalsOverview extends StatelessWidget {
  final int completedToday;
  final int totalToday;

  const VitalsOverview({
    super.key,
    required this.completedToday,
    required this.totalToday,
  });

  @override
  Widget build(BuildContext context) {
    final completedText =
        '${completedToday.toString().padLeft(2, '0')}/${totalToday.toString().padLeft(2, '0')}';
    final double capacityPct =
        totalToday > 0 ? (completedToday / totalToday) : 0;
    final capacityText = '${(capacityPct * 100).toInt()}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vitals Overview', style: AppTextStyles.heading3),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety_rounded,
                      color: AppColors.tealLight, size: 20),
                  const SizedBox(width: 8),
                  Text('Clinical Capacity', style: AppTextStyles.body),
                ],
              ),
              Text(
                capacityText,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.stable, size: 20),
                  const SizedBox(width: 8),
                  Text('Completed', style: AppTextStyles.body),
                ],
              ),
              Text(
                completedText,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
