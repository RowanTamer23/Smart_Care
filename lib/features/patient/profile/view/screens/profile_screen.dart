import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/auth/cubit/auth_cubit.dart';
import 'package:smart_care/features/auth/cubit/auth_state.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Widget imports
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/edit_profile_dialog.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_sliver_app_bar.dart';
import 'package:smart_care/features/patient/profile/view/widgets/patient_quick_card.dart';
import 'package:smart_care/features/patient/profile/view/widgets/medicine_reminders.dart';
import 'package:smart_care/features/patient/profile/view/widgets/medical_history_section.dart';
import 'package:smart_care/features/patient/profile/view/widgets/lab_and_documents_section.dart';
import 'package:smart_care/features/patient/profile/view/widgets/emergency_contacts_section.dart';
import 'package:smart_care/features/patient/profile/view/widgets/danger_zone_section.dart';

class PatientProfileScreen extends StatefulWidget {
  final String? profileId;
  const PatientProfileScreen({super.key, this.profileId});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load patient profile
    final userId =
        widget.profileId ?? Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<PatientProfileCubit>().loadPatientProfile(userId);
    }
  }

  void _showEditProfileDialog(BuildContext context, PatientProfile profile) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        backgroundColor: C.bg,
        body: BlocBuilder<PatientProfileCubit, PatientProfileState>(
          builder: (context, state) {
            if (state is PatientProfileInitial ||
                state is PatientProfileLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: C.teal));
            } else if (state is PatientProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}',
                        style: bTextStyle(14, c: C.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final userId = widget.profileId ??
                            Supabase.instance.client.auth.currentUser?.id;
                        if (userId != null) {
                          context
                              .read<PatientProfileCubit>()
                              .loadPatientProfile(userId);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: C.teal),
                      child: Text('Retry',
                          style: bTextStyle(14,
                              c: Colors.white, w: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            } else if (state is PatientProfileLoaded) {
              final profile = state.profile;
              final records = state.medicalRecords;

              return CustomScrollView(
                slivers: [
                  ProfileSliverAppBar(
                    profile: profile,
                    onEditPressed: () =>
                        _showEditProfileDialog(context, profile),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          PatientQuickCard(profile: profile),
                          const SizedBox(height: 20),
                          MedicineReminders(
                            reminders: state.medicalReminders,
                            patientProfileId: profile.id,
                          ),
                          const SizedBox(height: 20),
                          MedicalHistorySection(
                              profile: profile, records: records),
                          const SizedBox(height: 20),
                          LabAndDocumentsSection(records: records),
                          const SizedBox(height: 20),
                          EmergencyContactsSection(profile: profile),
                          const SizedBox(height: 20),
                          const DangerZoneSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
