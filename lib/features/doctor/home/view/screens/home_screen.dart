import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_state.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/doctor/home/view/widgets/home_greeting.dart';
import 'package:smart_care/features/doctor/home/view/widgets/home_search_bar.dart';
import 'package:smart_care/features/doctor/home/view/widgets/home_stats_row.dart';
import 'package:smart_care/features/doctor/home/view/widgets/today_schedule_list.dart';
import 'package:smart_care/features/doctor/home/view/widgets/vitals_overview.dart';
import 'package:smart_care/features/doctor/home/view/widgets/trends_card.dart';

class HomeScreen extends StatefulWidget {
  final String? role;
  final String? profileId;

  const HomeScreen({super.key, this.role, this.profileId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicalStaffCubit, MedicalStaffState>(
      listener: (context, state) {
        if (state is MedicalStaffSuccess) {
          context
              .read<AppointmentCubit>()
              .getAppointments(state.medicalStaffProfile.id);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              final appointments =
                  context.read<AppointmentCubit>().appointments;

              // Filter for today
              final today = DateTime.now();
              final todayAppointments = appointments.where((a) {
                return a.appointmentDate.year == today.year &&
                    a.appointmentDate.month == today.month &&
                    a.appointmentDate.day == today.day;
              }).toList();

              // Calculate stats
              final uniquePatients = todayAppointments
                  .map((a) => a.patientProfileId)
                  .toSet()
                  .length;
              final pendingCount = appointments
                  .where((a) => a.status == AppointmentStatus.pending)
                  .length;
              final completedToday = todayAppointments
                  .where((a) => a.status == AppointmentStatus.completed)
                  .length;
              final totalToday = todayAppointments.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const HomeGreeting(),
                    const SizedBox(height: 20),
                    const HomeSearchBar(),
                    const SizedBox(height: 16),
                    HomeStatsRow(
                      uniquePatients: uniquePatients,
                      pendingCount: pendingCount,
                    ),
                    const SizedBox(height: 16),
                    TodayScheduleList(
                      todayList: todayAppointments,
                      state: state,
                    ),
                    const SizedBox(height: 16),
                    VitalsOverview(
                      completedToday: completedToday,
                      totalToday: totalToday,
                    ),
                    const SizedBox(height: 16),
                    const TrendsCard(),
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
