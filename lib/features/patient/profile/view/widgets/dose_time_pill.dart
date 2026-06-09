import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class DoseTimePill extends StatelessWidget {
  final String time, status;
  final bool taken;
  const DoseTimePill(this.time, this.status, this.taken, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              taken ? C.green.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: taken
                  ? C.green.withOpacity(0.4)
                  : Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(
                taken
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: taken ? C.green : Colors.white54),
            const SizedBox(height: 5),
            Text(time, style: bTextStyle(11, c: Colors.white, w: FontWeight.w600)),
            Text(status,
                style: lblTextStyle(c: taken ? C.green : Colors.white54, s: 9)),
          ],
        ),
      );
}
