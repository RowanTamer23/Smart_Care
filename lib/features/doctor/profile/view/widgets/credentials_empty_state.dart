import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class CredentialsEmptyState extends StatelessWidget {
  const CredentialsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('No Credentials Yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Add your practice licenses, university diplomas, or board certificates to complete your doctor profile verification.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
