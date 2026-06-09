import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

enum LabStatus { normal, borderline, low, high }

class LabRow extends StatelessWidget {
  final String test, value, range;
  final LabStatus status;
  const LabRow(this.test, this.value, this.range, this.status, {super.key});

  Color get _color => switch (status) {
        LabStatus.normal => C.green,
        LabStatus.borderline => C.amber,
        LabStatus.low => C.blue,
        LabStatus.high => C.red,
      };
  String get _label => switch (status) {
        LabStatus.normal => 'Normal',
        LabStatus.borderline => 'Borderline',
        LabStatus.low => 'Low',
        LabStatus.high => 'High',
      };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(test, style: bTextStyle(13, w: FontWeight.w700)),
                  Text('Ref: $range', style: lblTextStyle(c: C.txt3, s: 10)),
                ])),
            Text(value, style: bTextStyle(14, c: _color, w: FontWeight.w700)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_label, style: lblTextStyle(c: _color, s: 10)),
            ),
          ],
        ),
      );
}
