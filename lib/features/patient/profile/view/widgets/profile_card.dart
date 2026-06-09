import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;
  final double padding;
  const ProfileCard({super.key, required this.child, this.padding = 16});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding > 0 ? EdgeInsets.all(padding) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: child,
      );
}
