import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/auth/cubit/auth_cubit.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_state.dart';
import 'package:smart_care/features/doctor/profile/view/widgets/build_profile_header.dart';
import 'package:smart_care/features/doctor/profile/view/widgets/build_section.dart';
import 'package:smart_care/features/doctor/profile/view/widgets/build_stats_row.dart';

class ProfileScreen extends StatefulWidget {
  final String? profileId;
  const ProfileScreen({super.key, this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.profileId != null) {
      context.read<ProfileCubit>().fetchById(widget.profileId!);
      context.read<MedicalStaffCubit>().getMedicalData(widget.profileId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: MultiBlocListener(
            listeners: [
              BlocListener<MedicalStaffCubit, MedicalStaffState>(
                listener: (context, state) {
                  if (state is MedicalStaffSuccess) {
                    final id = state.medicalStaffProfile.specialtyId;
                    if (id != null) {
                      print("speciality ID: $id");
                    } else {
                      print("speciality ID: No Data");
                    }
                  }
                },
              ),
            ],
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                return BlocBuilder<MedicalStaffCubit, MedicalStaffState>(
                  builder: (context, medicalState) {
                    // ── loading ──────────────────────────────
                    if (profileState is ProfileLoading ||
                        medicalState is MedicalStaffLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // ── error ─────────────────────────────────
                    if (profileState is ProfileFailure) {
                      return Center(child: Text(profileState.message));
                    }
                    if (medicalState is MedicalStaffFailure) {
                      return Center(child: Text(medicalState.message));
                    }

                    // ── data ──────────────────────────────────
                    final doctor = profileState is ProfileSuccess
                        ? profileState.profile
                        : null;
                    final medicalData = medicalState is MedicalStaffSuccess
                        ? medicalState.medicalStaffProfile
                        : null;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          ProfileHeader(
                            name: doctor?.fullName,
                            imageUrl: doctor?.avatarUrl,
                            specialityId: medicalData?.specialtyId,
                          ),
                          const SizedBox(height: 24),
                          buildStatsRow(
                            patientsCount: medicalData
                                    ?.appointmentDurationMinutes
                                    .toString() ??
                                'no data',
                            yearsOfExperience:
                                medicalData?.yearsExperience.toString() ??
                                    'no data',
                            isVerified:
                                medicalData?.isVerified == true ? 'Yes' : 'No',
                          ),
                          const SizedBox(height: 20),
                          buildSection('Account', [
                            MenuItem(
                                icon: Icons.person_outline_rounded,
                                label: 'Personal Information',
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.personalInfoScreen)),
                            MenuItem(
                                icon: Icons.medical_services_outlined,
                                label: 'Credentials & License',
                                onTap: () {
                                  if (medicalData?.id != null) {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.credentialsScreen,
                                      arguments: medicalData!.id,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Medical profile data is loading...'),
                                      ),
                                    );
                                  }
                                }),
                          ]),
                          const SizedBox(height: 16),
                          buildSection('Preferences', [
                            MenuItem(
                                icon: Icons.notifications_outlined,
                                label: 'Notification Settings'),
                            MenuItem(
                                icon: Icons.palette_outlined,
                                label: 'Appearance'),
                            MenuItem(
                                icon: Icons.language_outlined,
                                label: 'Language'),
                          ]),
                          const SizedBox(height: 16),
                          buildSection('Support', [
                            MenuItem(
                                icon: Icons.help_outline_rounded,
                                label: 'Help Center'),
                            MenuItem(
                                icon: Icons.privacy_tip_outlined,
                                label: 'Privacy Policy'),
                            MenuItem(
                                icon: Icons.star_outline_rounded,
                                label: 'Rate Smart-Care'),
                          ]),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.read<LogoutCubit>().logout(),
                              icon: const Icon(Icons.logout_rounded,
                                  color: AppColors.critical, size: 18),
                              label: Text(
                                'Log Out',
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.critical,
                                    fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: AppColors.critical.withOpacity(0.3)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                );
              },
            )),
      ),
    );
  }
}
