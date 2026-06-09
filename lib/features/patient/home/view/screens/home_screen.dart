import 'package:flutter/material.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/patient/shared.dart';
import 'package:smart_care/features/patient/theme3.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';

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
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      datePart = '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              _buildTopBar(context),
              const SizedBox(height: 20),
              _buildUpcomingCard(context),
              const SizedBox(height: 20),
              _buildHealthInsights(),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildRecentRecords(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return BlocBuilder<PatientProfileCubit, PatientProfileState>(
      builder: (context, state) {
        String patientName = 'Rowan Tamer';
        if (state is PatientProfileLoaded && state.profile.fullName != null && state.profile.fullName!.isNotEmpty) {
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
              ),
              child:
                  const Icon(Icons.person_rounded, color: Colors.white, size: 22),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimary, size: 22),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: AppColors.red, shape: BoxShape.circle),
                    ),
                  ),
                ],
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

        // Find nearest future appointment
        final futureAppointments = appointments.where((appt) {
          final apptDateTime = DateTime(
            appt.appointmentDate.year,
            appt.appointmentDate.month,
            appt.appointmentDate.day,
            appt.appointmentTime.hour,
            appt.appointmentTime.minute,
          );
          final isFuture = apptDateTime.isAfter(DateTime.now().subtract(const Duration(minutes: 30)));
          final isActive = appt.status == AppointmentStatus.pending || appt.status == AppointmentStatus.confirmed;
          return isFuture && isActive;
        }).toList();

        // Sort ascending
        futureAppointments.sort((a, b) {
          final dtA = DateTime(a.appointmentDate.year, a.appointmentDate.month, a.appointmentDate.day, a.appointmentTime.hour, a.appointmentTime.minute);
          final dtB = DateTime(b.appointmentDate.year, b.appointmentDate.month, b.appointmentDate.day, b.appointmentTime.hour, b.appointmentTime.minute);
          return dtA.compareTo(dtB);
        });

        if (futureAppointments.isEmpty) {
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

        final appt = futureAppointments.first;
        final docName = appt.doctorName ?? 'Clinical Doctor';
        
        final careTypeStr = appt.careType != null
            ? '${appt.careType!.value[0].toUpperCase()}${appt.careType!.value.substring(1)} Consultation'
            : 'In-person Consultation';

        final formattedDateTime = _formatAppointmentDateTime(appt.appointmentDate, appt.appointmentTime);

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
                                color: AppColors.accent, weight: FontWeight.w700)),
                        Text('Upcoming Appointment',
                            style: AppText.body(11, color: Colors.white60)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(docName,
                  style: AppText.display(18, color: Colors.white)),
              const SizedBox(height: 4),
              Text(careTypeStr,
                  style: AppText.body(13, color: Colors.white60)),
              const SizedBox(height: 12),
              // ── Action buttons row ─────────────────────────────────────
              Row(
                children: [
                  // Primary CTA (Join Call / Get Directions)
                  Expanded(
                    child: appt.careType == AppointmentCareType.video
                        ? ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Joining: ${appt.videoRoomUrl ?? "https://smartcare.meet/room-id"}')),
                              );
                            },
                            icon: const Icon(Icons.videocam_rounded, size: 16),
                            label: const Text('Join Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                            icon: const Icon(Icons.location_on_rounded,
                                size: 16),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                    child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
                      builder: (context, profileState) {
                        final patientProfileId =
                            profileState is PatientProfileLoaded
                                ? profileState.profile.id
                                : appt.patientProfileId;
                        return OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              Routes.chatScreen,
                              arguments: {
                                'appointmentId': appt.id,
                                'currentUserId': patientProfileId,
                                'otherUserId': appt.staffProfileId,
                                'otherUserName': docName,
                                'otherUserRole': 'Doctor',
                                'otherUserAvatar': null,
                              },
                            );
                          },
                          icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16),
                          label: const Text('Message'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color:
                                    Colors.white.withValues(alpha: 0.4)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle:
                                AppText.body(13, weight: FontWeight.w700),
                          ),
                        );
                      },
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

  Widget _buildHealthInsights() {
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
              Text('Health Insights', style: AppText.display(16)),
              const Icon(Icons.favorite_rounded,
                  color: AppColors.red, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _VitalTile(
                  label: 'Blood Pressure',
                  value: '120/80',
                  unit: 'mm Hg',
                  color: AppColors.blue,
                  bg: AppColors.blueLight,
                  icon: Icons.favorite_border_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VitalTile(
                  label: 'Heart Rate',
                  value: '72',
                  unit: 'bpm',
                  color: AppColors.green,
                  bg: AppColors.greenLight,
                  icon: Icons.monitor_heart_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Mini sparkline
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 40,
              child: CustomPaint(
                painter: _SparklinePainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
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
                    bg: AppColors.tealLight)),
          ],
        ),
        const SizedBox(height: 10),
        _QuickAction(
            icon: Icons.medication_rounded,
            label: 'Order Refill',
            color: AppColors.accent,
            bg: AppColors.accentLight,
            fullWidth: true),
      ],
    );
  }

  Widget _buildRecentRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recent Records', action: 'View All'),
        const SizedBox(height: 12),
        _RecordTile(
          icon: Icons.description_rounded,
          iconColor: AppColors.blue,
          iconBg: AppColors.blueLight,
          title: 'New Blood LPL Recommendation',
          subtitle: 'Created 3 days ago on Oct 24, 2023',
        ),
        const SizedBox(height: 8),
        _RecordTile(
          icon: Icons.picture_as_pdf_rounded,
          iconColor: AppColors.orange,
          iconBg: AppColors.orangeLight,
          title: 'Vaccination Record Update 3ad Pred',
          subtitle: 'Created 6 days on Oct 2, 2023',
        ),
      ],
    );
  }
}

// ── Supporting Widgets ──────────────────────────────────────────────────────

class _VitalTile extends StatelessWidget {
  final String label, value, unit;
  final Color color, bg;
  final IconData icon;
  const _VitalTile(
      {required this.label,
      required this.value,
      required this.unit,
      required this.color,
      required this.bg,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: AppText.display(22, color: color)),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit,
                    style:
                        AppText.label(color: color.withOpacity(0.7), size: 10)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppText.label(color: color.withOpacity(0.8), size: 10)),
        ],
      ),
    );
  }
}

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
  const _RecordTile(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = [0.7, 0.5, 0.65, 0.4, 0.55, 0.45, 0.6, 0.35, 0.5, 0.6];
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = (1 - points[i]) * size.height;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
