import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/auth/cubit/auth_cubit.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_card.dart';
import 'package:smart_care/features/patient/profile/view/widgets/action_row.dart';

class DangerZoneSection extends StatelessWidget {
  const DangerZoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_rounded, size: 16, color: C.txt2),
              const SizedBox(width: 8),
              Text(
                'Account Actions',
                style: bTextStyle(14, w: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ActionRow(
            Icons.download_rounded,
            'Download Health Data',
            C.blue,
            () {},
          ),
          ActionRow(
            Icons.share_rounded,
            'Share Records with Doctor',
            C.teal,
            () {},
          ),
          ActionRow(
            Icons.lock_reset_rounded,
            'Change Password',
            C.orange,
            () {},
          ),
          ActionRow(
            Icons.logout_rounded,
            'Sign Out',
            C.red,
            () {
              context.read<LogoutCubit>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
