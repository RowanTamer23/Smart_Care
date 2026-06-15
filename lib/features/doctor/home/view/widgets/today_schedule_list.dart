import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/doctor/home/view/widgets/appointment_item.dart';
import 'package:smart_care/features/patient/profile/data/model/lab_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodayScheduleList extends StatelessWidget {
  final List<Appointment> todayList;
  final AppointmentState state;

  const TodayScheduleList({
    super.key,
    required this.todayList,
    required this.state,
  });

  Future<void> _startVisit(BuildContext context, Appointment appointment) async {
    try {
      final supabase = Supabase.instance.client;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch patient profile
      final profileRes = await supabase
          .from('patient_profiles')
          .select()
          .eq('id', appointment.patientProfileId)
          .maybeSingle();

      if (profileRes == null) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient profile not found'), backgroundColor: AppColors.critical),
        );
        return;
      }

      final patientProfile = PatientProfile.fromMap(profileRes);

      // Fetch medical records
      final recordsRes = await supabase
          .from('medical_records')
          .select()
          .eq('patient_profile_id', appointment.patientProfileId)
          .order('record_date', ascending: false);
      final medicalRecords = (recordsRes as List).map((e) => MedicalRecord.fromMap(e)).toList();

      // Fetch labs
      final labsRes = await supabase
          .from('patient_labs')
          .select()
          .eq('patient_profile_id', appointment.patientProfileId)
          .order('created_at', ascending: false);
      final labs = (labsRes as List).map((e) => PatientLab.fromMap(e)).toList();

      Navigator.pop(context); // Close loading

      // Navigate to visit screen
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.visitScreen,
          arguments: {
            'appointment': appointment,
            'patientProfile': patientProfile,
            'medicalRecords': medicalRecords,
            'labs': labs,
          },
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load patient data: $e'), backgroundColor: AppColors.critical),
        );
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text("Today's Schedule", style: AppTextStyles.heading3),
                  ],
                ),
              ],
            ),
          ),
          if (state is AppointmentLoading && todayList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (state is AppointmentFailure && todayList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Failed to load: ${(state as AppointmentFailure).error}',
                  style: AppTextStyles.body.copyWith(color: AppColors.critical),
                ),
              ),
            )
          else if (todayList.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.event_available_rounded,
                      size: 40, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'No appointments scheduled today',
                    style: AppTextStyles.heading3
                        .copyWith(color: AppColors.textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Enjoy your free day!',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayList.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final a = todayList[index];
                final formattedTime = _formatTimeOfDay(a.appointmentTime);
                final isCompleted = a.status == AppointmentStatus.completed;
                final isConfirmed = a.status == AppointmentStatus.confirmed;
                final isPending = a.status == AppointmentStatus.pending;
                final isCancelled = a.status == AppointmentStatus.cancelled ||
                    a.status == AppointmentStatus.rejected;

                // Format care type
                final typeStr = a.careType != null
                    ? '${a.careType!.value[0].toUpperCase()}${a.careType!.value.substring(1)}'
                    : 'In-person';

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.appointmentApproval,
                      arguments: a,
                    );
                  },
                  child: AppointmentItem(
                    time: formattedTime,
                    name: a.patientName ?? 'Unknown Patient',
                    procedure: '$typeStr • ${a.notesText}',
                    showStart: isConfirmed,
                    isCompleted: isCompleted,
                    isPending: isPending,
                    isCancelled: isCancelled,
                    onStartVisit: isConfirmed ? () => _startVisit(context, a) : null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
