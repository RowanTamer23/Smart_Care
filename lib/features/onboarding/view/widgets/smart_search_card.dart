import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme.dart';
import 'package:smart_care/features/onboarding/view/widgets/onboarding_data.dart';

class SmartSearchCard extends StatelessWidget {
  final OnboardingData data;
  const SmartSearchCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor card preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.tealLight,
                    child:
                        Icon(Icons.person, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. Elena Ross', style: darkHeadline),
                      Text('Cardiology', style: lightTextBody),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logo watermark
            Row(
              children: [
                Icon(Icons.eco_outlined,
                    color: AppColors.primary.withOpacity(0.3), size: 28),
                Text(
                  'RK',
                  style: lightTextBody.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      color: AppColors.primary.withOpacity(0.2)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              data.headline,
              style: darkHeadline.copyWith(
                  fontSize: 22, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            Text(
              data.body,
              style: lightTextBody.copyWith(
                  fontSize: 14, color: AppColors.textMedium, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
