import 'package:flutter/material.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/patient/shared.dart';
import 'package:smart_care/features/patient/theme3.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_care/core/services/notification_service.dart';
import 'package:smart_care/features/patient/profile/data/model/notification_model.dart';

class PatientHomeScreen extends StatelessWidget {
  final VoidCallback? onBookPressed;
  const PatientHomeScreen({super.key, this.onBookPressed});

  String _formatAppointmentDateTime(DateTime date, TimeOfDay time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final apptDate = DateTime(date.year, date.month, date.day);

    String datePart;
    if (apptDate == today) {
      datePart = 'Today';
    } else if (apptDate == today.add(const Duration(days: 1))) {
      datePart = 'Tomorrow';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      datePart =
          '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }

    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$datePart • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final patientState = context.read<PatientProfileCubit>().state;
            if (patientState is PatientProfileLoaded) {
              final patientId = patientState.profile.id;
              await Future.wait([
                context
                    .read<AppointmentCubit>()
                    .getPatientAppointments(patientId),
                context
                    .read<PatientProfileCubit>()
                    .loadPatientProfile(patientState.profile.profileId),
              ]);
            } else {
              final currentUser = Supabase.instance.client.auth.currentUser;
              if (currentUser != null) {
                await context
                    .read<PatientProfileCubit>()
                    .loadPatientProfile(currentUser.id);
              }
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                _buildTopBar(context),
                const SizedBox(height: 20),
                _buildUpcomingCard(context),
                const SizedBox(height: 20),
                _buildTodaysAppointments(context),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildRecentRecords(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return BlocBuilder<PatientProfileCubit, PatientProfileState>(
      builder: (context, state) {
        String patientName = 'Rowan Tamer';
        if (state is PatientProfileLoaded &&
            state.profile.fullName != null &&
            state.profile.fullName!.isNotEmpty) {
          patientName = state.profile.fullName!;
        }
        return Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                image: (state is PatientProfileLoaded &&
                        state.profile.avatarUrl != null &&
                        state.profile.avatarUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(state.profile.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (state is PatientProfileLoaded &&
                      state.profile.avatarUrl != null &&
                      state.profile.avatarUrl!.isNotEmpty)
                  ? null
                  : const Icon(Icons.person_rounded,
                      color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello,',
                      style: AppText.body(13, color: AppColors.textMuted)),
                  Text(patientName, style: AppText.display(17)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, Routes.notificationScreen);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06), blurRadius: 8)
                  ],
                ),
                child: ValueListenableBuilder<List<NotificationModel>>(
                  valueListenable: NotificationService().notificationsNotifier,
                  builder: (context, notifications, _) {
                    final unreadCount = notifications
                        .where((n) =>
                            !n.isRead && n.timestamp.isBefore(DateTime.now()))
                        .length;
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_outlined,
                            color: AppColors.textPrimary, size: 22),
                        if (unreadCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                  color: AppColors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingCard(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        final appointments = context.read<AppointmentCubit>().appointments;

        Appointment? appt;

        // 1. Check if there is an active appointment where the video call is started by the doctor
        for (final a in appointments) {
          if ((a.status == AppointmentStatus.pending ||
                  a.status == AppointmentStatus.confirmed) &&
              a.videoRoomUrl != null &&
              a.videoRoomUrl!.isNotEmpty) {
            appt = a;
            break;
          }
        }

        // 2. Fall back to finding the nearest future appointment
        if (appt == null) {
          final futureAppointments = appointments.where((a) {
            final apptDateTime = DateTime(
              a.appointmentDate.year,
              a.appointmentDate.month,
              a.appointmentDate.day,
              a.appointmentTime.hour,
              a.appointmentTime.minute,
            );
            final isFuture = apptDateTime
                .isAfter(DateTime.now().subtract(const Duration(minutes: 30)));
            final isActive = a.status == AppointmentStatus.pending ||
                a.status == AppointmentStatus.confirmed;
            return isFuture && isActive;
          }).toList();

          // Sort ascending
          futureAppointments.sort((a, b) {
            final dtA = DateTime(
                a.appointmentDate.year,
                a.appointmentDate.month,
                a.appointmentDate.day,
                a.appointmentTime.hour,
                a.appointmentTime.minute);
            final dtB = DateTime(
                b.appointmentDate.year,
                b.appointmentDate.month,
                b.appointmentDate.day,
                b.appointmentTime.hour,
                b.appointmentTime.minute);
            return dtA.compareTo(dtB);
          });

          if (futureAppointments.isNotEmpty) {
            appt = futureAppointments.first;
          }
        }

        if (appt != null && appt.careType == AppointmentCareType.video) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final apptDate = DateTime(
            appt.appointmentDate.year,
            appt.appointmentDate.month,
            appt.appointmentDate.day,
          );
          if (apptDate != today) {
            appt = null;
          }
        }

        if (appt == null) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today_rounded,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('No Upcoming Appointments',
                          style: AppText.body(13,
                              color: Colors.white, weight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Keep track of your health',
                    style: AppText.display(18, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Book an appointment with our specialists today.',
                    style: AppText.body(13, color: Colors.white60)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onBookPressed,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Book Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: AppText.body(14, weight: FontWeight.w700),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final docName = appt.doctorName ?? 'Clinical Doctor';

        final careTypeStr = appt.careType != null
            ? '${appt.careType!.value[0].toUpperCase()}${appt.careType!.value.substring(1)} Consultation'
            : 'In-person Consultation';

        final formattedDateTime = _formatAppointmentDateTime(
            appt.appointmentDate, appt.appointmentTime);

        final isCallStarted =
            appt.videoRoomUrl != null && appt.videoRoomUrl!.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: AppColors.accent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formattedDateTime,
                            style: AppText.body(13,
                                color: AppColors.accent,
                                weight: FontWeight.w700)),
                        Text(
                          isCallStarted
                              ? 'Active Call - Join Now'
                              : 'Upcoming Appointment',
                          style: AppText.body(11,
                              color: isCallStarted
                                  ? AppColors.accent
                                  : Colors.white60,
                              weight: isCallStarted
                                  ? FontWeight.w700
                                  : FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(docName, style: AppText.display(18, color: Colors.white)),
              const SizedBox(height: 4),
              Text(careTypeStr, style: AppText.body(13, color: Colors.white60)),
              const SizedBox(height: 12),
              // ── Action buttons row ─────────────────────────────────────
              Row(
                children: [
                  // Primary CTA (Join Call / Get Directions)
                  Expanded(
                    child: appt.careType == AppointmentCareType.video
                        ? ElevatedButton.icon(
                            onPressed: (appt.videoRoomUrl != null &&
                                    appt.videoRoomUrl!.isNotEmpty)
                                ? () {
                                    final patientState = context
                                        .read<PatientProfileCubit>()
                                        .state;
                                    final patientName =
                                        (patientState is PatientProfileLoaded)
                                            ? (patientState.profile.fullName ??
                                                'Patient')
                                            : 'Patient';
                                    final patientId =
                                        (patientState is PatientProfileLoaded)
                                            ? patientState.profile.id
                                            : (Supabase.instance.client.auth
                                                    .currentUser?.id ??
                                                '');

                                    Navigator.pushNamed(
                                      context,
                                      Routes.videoCall,
                                      arguments: {
                                        'callId': appt?.videoRoomUrl!,
                                        'userId': patientId,
                                        'userName': patientName,
                                      },
                                    );
                                  }
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Waiting for the doctor to start the video call...'),
                                        backgroundColor: AppColors.orange,
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.videocam_rounded, size: 16),
                            label: Text(
                              (appt.videoRoomUrl != null &&
                                      appt.videoRoomUrl!.isNotEmpty)
                                  ? 'Join Call'
                                  : 'Wait for Doctor',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (appt.videoRoomUrl != null &&
                                      appt.videoRoomUrl!.isNotEmpty)
                                  ? AppColors.accent
                                  : Colors.white.withOpacity(0.2),
                              foregroundColor: (appt.videoRoomUrl != null &&
                                      appt.videoRoomUrl!.isNotEmpty)
                                  ? Colors.white
                                  : Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle:
                                  AppText.body(13, weight: FontWeight.w700),
                              elevation: 0,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Directions: 123 Health Ave, Suite 400')),
                              );
                            },
                            icon:
                                const Icon(Icons.location_on_rounded, size: 16),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle:
                                  AppText.body(13, weight: FontWeight.w700),
                              elevation: 0,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  // Message doctor button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.chatScreen,
                          arguments: {
                            'appointmentId': appt?.id,
                            'currentUserId':
                                Supabase.instance.client.auth.currentUser?.id ??
                                    '',
                            'otherUserId':
                                appt?.doctorAuthId ?? appt?.staffProfileId,
                            'otherUserName': docName,
                            'otherUserRole': 'Doctor',
                            'otherUserAvatar': null,
                          },
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 16),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: AppText.body(13, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodaysAppointments(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        final appointments = context.read<AppointmentCubit>().appointments;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Filter appointments that are scheduled for today
        final todaysAppts = appointments.where((appt) {
          final apptDate = DateTime(
            appt.appointmentDate.year,
            appt.appointmentDate.month,
            appt.appointmentDate.day,
          );
          // Match exactly today's date
          final isToday = apptDate == today;
          final isActive = appt.status == AppointmentStatus.pending ||
              appt.status == AppointmentStatus.confirmed ||
              appt.status == AppointmentStatus.completed;
          return isToday && isActive;
        }).toList();

        // Sort ascending by time
        todaysAppts.sort((a, b) {
          final dtA = DateTime(
              a.appointmentDate.year,
              a.appointmentDate.month,
              a.appointmentDate.day,
              a.appointmentTime.hour,
              a.appointmentTime.minute);
          final dtB = DateTime(
              b.appointmentDate.year,
              b.appointmentDate.month,
              b.appointmentDate.day,
              b.appointmentTime.hour,
              b.appointmentTime.minute);
          return dtA.compareTo(dtB);
        });

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today\'s Appointments', style: AppText.display(16)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${todaysAppts.length}',
                      style: AppText.body(12,
                          color: AppColors.primary, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (todaysAppts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy_rounded,
                            size: 36, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'No appointments scheduled for today.',
                          style: AppText.body(13,
                              color: AppColors.textSecondary,
                              weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todaysAppts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final appt = todaysAppts[index];
                    final time = appt.appointmentTime;
                    final hour =
                        time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                    final minute = time.minute.toString().padLeft(2, '0');
                    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                    final docName = appt.doctorName ?? 'Clinical Doctor';
                    final careTypeStr = appt.careType != null
                        ? '${appt.careType!.value[0].toUpperCase()}${appt.careType!.value.substring(1)}'
                        : 'In-person';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$hour:$minute',
                                  style: AppText.body(13,
                                      color: Colors.white,
                                      weight: FontWeight.w800),
                                ),
                                Text(
                                  period,
                                  style: AppText.label(
                                      color: Colors.white70, size: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  docName,
                                  style:
                                      AppText.body(14, weight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$careTypeStr Consultation',
                                  style: AppText.label(
                                      color: AppColors.textSecondary, size: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: appt.status == AppointmentStatus.confirmed
                                  ? AppColors.green.withOpacity(0.08)
                                  : AppColors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              appt.status.name.toUpperCase(),
                              style: AppText.label(
                                color:
                                    appt.status == AppointmentStatus.confirmed
                                        ? AppColors.green
                                        : AppColors.orange,
                                size: 9,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppText.display(16)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _QuickAction(
              icon: Icons.calendar_today_rounded,
              label: 'Book Appointment',
              color: AppColors.primary,
              bg: AppColors.primary.withOpacity(0.08),
              onTap: onBookPressed,
            )),
            const SizedBox(width: 10),
            Expanded(
                child: _QuickAction(
              icon: Icons.monitor_rounded,
              label: 'Manage Prescriptions',
              color: AppColors.teal,
              bg: AppColors.tealLight,
              onTap: () {
                Navigator.pushNamed(context, Routes.medicalRecordsScreen);
              },
            )),
          ],
        ),
        const SizedBox(height: 10),
        _QuickAction(
          icon: Icons.medication_rounded,
          label: 'Order Refill',
          color: AppColors.accent,
          bg: AppColors.accentLight,
          fullWidth: true,
          onTap: () {
            final patientState = context.read<PatientProfileCubit>().state;
            if (patientState is PatientProfileLoaded) {
              _showOrderRefillBottomSheet(
                  context, patientState.medicalReminders);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Loading your medical data... Please try again.')),
              );
            }
          },
        ),
      ],
    );
  }

  void _showOrderRefillBottomSheet(
      BuildContext context, List<MedicalReminder> reminders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Medication Refill',
                            style: AppText.display(18)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Select an active medication to request a refill from your physician.',
                      style: AppText.body(13, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: reminders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.medication_outlined,
                                    size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                Text(
                                  'No active medications found',
                                  style: AppText.body(14,
                                      weight: FontWeight.w600,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: reminders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = reminders[index];
                              final dose = item.rawDosage.isEmpty
                                  ? 'As directed'
                                  : item.rawDosage;
                              final freq = item.frequencyDescription;

                              return _RefillItemRow(
                                name: item.medicineName,
                                subtitle: '$dose • $freq',
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentRecords(BuildContext context) {
    return BlocBuilder<PatientProfileCubit, PatientProfileState>(
      builder: (context, state) {
        final records = state is PatientProfileLoaded
            ? state.medicalRecords.take(3).toList()
            : <MedicalRecord>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recent Records',
              action: 'View All',
              onAction: () {
                Navigator.pushNamed(context, Routes.medicalRecordsScreen);
              },
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.folder_open_rounded,
                        color: AppColors.textMuted, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No medical records yet.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...records.map((record) {
                final IconData icon;
                final Color iconColor;
                final Color iconBg;
                switch (record.recordType) {
                  case 'lab':
                    icon = Icons.science_rounded;
                    iconColor = AppColors.teal;
                    iconBg = AppColors.tealLight;
                    break;
                  case 'surgery':
                    icon = Icons.local_hospital_rounded;
                    iconColor = AppColors.red;
                    iconBg = AppColors.redLight;
                    break;
                  case 'prescription':
                    icon = Icons.medication_rounded;
                    iconColor = AppColors.orange;
                    iconBg = AppColors.orangeLight;
                    break;
                  default: // visit
                    icon = Icons.description_rounded;
                    iconColor = AppColors.blue;
                    iconBg = AppColors.blueLight;
                }

                final months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ];
                final d = record.recordDate;
                final dateStr = '${months[d.month - 1]} ${d.day}, ${d.year}';

                final title =
                    (record.diagnosis != null && record.diagnosis!.isNotEmpty)
                        ? record.diagnosis!
                        : record.recordType[0].toUpperCase() +
                            record.recordType.substring(1);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RecordTile(
                    icon: icon,
                    iconColor: iconColor,
                    iconBg: iconBg,
                    title: title,
                    subtitle: 'Created on $dateStr',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.medicalRecordsScreen);
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

// ── Supporting Widgets ──────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final bool fullWidth;
  final VoidCallback? onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg,
      this.fullWidth = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(label,
                    style: AppText.body(13, weight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, subtitle;
  final VoidCallback? onTap;
  const _RecordTile(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.title,
      required this.subtitle,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.body(13, weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: AppText.label(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ));
  }
}

class _RefillItemRow extends StatefulWidget {
  final String name;
  final String subtitle;
  const _RefillItemRow({required this.name, required this.subtitle});

  @override
  State<_RefillItemRow> createState() => _RefillItemRowState();
}

class _RefillItemRowState extends State<_RefillItemRow> {
  bool _isLoading = false;
  bool _isSuccess = false;

  void _requestRefill() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSuccess
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isSuccess
                  ? AppColors.green.withValues(alpha: 0.08)
                  : AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.medication_rounded,
              color: _isSuccess ? AppColors.green : AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: AppText.body(14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  _isSuccess
                      ? 'Refill Request Pending Approval'
                      : widget.subtitle,
                  style: AppText.label(
                    color:
                        _isSuccess ? AppColors.green : AppColors.textSecondary,
                    size: 11,
                    weight: _isSuccess ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isSuccess)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'SENT',
                style: AppText.label(
                  color: AppColors.green,
                  size: 9,
                  weight: FontWeight.w700,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: _isLoading ? null : _requestRefill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Refill',
                      style: AppText.body(11,
                          color: Colors.white, weight: FontWeight.bold),
                    ),
            ),
        ],
      ),
    );
  }
}
