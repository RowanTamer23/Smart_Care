import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';

class ScheduleLoadCard extends StatelessWidget {
  final DateTime selectedDate;
  final List<Appointment> filtered;

  const ScheduleLoadCard({
    super.key,
    required this.selectedDate,
    required this.filtered,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;
    final label = isToday ? "Today's Load" : "Schedule Load";
    final count = filtered.length;
    final countText = count == 1 ? '1 Appointment' : '$count Appointments';

    // Count pending appointments
    final pendingCount =
        filtered.where((a) => a.status == AppointmentStatus.pending).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.body.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(countText,
                  style: AppTextStyles.heading2.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text('$pendingCount Pending Approval',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                ],
              ),
            ],
          ),
          // ElevatedButton.icon(
          //   onPressed: () {},
          //   icon: const Icon(Icons.add_circle_outline, size: 16),
          //   label: const Text('Create New\nAppointment'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColors.accent,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12)),
          //     textStyle: AppTextStyles.bodySmall
          //         .copyWith(fontWeight: FontWeight.w700, height: 1.3),
          //   ),
          // ),
        ],
      ),
    );
  }
}
