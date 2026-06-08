import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final doctor = context.watch<ProfileCubit>().doctor;
    final doctorName = doctor != null ? doctor.fullName : 'Doctor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, Dr. $doctorName',
          style: AppTextStyles.body.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Overview', style: AppTextStyles.heading1),
      ],
    );
  }
}
