import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/doctor/schedule/view/widgets/schedule_item.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';

class ScheduleAppointmentsList extends StatelessWidget {
  final DateTime selectedDate;
  final List<Appointment> filtered;
  final AppointmentState state;
  final String? role;

  const ScheduleAppointmentsList({
    super.key,
    required this.selectedDate,
    required this.filtered,
    required this.state,
    this.role,
  });

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Opens ChatScreen with the correct IDs for both doctor and patient sides.
  void _openChat(BuildContext context, Appointment a) {
    final isPatient = role == 'patient';

    String currentProfileId;
    String otherProfileId;
    String otherName;
    String otherRole;

    if (isPatient) {
      // Patient → doctor: read current patient profile from cubit
      final patientState = context.read<PatientProfileCubit>().state;
      currentProfileId = patientState is PatientProfileLoaded
          ? patientState.profile.id
          : a.patientProfileId;
      otherProfileId = a.staffProfileId;
      otherName = a.doctorName ?? 'Doctor';
      otherRole = 'Doctor';
    } else {
      // Doctor → patient: read doctor staff profile from cubit
      final medStaff = context.read<MedicalStaffCubit>().medicalStaffProfile;
      currentProfileId = medStaff?.id ?? a.staffProfileId;
      otherProfileId = a.patientProfileId;
      otherName = a.patientName ?? 'Patient';
      otherRole = 'Patient';
    }

    Navigator.pushNamed(
      context,
      Routes.chatScreen,
      arguments: {
        'appointmentId': a.id,
        'currentUserId': currentProfileId,
        'otherUserId': otherProfileId,
        'otherUserName': otherName,
        'otherUserRole': otherRole,
        'otherUserAvatar': null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr = '${months[selectedDate.month - 1]} ${selectedDate.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Schedule for $dateStr', style: AppTextStyles.heading3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text('Filter',
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.tune, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Content ───────────────────────────────────────────────────────
          if (state is AppointmentLoading && filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (state is AppointmentFailure && filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Failed to load appointments: ${(state as AppointmentFailure).error}',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.critical),
                ),
              ),
            )
          else if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_available_rounded,
                      size: 48,
                      color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'No appointments scheduled',
                    style: AppTextStyles.heading3
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enjoy your free day!',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            Column(
              children: filtered.map((a) {
                final formattedTime = _formatTimeOfDay(a.appointmentTime);
                final isCompleted = a.status == AppointmentStatus.completed;
                final isConfirmed = a.status == AppointmentStatus.confirmed;
                final isPending = a.status == AppointmentStatus.pending;
                final isCancelled = a.status == AppointmentStatus.cancelled ||
                    a.status == AppointmentStatus.rejected;

                final isPatient = role == 'patient';
                final name = isPatient
                    ? (a.doctorName ?? 'Unknown Doctor')
                    : (a.patientName ?? 'Unknown Patient');
                final initials = name.isNotEmpty
                    ? name.substring(0, 1).toUpperCase()
                    : (isPatient ? 'D' : 'P');

                final typeStr = a.careType != null
                    ? '${a.careType!.value[0].toUpperCase()}${a.careType!.value.substring(1)}'
                    : 'In-person';

                // Chat is only available for active (non-cancelled, non-completed) appointments
                final canChat = !isCancelled && !isCompleted;

                return GestureDetector(
                  onTap: () {
                    // Doctor tap → appointment approval screen
                    if (role == 'doctor') {
                      Navigator.pushNamed(
                        context,
                        Routes.appointmentApproval,
                        arguments: a,
                      );
                    }
                  },
                  child: ScheduleItem(
                    time: formattedTime,
                    name: name,
                    typeProcedure:
                        '$typeStr • ${a.notes ?? 'General Check-up'}',
                    isCompleted: isCompleted,
                    isConfirmed: isConfirmed,
                    isPending: isPending,
                    isCancelled: isCancelled,
                    hasAvatar: true,
                    avatarLetter: initials,
                    // Wire the chat button — null disables it (greyed out)
                    onChatTap: canChat ? () => _openChat(context, a) : null,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
