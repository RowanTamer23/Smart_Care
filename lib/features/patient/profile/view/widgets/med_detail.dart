import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class MedDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const MedDetail(this.icon, this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: bTextStyle(11, c: color, w: FontWeight.w500)),
        ],
      );
}
