import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/shared.dart';
import 'package:smart_care/features/patient/theme3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Medical Records',
            style: AppText.display(20, color: AppColors.primary)),
      ),
      body: BlocBuilder<PatientProfileCubit, PatientProfileState>(
        builder: (context, state) {
          if (state is PatientProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is PatientProfileError) {
            return Center(
              child: Text(
                'Failed to load records: ${state.error}',
                style: AppText.body(14, color: AppColors.red),
              ),
            );
          }

          final records = state is PatientProfileLoaded
              ? state.medicalRecords
              : <MedicalRecord>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CPSearchBar(
                        hint: 'Search for reports, doctors, or hospitals...',
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          // width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.tune_rounded,
                                  color: Colors.white, size: 15),
                              const SizedBox(width: 3),
                              Text('Filter',
                                  style: AppText.label(
                                      color: Colors.white, size: 9)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _TrendCard(),
                const SizedBox(height: 16),
                // Quick access buttons
                Row(
                  children: [
                    Expanded(
                        child: _AccessButton(
                            icon: Icons.science_rounded,
                            label: 'Lab Results',
                            color: AppColors.teal,
                            bg: AppColors.tealLight)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _AccessButton(
                            icon: Icons.image_rounded,
                            label: 'Prescriptions',
                            color: AppColors.primary,
                            bg: AppColors.primary.withOpacity(0.08))),
                  ],
                ),

                const SizedBox(height: 24),
                SectionHeader(title: 'Recent Records'),
                const SizedBox(height: 14),
                if (records.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open_rounded,
                              size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No medical records found',
                            style: AppText.body(14,
                                weight: FontWeight.w600,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
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
                    final dateStr =
                        '${months[d.month - 1]} ${d.day}, ${d.year}';

                    final title = (record.diagnosis != null &&
                            record.diagnosis!.isNotEmpty)
                        ? record.diagnosis!
                        : record.recordType[0].toUpperCase() +
                            record.recordType.substring(1);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecordCard(
                        badgeLabel: null,
                        badgeColor: Colors.transparent,
                        badgeBg: Colors.transparent,
                        title: title,
                        date: dateStr,
                        doctor: record.treatment ?? 'General Consultation',
                        icon: icon,
                        iconColor: iconColor,
                        iconBg: iconBg,
                        onViewTap: () =>
                            _showRecordDetailsBottomSheet(context, record),
                      ),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRecordDetailsBottomSheet(
      BuildContext context, MedicalRecord record) {
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
    final title = (record.diagnosis != null && record.diagnosis!.isNotEmpty)
        ? record.diagnosis!
        : record.recordType[0].toUpperCase() + record.recordType.substring(1);

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
      default:
        icon = Icons.description_rounded;
        iconColor = AppColors.blue;
        iconBg = AppColors.blueLight;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.display(16)),
                        const SizedBox(height: 2),
                        Text(
                          '${record.recordType[0].toUpperCase()}${record.recordType.substring(1)} • $dateStr',
                          style: AppText.label(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record.symptoms != null &&
                          record.symptoms!.isNotEmpty) ...[
                        Text('Symptoms',
                            style: AppText.body(13, weight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            record.symptoms!,
                            style: AppText.body(12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (record.treatment != null &&
                          record.treatment!.isNotEmpty) ...[
                        Text('Treatment & Diagnosis Details',
                            style: AppText.body(13, weight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            record.treatment!,
                            style: AppText.body(12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (record.doctorNotes != null &&
                          record.doctorNotes!.isNotEmpty) ...[
                        Text('Doctor Notes',
                            style: AppText.body(13, weight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            record.doctorNotes!,
                            style: AppText.body(12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (record.notes != null && record.notes!.isNotEmpty) ...[
                        Text('General Notes',
                            style: AppText.body(13, weight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            record.notes!,
                            style: AppText.body(12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  const _AccessButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: AppText.body(13, color: color, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final String? badgeLabel;
  final Color badgeColor, badgeBg;
  final String title, date;
  final String? doctor;
  final IconData icon;
  final Color iconColor, iconBg;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onViewTap;

  const _RecordCard({
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    required this.title,
    required this.date,
    this.doctor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.actionLabel,
    this.actionColor,
    this.onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badgeLabel != null)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badgeLabel!,
                      style: AppText.label(color: badgeColor, size: 9),
                      textAlign: TextAlign.center),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.body(14, weight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    if (doctor != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(date,
                                  style: AppText.label(
                                      color: AppColors.textMuted))),
                        ],
                      ),
                    if (doctor != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_rounded,
                              size: 11, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(doctor!,
                                  style: AppText.label(
                                      color: AppColors.textMuted))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download_rounded,
                      size: 14, color: actionColor),
                  label: Text('Download PDF',
                      style: AppText.body(12,
                          color: actionColor, weight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: actionColor!.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded,
                      size: 14, color: Colors.white),
                  label: Text(actionLabel!,
                      style: AppText.body(12,
                          color: Colors.white, weight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onViewTap,
                  child: const Icon(Icons.visibility_outlined,
                      size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded,
                      size: 14, color: AppColors.primary),
                  label: Text('Download PDF',
                      style: AppText.body(12,
                          color: AppColors.primary, weight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onViewTap,
                  child: const Icon(Icons.visibility_outlined,
                      size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trend Analysis',
              style: AppText.display(18, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Your cholesterol levels have decreased by 12% since your last check-up in January. Keep up the dietary plan.',
            style: AppText.body(13, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LDL LEVEL',
                          style:
                              AppText.label(color: Colors.white60, size: 10)),
                      const SizedBox(height: 4),
                      Text('110 g/dL',
                          style: AppText.display(20, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HDL LEVEL',
                          style:
                              AppText.label(color: Colors.white60, size: 10)),
                      const SizedBox(height: 4),
                      Text('K8 g/dL',
                          style: AppText.display(20, color: AppColors.accent)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifiedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_rounded,
              color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text('Records Verified',
              style: AppText.display(18, color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            'Your records are encrypted and synced with the National Health Registry.',
            style: AppText.body(13, color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: Text('Manage Privacy Settings',
                  style: AppText.body(14,
                      color: Colors.white, weight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
