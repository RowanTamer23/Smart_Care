import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme.dart';
import 'package:smart_care/features/onboarding/view/widgets/onboarding_data.dart';
import 'package:smart_care/features/onboarding/view/widgets/stat_card.dart';

class EfficiencySection extends StatelessWidget {
  final OnboardingData data;
  const EfficiencySection({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(data.badge!, style: primaryBody),
          ),
          const SizedBox(height: 16),
          Text(data.headline, style: textHeadline),
          const SizedBox(height: 14),
          Text(data.body, style: lightTextBody),
          const SizedBox(height: 28),

          // Stats grid
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '3',
                  label: 'Clicks to book',
                  icon: Icons.touch_app_rounded,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: '45+',
                  label: 'Specialties',
                  icon: Icons.local_hospital_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '1.2k',
                  label: 'Practitioners',
                  icon: Icons.people_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: '0s',
                  label: 'Admin delay',
                  icon: Icons.speed_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
