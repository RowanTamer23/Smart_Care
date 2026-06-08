import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class AppointmentItem extends StatelessWidget {
  final String time;
  final String name;
  final String procedure;
  final bool showStart;
  final bool isCompleted;
  final bool isPending;
  final bool isCancelled;

  const AppointmentItem({
    super.key,
    required this.time,
    required this.name,
    required this.procedure,
    required this.showStart,
    required this.isCompleted,
    required this.isPending,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(procedure, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (showStart)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Start\nVisit',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.stableLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 12, color: AppColors.stable),
                  const SizedBox(width: 4),
                  Text('Completed',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.stable)),
                ],
              ),
            ),
          if (isPending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.followUpLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_empty_rounded,
                      size: 12, color: AppColors.followUp),
                  const SizedBox(width: 4),
                  Text('Pending',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.followUp)),
                ],
              ),
            ),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.criticalLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_outlined,
                      size: 12, color: AppColors.critical),
                  const SizedBox(width: 4),
                  Text('Cancelled',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.critical)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
