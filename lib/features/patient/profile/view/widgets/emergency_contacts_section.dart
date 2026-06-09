import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_card.dart';
import 'package:smart_care/features/patient/profile/view/widgets/section_header.dart';
import 'package:smart_care/features/patient/profile/view/widgets/contact_row.dart';

class EmergencyContactsSection extends StatelessWidget {
  final PatientProfile profile;

  const EmergencyContactsSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile.emergencyContactName == null &&
        profile.emergencyContact == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Emergency Contacts',
          icon: Icons.emergency_rounded,
          color: C.red,
        ),
        const SizedBox(height: 12),
        ProfileCard(
          padding: 0,
          child: ContactRow(
            profile.emergencyContactName ?? 'Unknown Contact',
            'Emergency Relation',
            profile.emergencyContact ?? 'No phone number provided',
            Icons.favorite_rounded,
            C.red,
          ),
        ),
      ],
    );
  }
}
