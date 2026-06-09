import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/bottom_nav.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/home/view/screens/home_screen.dart';
import 'package:smart_care/features/doctor/schedule/view/screens/schedule_screen.dart';
import 'package:smart_care/features/doctor/patients/view/screens/patients_screen.dart';
import 'package:smart_care/features/doctor/profile/view/screens/profile_screen.dart';
import 'package:smart_care/features/patient/book/view/screens/find_specialist_screen.dart';
import 'package:smart_care/features/patient/home/view/screens/home_screen.dart';
import 'package:smart_care/features/patient/profile/view/screens/profile_screen.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';

class MainLayout extends StatefulWidget {
  final String role;
  final String? profileId;
  const MainLayout({super.key, required this.role, this.profileId});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  List<Widget> _screens = [];
  @override
  void initState() {
    super.initState();
    _screens = widget.role == 'doctor'
        ? [
            HomeScreen(role: widget.role, profileId: widget.profileId),
            ScheduleScreen(role: widget.role, profileId: widget.profileId),
            const PatientsScreen(),
            ProfileScreen(profileId: widget.profileId),
          ]
        : [
            PatientHomeScreen(onBookPressed: () {
              setState(() {
                _currentIndex = 2; // Find Specialist Screen
              });
            }),
            ScheduleScreen(role: widget.role, profileId: widget.profileId),
            const FindSpecialistScreen(),
            // MedicalRecordsScreen(),
            PatientProfileScreen(profileId: widget.profileId),
          ];

    if (widget.role == 'patient' && widget.profileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PatientProfileCubit>().loadPatientProfile(widget.profileId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientProfileCubit, PatientProfileState>(
      listener: (context, state) {
        if (state is PatientProfileLoaded) {
          context.read<AppointmentCubit>().getPatientAppointments(state.profile.id);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: SmartCareBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          role: widget.role,
        ),
      ),
    );
  }
}
