import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class ContactRow extends StatelessWidget {
  final String name, relation, phone;
  final IconData icon;
  final Color color;
  const ContactRow(
      this.name, this.relation, this.phone, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name, style: bTextStyle(13, w: FontWeight.w700)),
                  Text(relation, style: bTextStyle(12, c: C.txt2)),
                ])),
            Row(children: [
              GestureDetector(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: C.greenLight,
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      const Icon(Icons.phone_rounded, size: 17, color: C.green),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.message_rounded, size: 17, color: color),
                ),
              ),
            ]),
          ],
        ),
      );
}
