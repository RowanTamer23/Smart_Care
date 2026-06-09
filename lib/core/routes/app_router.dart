import 'package:flutter/material.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/auth/view/screens/login_screen.dart';
import 'package:smart_care/features/auth/view/screens/medical_staff_profile_screen.dart';
import 'package:smart_care/features/auth/view/screens/register_screen.dart';
import 'package:smart_care/features/doctor/home/view/screens/main_layout.dart';
import 'package:smart_care/features/doctor/profile/view/screens/profile_screen.dart';
import 'package:smart_care/features/onboarding/view/screens/onboarding_screen.dart';
import 'package:smart_care/features/onboarding/view/screens/role_selection_screen.dart';
import 'package:smart_care/features/onboarding/view/screens/splash_screen.dart';
import 'package:smart_care/features/patient/book/view/screens/doctor_profile_screen.dart';
import 'package:smart_care/features/patient/book/view/screens/find_specialist_screen.dart';
import 'package:smart_care/features/patient/home/view/screens/home_screen.dart';
import 'package:smart_care/features/patient/profile/view/screens/medical_records_screen.dart';
import 'package:smart_care/features/patient/profile/view/screens/profile_screen.dart';
import 'package:smart_care/features/doctor/profile/view/screens/credentials_screen.dart';
import 'package:smart_care/features/doctor/profile/view/screens/personal_info_screen.dart';
import 'package:smart_care/features/doctor/schedule/view/screens/availability_settings_screen.dart';
import 'package:smart_care/features/doctor/patients/view/screens/patient_detail_screen.dart';
import 'package:smart_care/features/doctor/patients/data/model/doctor_patient_model.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/doctor/schedule/view/screens/appointment_approval_screen.dart';
import 'package:smart_care/features/patient/book/view/screens/chat_screen.dart';

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case Routes.roleSelection:
        return MaterialPageRoute(builder: (_) => RoleSelectionScreen());

      case Routes.register:
        return MaterialPageRoute(
            builder: (_) => RegisterScreen(role: settings.arguments as int));

      case Routes.medicalStaffProfile:
        return MaterialPageRoute(
            builder: (_) => const MedicalStaffProfileScreen());

      case Routes.home:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => MainLayout(
                  role: args['role'],
                  profileId: args['userId'],
                ));

      // patient routes
      case Routes.patientHomeScreen:
        return MaterialPageRoute(builder: (_) => const PatientHomeScreen());

      case Routes.findSpecialistScreen:
        return MaterialPageRoute(builder: (_) => const FindSpecialistScreen());

      case Routes.doctorProfileScreen:
        final doctorData = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctorData: doctorData));

      case Routes.medicalRecordsScreen:
        return MaterialPageRoute(builder: (_) => const MedicalRecordsScreen());

      case Routes.patientProfileScreen:
        return MaterialPageRoute(builder: (_) => const PatientProfileScreen());

      case Routes.profileScreen:
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(
                  profileId: settings.arguments as String?,
                ));

      case Routes.credentialsScreen:
        final staffProfileId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => CredentialsScreen(id: staffProfileId));

      case Routes.personalInfoScreen:
        return MaterialPageRoute(
            builder: (_) => const PersonalInfoScreen());

      case Routes.availabilitySettings:
        final staffProfileId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => AvailabilitySettingsScreen(staffProfileId: staffProfileId));

      case Routes.patientDetailScreen:
        final patient = settings.arguments as DoctorPatient;
        return MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patient: patient));

      case Routes.appointmentApproval:
        final appointment = settings.arguments as Appointment;
        return MaterialPageRoute(
            builder: (_) => AppointmentApprovalScreen(appointment: appointment));

      case Routes.chatScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            appointmentId: args['appointmentId'] as String,
            currentUserId: args['currentUserId'] as String,
            otherUserId: args['otherUserId'] as String,
            otherUserName: args['otherUserName'] as String,
            otherUserRole: args['otherUserRole'] as String?,
            otherUserAvatar: args['otherUserAvatar'] as String?,
          ),
        );
    }

    // Unknown route
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
