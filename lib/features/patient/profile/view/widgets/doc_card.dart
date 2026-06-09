import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class DocCard extends StatelessWidget {
  final IconData icon;
  final String name, date;
  final Color color, bg;
  const DocCard(this.icon, this.name, this.date, this.color, this.bg, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(name, style: bTextStyle(13, w: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(date, style: lblTextStyle(c: C.txt3)),
            const SizedBox(height: 10),
            Row(children: [
              GestureDetector(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.download_rounded, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text('PDF', style: lblTextStyle(c: color, s: 11)),
                  ]),
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz_rounded, size: 18, color: C.txt3),
            ]),
          ],
        ),
      );
}
