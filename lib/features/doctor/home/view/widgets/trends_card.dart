import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/home/view/widgets/trends_bar.dart';

class TrendsCard extends StatelessWidget {
  const TrendsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          Text('Trends This Week', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                TrendsBar(height: 0.5),
                TrendsBar(height: 0.6),
                TrendsBar(height: 0.45),
                TrendsBar(height: 0.7),
                TrendsBar(height: 0.55),
                TrendsBar(height: 0.65),
                TrendsBar(height: 1.0, isActive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
