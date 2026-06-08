import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class PatientsHeader extends StatelessWidget {
  const PatientsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Records', style: AppTextStyles.heading1),
        ],
      ),
    );
  }
}
