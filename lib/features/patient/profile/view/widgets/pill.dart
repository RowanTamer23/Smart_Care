import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class Pill extends StatelessWidget {
  final String text;
  final Color textColor, bg;
  const Pill(this.text, this.textColor, this.bg, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: lblTextStyle(c: textColor, s: 11)),
      );
}
