import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class InfoPill extends StatelessWidget {
  final String label;
  final String value;
  const InfoPill({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.body
                .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
