import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class HistoryItem extends StatelessWidget {
  final String name, year;
  final Color color;
  final String note;
  final VoidCallback? onEdit;
  const HistoryItem(this.name, this.year, this.color, this.note, {super.key, this.onEdit});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 10, top: 5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: bTextStyle(13, w: FontWeight.w600)),
                        Text(year, style: lblTextStyle(c: C.txt3)),
                      ]),
                  Text(note, style: bTextStyle(12, c: C.txt2)),
                ])),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 16, color: C.txt3),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      );
}
