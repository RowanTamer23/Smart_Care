import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/schedule/view/widgets/nav_arrow.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime selectedDate;
  final String? role;
  final VoidCallback onPreviousWeek;
  final VoidCallback onToday;
  final VoidCallback onNextWeek;

  const CalendarHeader({
    super.key,
    required this.selectedDate,
    this.role,
    required this.onPreviousWeek,
    required this.onToday,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthName = months[selectedDate.month - 1];
    final yearName = selectedDate.year.toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(monthName, style: AppTextStyles.heading1),
              Text(yearName,
                  style: AppTextStyles.heading2
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          Row(
            children: [
              NavArrow(
                icon: Icons.chevron_left,
                onTap: onPreviousWeek,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToday,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('Today',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              NavArrow(
                icon: Icons.chevron_right,
                onTap: onNextWeek,
              ),
              if (role == 'doctor') ...[
                const SizedBox(width: 8),
                NavArrow(
                  icon: Icons.calendar_month_rounded,
                  onTap: () {
                    final staffProfile =
                        context.read<MedicalStaffCubit>().medicalStaffProfile;
                    if (staffProfile != null) {
                      Navigator.pushNamed(
                        context,
                        Routes.availabilitySettings,
                        arguments: staffProfile.id,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Loading doctor profile, please wait...'),
                          backgroundColor: AppColors.primaryLight,
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
