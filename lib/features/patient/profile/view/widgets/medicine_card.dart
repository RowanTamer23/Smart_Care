import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/med_detail.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final ({
    String dose,
    String freq,
    IconData icon,
    Color color,
    Color bg,
    String desc,
    String refill,
    String times
  }) data;
  final bool active;
  final ValueChanged<bool> onToggle;
  const MedicineCard(
      {super.key, required this.name,
      required this.data,
      required this.active,
      required this.onToggle});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: active ? data.color.withOpacity(0.25) : C.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: data.bg, borderRadius: BorderRadius.circular(13)),
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: bTextStyle(14, w: FontWeight.w700)),
                    Text(data.desc, style: bTextStyle(12, c: C.txt2)),
                  ],
                )),
                Switch(
                  value: active,
                  onChanged: onToggle,
                  activeColor: data.color,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: C.border, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MedDetail(Icons.medication_rounded, data.dose, C.txt2),
                MedDetail(Icons.repeat_rounded, data.freq, C.txt2),
                MedDetail(Icons.access_time_rounded, data.times, data.color),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: data.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.inventory_2_rounded,
                        size: 13, color: data.color),
                    const SizedBox(width: 5),
                    Text('Refill: ${data.refill}',
                        style: lblTextStyle(c: data.color, s: 11)),
                  ]),
                  GestureDetector(
                    child: Text('Request Refill →',
                        style: lblTextStyle(c: data.color, s: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
