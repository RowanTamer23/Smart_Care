import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_state.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/doctor/schedule/view/widgets/calendar_header.dart';
import 'package:smart_care/features/doctor/schedule/view/widgets/week_strip.dart';
import 'package:smart_care/features/doctor/schedule/view/widgets/schedule_load_card.dart';
import 'package:smart_care/features/doctor/schedule/view/widgets/schedule_appointments_list.dart';

class ScheduleScreen extends StatefulWidget {
  final String? role;
  final String? profileId;

  const ScheduleScreen({super.key, this.role, this.profileId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late List<(String, DateTime)> _days;

  @override
  void initState() {
    super.initState();

    // Calculate current week starting from Monday
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _selectedDate = DateTime(now.year, now.month, now.day);

    final weekdayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    _days = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      return (weekdayNames[index], DateTime(date.year, date.month, date.day));
    });

    if (widget.role == 'doctor' && widget.profileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final medicalCubit = context.read<MedicalStaffCubit>();
        final profile = medicalCubit.medicalStaffProfile;
        if (profile == null) {
          medicalCubit.getMedicalData(widget.profileId!);
        } else {
          context.read<AppointmentCubit>().getAppointments(profile.id);
        }
      });
    }
  }

  void _onNavigation(int daysDiff) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: daysDiff));
      // Re-calculate the week based on new selectedDate
      final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final weekdayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      _days = List.generate(7, (index) {
        final date = monday.add(Duration(days: index));
        return (weekdayNames[index], DateTime(date.year, date.month, date.day));
      });
    });
  }

  void _onToday() {
    setState(() {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      _selectedDate = DateTime(now.year, now.month, now.day);
      final weekdayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      _days = List.generate(7, (index) {
        final date = monday.add(Duration(days: index));
        return (weekdayNames[index], DateTime(date.year, date.month, date.day));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicalStaffCubit, MedicalStaffState>(
      listener: (context, state) {
        if (state is MedicalStaffSuccess) {
          context.read<AppointmentCubit>().getAppointments(state.medicalStaffProfile.id);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              final appointments = context.read<AppointmentCubit>().appointments;
              
              // Filter appointments for selected day
              final filtered = appointments.where((a) {
                return a.appointmentDate.year == _selectedDate.year &&
                    a.appointmentDate.month == _selectedDate.month &&
                    a.appointmentDate.day == _selectedDate.day;
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    CalendarHeader(
                      selectedDate: _selectedDate,
                      role: widget.role,
                      onPreviousWeek: () => _onNavigation(-7),
                      onToday: _onToday,
                      onNextWeek: () => _onNavigation(7),
                    ),
                    WeekStrip(
                      days: _days,
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                    if (widget.role == 'doctor') ...[
                      ScheduleLoadCard(
                        selectedDate: _selectedDate,
                        filtered: filtered,
                      ),
                      ScheduleAppointmentsList(
                        selectedDate: _selectedDate,
                        filtered: filtered,
                        state: state,
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Schedule features are only available to medical staff.',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
