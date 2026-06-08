import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/home/view/widgets/stat_card.dart';

class HomeStatsRow extends StatelessWidget {
  final int uniquePatients;
  final int pendingCount;

  const HomeStatsRow({
    super.key,
    required this.uniquePatients,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: "TODAY'S PATIENTS",
                value: uniquePatients.toString().padLeft(2, '0'),
                icon: Icons.people_rounded,
                iconBg: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'PENDING REQUESTS',
                value: pendingCount.toString().padLeft(2, '0'),
                showBar: true,
                icon: Icons.pending_actions_rounded,
                iconBg: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
