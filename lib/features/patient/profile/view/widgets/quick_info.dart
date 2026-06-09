import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class QuickInfo extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const QuickInfo(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 18, color: C.teal),
          const SizedBox(height: 5),
          Text(label, style: lblTextStyle(c: C.txt3, s: 10)),
          const SizedBox(height: 3),
          Text(value,
              style: bTextStyle(12, w: FontWeight.w700), textAlign: TextAlign.center),
        ],
      );
}
