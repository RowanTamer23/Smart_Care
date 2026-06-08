import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_state.dart';

class ProfileHeader extends StatefulWidget {
  final String? name;
  final String? imageUrl;
  final String? specialityId;
  const ProfileHeader({
    super.key,
    this.name,
    this.imageUrl,
    this.specialityId,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    print(widget.specialityId);
    if (widget.specialityId != null && widget.specialityId!.isNotEmpty) {
      context.read<SpecialityCubit>().getSpeciality(widget.specialityId!);
    }
    print(context.read<SpecialityCubit>().specialty?.name);
  }

  @override
  void didUpdateWidget(covariant ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.specialityId != oldWidget.specialityId &&
        widget.specialityId != null &&
        widget.specialityId!.isNotEmpty) {
      context.read<SpecialityCubit>().getSpeciality(widget.specialityId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpecialityCubit, SpecialityState>(
        listener: (context, state) {
      if (state is SpecialitySuccess) {
        print('state success : $state');
        print(context.read<SpecialityCubit>().specialty?.name);
      } else if (state is SpecialityFailure) {
        print('state failure : $state');
        print(state.message);
      }
    }, builder: (context, state) {
      final speciality = state is SpecialitySuccess
          ? state.speciality
          : context.read<SpecialityCubit>().specialty;
      final specialityName = speciality?.name;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundImage:
                  widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? NetworkImage(widget.imageUrl!)
                      : null,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: widget.imageUrl == null || widget.imageUrl!.isEmpty
                  ? const Icon(Icons.person_rounded,
                      size: 36, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name != null ? "Dr. ${widget.name}" : "",
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialityName ?? "No Data",
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Active · Smart-Care Pro',
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
