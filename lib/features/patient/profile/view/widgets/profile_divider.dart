import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class ProfileDivider extends StatelessWidget {
  const ProfileDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 44, color: C.border);
}
