import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class AllergyRow extends StatelessWidget {
  final String name, severity;
  final Color color, bg;
  final IconData icon;
  const AllergyRow(this.name, this.severity, this.color, this.bg, this.icon, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name, style: bTextStyle(13, w: FontWeight.w700)),
                  Text(severity, style: bTextStyle(12, c: C.txt2)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(20)),
              child: Text(
                severity.startsWith('Severe')
                    ? 'SEVERE'
                    : severity.startsWith('Mod')
                        ? 'MODERATE'
                        : 'MILD',
                style: lblTextStyle(c: color, s: 10),
              ),
            ),
          ],
        ),
      );
}
