import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/patients/cubit/doctor_patients_cubit.dart';
import 'package:smart_care/features/doctor/patients/cubit/doctor_patients_state.dart';
import 'package:smart_care/features/doctor/patients/data/model/doctor_patient_model.dart';
import 'package:smart_care/features/doctor/patients/view/widgets/patient_card.dart';
import 'package:smart_care/features/doctor/patients/view/widgets/patients_header.dart';
import 'package:smart_care/features/doctor/patients/view/widgets/patients_search_bar.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _searchQuery = '';

  // ── Load helpers ──────────────────────────────────────────────────────────

  void _tryLoad() {
    final medicalCubit = context.read<MedicalStaffCubit>();
    final staffProfile = medicalCubit.medicalStaffProfile;
    if (staffProfile == null) return;

    final appointments = context.read<AppointmentCubit>().appointments;
    // Don't bother if there's nothing to load
    if (appointments.isEmpty) return;

    final patientsState = context.read<DoctorPatientsCubit>().state;
    // If already loading or successfully loaded with data, skip
    if (patientsState is DoctorPatientsLoading) return;
    if (patientsState is DoctorPatientsSuccess && patientsState.patients.isNotEmpty) return;

    context.read<DoctorPatientsCubit>().loadPatients(
          staffProfileId: staffProfile.id,
          appointments: appointments,
        );
  }

  void _forceReload() {
    final medicalCubit = context.read<MedicalStaffCubit>();
    final staffProfile = medicalCubit.medicalStaffProfile;
    if (staffProfile == null) return;

    final appointments = context.read<AppointmentCubit>().appointments;
    context.read<DoctorPatientsCubit>().loadPatients(
          staffProfileId: staffProfile.id,
          appointments: appointments,
        );
  }

  List<DoctorPatient> _applyFilter(List<DoctorPatient> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((p) => p.displayName.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Whenever appointments arrive / update, re-trigger patient load
        BlocListener<AppointmentCubit, AppointmentState>(
          listener: (context, state) {
            if (state is AppointmentSuccess) {
              _tryLoad();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PatientsHeader(),
              PatientsSearchBar(
                onSearchQueryChanged: (v) => setState(() => _searchQuery = v),
              ),
              Expanded(
                child: BlocBuilder<DoctorPatientsCubit, DoctorPatientsState>(
                  builder: (context, state) {
                    // Auto-trigger on first build if appointments already available
                    WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoad());

                    if (state is DoctorPatientsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (state is DoctorPatientsFailure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.critical.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load patients',
                                style: AppTextStyles.heading3
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.error,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _forceReload,
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final patients = state is DoctorPatientsSuccess
                        ? _applyFilter(state.patients)
                        : <DoctorPatient>[];

                    if (patients.isEmpty) {
                      final appointmentsLoaded =
                          context.read<AppointmentCubit>().appointments.isNotEmpty;

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 56,
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No patients yet'
                                  : 'No results for "$_searchQuery"',
                              style: AppTextStyles.heading3
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                appointmentsLoaded
                                    ? 'Patients will appear once appointments are confirmed.'
                                    : 'Patients will appear here\nonce they book an appointment.',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          PatientCard(patient: patients[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
