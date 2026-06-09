import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_card.dart';
import 'package:smart_care/features/patient/profile/view/widgets/quick_info.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_divider.dart';

class PatientQuickCard extends StatelessWidget {
  final PatientProfile profile;

  const PatientQuickCard({super.key, required this.profile});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not Provided';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuickInfo(
                Icons.cake_rounded,
                'Date of Birth',
                _formatDate(profile.dateOfBirth),
              ),
              const ProfileDivider(),
              QuickInfo(
                Icons.water_drop_rounded,
                'Blood Type',
                profile.bloodType?.value ?? 'N/A',
              ),
              const ProfileDivider(),
              const QuickInfo(
                Icons.smoke_free_rounded,
                'Smoker',
                'Non-smoker',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
