import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/section_header.dart';

class InsuranceCardSection extends StatelessWidget {
  final PatientProfile profile;

  const InsuranceCardSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final company = profile.insuranceCompany ?? 'Not Provided';
    final number = profile.insuranceNumber ?? 'Not Provided';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Insurance Information',
          icon: Icons.shield_rounded,
          color: C.blue,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: C.blue.withOpacity(0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HEALTH INSURANCE',
                        style: lblTextStyle(c: Colors.white54, s: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(company, style: hTextStyle(18, c: Colors.white)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEMBER ID',
                          style: lblTextStyle(c: Colors.white54, s: 9),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          number,
                          style: bTextStyle(14, c: Colors.white, w: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GROUP NO.',
                          style: lblTextStyle(c: Colors.white54, s: 9),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'GRP-77341',
                          style: bTextStyle(14, c: Colors.white, w: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VALID THROUGH',
                          style: lblTextStyle(c: Colors.white54, s: 9),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Dec 31, 2026',
                          style: bTextStyle(14, c: Colors.white, w: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLAN TYPE',
                          style: lblTextStyle(c: Colors.white54, s: 9),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'PPO Premium',
                          style: bTextStyle(14, c: Colors.white, w: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deductible met: \$1,200 / \$3,000',
                      style: bTextStyle(12, c: Colors.white70),
                    ),
                    Container(
                      height: 6,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: C.green,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
