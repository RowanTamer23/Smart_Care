import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme.dart';
import 'package:smart_care/features/onboarding/view/widgets/onboarding_data.dart';

class DarkBookingCard extends StatelessWidget {
  final OnboardingData data;
  const DarkBookingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 20),

            Text(data.headline, style: darkHeadline),
            const SizedBox(height: 10),
            Text(data.body, style: lightTextBody),
            const SizedBox(height: 24),

            // Slot indicators
            Row(
              children: List.generate(
                4,
                (i) => AnimatedContainer(
                  duration: Duration(milliseconds: 200 + i * 80),
                  margin: const EdgeInsets.only(right: 8),
                  width: i == 2 ? 44 : 36,
                  height: 12,
                  decoration: BoxDecoration(
                    color: i == 2
                        ? AppColors.accentDark
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Trust badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.teal,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 16),
                      ),
                      Positioned(
                        left: 20,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.accent,
                          child: Icon(Icons.medical_services,
                              color: AppColors.primary, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trusted by Professionals',
                        style: lightTextBody,
                      ),
                      Text(
                        'Across 45 medical specialties',
                        style: darkTextBody,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
