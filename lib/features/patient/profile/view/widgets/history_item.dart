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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12, top: 5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: bTextStyle(13, w: FontWeight.bold, c: C.txt1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(year, style: lblTextStyle(c: C.txt3, s: 11)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: bTextStyle(12, c: C.txt2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 16, color: C.txt3),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      );
}
