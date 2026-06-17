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
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_care/core/services/notification_service.dart';
import 'package:smart_care/core/routes/routes.dart';

class MainLayout extends StatefulWidget {
  final String role;
  final String? profileId;
  static final ValueNotifier<int> mainLayoutTabNotifier = ValueNotifier<int>(0);

  const MainLayout({super.key, required this.role, this.profileId});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  List<Widget> _screens = [];
  RealtimeChannel? _appointmentChannel;

  void _onTabNotifierChanged() {
    if (mounted) {
      setState(() {
        _currentIndex = MainLayout.mainLayoutTabNotifier.value;
      });
    }
  }

  @override
  void dispose() {
    MainLayout.mainLayoutTabNotifier.removeListener(_onTabNotifierChanged);
    _unsubscribeFromAppointments();
    super.dispose();
  }

  void _unsubscribeFromAppointments() {
    if (_appointmentChannel != null) {
      Supabase.instance.client.removeChannel(_appointmentChannel!);
      _appointmentChannel = null;
    }
  }

  void _subscribeToAppointments(String filterColumn, String filterValue, VoidCallback onUpdate) {
    if (_appointmentChannel != null) return;

    _appointmentChannel = Supabase.instance.client
        .channel('public:appointments:$filterValue')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: filterColumn,
            value: filterValue,
          ),
          callback: (payload) {
            if (mounted) {
              onUpdate();
              try {
                final newRecord = payload.newRecord;
                if (newRecord != null) {
                  final statusStr = newRecord['status'] as String? ?? 'pending';
                  final dateStr = newRecord['appointment_date'] as String? ?? '';
                  final timeStr = newRecord['appointment_time'] as String? ?? '';
                  
                  if (payload.eventType == PostgresChangeEvent.insert) {
                    NotificationService().showInstantNotification(
                      title: 'Appointment Booked',
                      body: 'A new appointment has been scheduled for $dateStr at $timeStr.',
                      type: 'appointment',
                    );
                  } else if (payload.eventType == PostgresChangeEvent.update) {
                    NotificationService().showInstantNotification(
                      title: 'Appointment Status Updated',
                      body: 'Your appointment for $dateStr is now ${statusStr.toUpperCase()}.',
                      type: 'appointment',
                    );
                  }
                }
              } catch (e) {
                debugPrint('Realtime notification error: $e');
              }
            }
          },
        )
        .subscribe();
  }

  @override
  void initState() {
    super.initState();
    MainLayout.mainLayoutTabNotifier.addListener(_onTabNotifierChanged);
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
    return MultiBlocListener(
      listeners: [
        BlocListener<PatientProfileCubit, PatientProfileState>(
          listener: (context, state) {
            if (state is PatientProfileLoaded) {
              final patientId = state.profile.id;
              context.read<AppointmentCubit>().getPatientAppointments(patientId);
              _subscribeToAppointments(
                'patient_profile_id',
                patientId,
                () {
                  context.read<AppointmentCubit>().getPatientAppointments(patientId);
                },
              );
              NotificationService().scheduleMedicineReminders(state.medicalReminders);
            }
          },
        ),
        BlocListener<AppointmentCubit, AppointmentState>(
          listener: (context, state) {
            if (state is AppointmentSuccess) {
              NotificationService().scheduleAppointmentNotifications(state.appointments);
            }
          },
        ),
        BlocListener<MedicalStaffCubit, MedicalStaffState>(
          listener: (context, state) {
            if (state is MedicalStaffSuccess) {
              final staffId = state.medicalStaffProfile.id;
              context.read<AppointmentCubit>().getAppointments(staffId);
              _subscribeToAppointments(
                'staff_profile_id',
                staffId,
                () {
                  context.read<AppointmentCubit>().getAppointments(staffId);
                },
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.aiChatScreen,
              arguments: widget.role,
            );
          },
          backgroundColor: const Color(0xFF1A3C34),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF5A623), size: 18),
          label: const Text(
            'AI Chat',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2),
          ),
        ),
        bottomNavigationBar: SmartCareBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0 && widget.role == 'patient' && widget.profileId != null) {
              context.read<PatientProfileCubit>().loadPatientProfile(widget.profileId!);
            }
          },
          role: widget.role,
        ),
      ),
    );
  }
}
