import 'package:flutter/material.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/patients/data/model/doctor_patient_model.dart';
import 'package:smart_care/features/doctor/patients/view/widgets/info_pill.dart';

class PatientCard extends StatelessWidget {
  final DoctorPatient patient;
  const PatientCard({super.key, required this.patient});

  Color get _statusColor {
    switch (patient.status) {
      case 'STABLE':
        return AppColors.stable;
      case 'FOLLOW-UP':
        return AppColors.followUp;
      case 'CRITICAL':
        return AppColors.critical;
      default:
        return AppColors.textMuted;
    }
  }

  Color get _statusBg {
    switch (patient.status) {
      case 'STABLE':
        return AppColors.stableLight;
      case 'FOLLOW-UP':
        return AppColors.followUpLight;
      case 'CRITICAL':
        return AppColors.criticalLight;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = patient.status == 'CRITICAL';
    final initials = patient.displayName.isNotEmpty
        ? patient.displayName[0].toUpperCase()
        : 'P';
    final bloodType = patient.profile.bloodType?.value;
    final allergiesCount = patient.profile.allergies.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? AppColors.critical.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  initials,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            patient.displayName,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            patient.status,
                            style: AppTextStyles.label
                                .copyWith(color: _statusColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${patient.appointments.length} appointment${patient.appointments.length == 1 ? '' : 's'}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (patient.age != null)
                InfoPill(label: 'AGE', value: '${patient.age} yrs'),
              if (patient.age != null) const SizedBox(width: 12),
              InfoPill(label: 'LAST VISIT', value: patient.lastVisitDisplay),
              if (bloodType != null) ...[
                const SizedBox(width: 12),
                InfoPill(label: 'BLOOD', value: bloodType),
              ],
            ],
          ),
          if (allergiesCount > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 12, color: AppColors.critical),
                const SizedBox(width: 4),
                Text(
                  '$allergiesCount allerg${allergiesCount == 1 ? 'y' : 'ies'}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.critical),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (isCritical) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.warning_amber_rounded,
                    size: 16, color: AppColors.critical),
                label: Text(
                  '! Emergency Actions',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.critical,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.critical.withOpacity(0.4)),
                  backgroundColor: AppColors.criticalLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.patientDetailScreen,
                  arguments: patient,
                );
              },
              icon: const Icon(Icons.history_rounded,
                  size: 16, color: AppColors.primary),
              label: Text(
                'View Full History',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
