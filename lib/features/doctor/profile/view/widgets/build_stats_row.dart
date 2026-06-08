import 'package:flutter/material.dart';
import 'package:smart_care/features/doctor/profile/view/widgets/profile_stat.dart';

Widget buildStatsRow(
    {required String patientsCount,
    required String yearsOfExperience,
    required String isVerified}) {
  return Row(
    children: [
      Expanded(child: ProfileStat(value: patientsCount, label: 'minutes')),
      const SizedBox(width: 10),
      Expanded(
          child: ProfileStat(value: yearsOfExperience, label: 'Experience')),
      const SizedBox(width: 10),
      Expanded(child: ProfileStat(value: isVerified, label: 'Verified')),
    ],
  );
}
