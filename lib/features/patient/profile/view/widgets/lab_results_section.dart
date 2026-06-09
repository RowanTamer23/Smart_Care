import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_card.dart';
import 'package:smart_care/features/patient/profile/view/widgets/section_header.dart';
import 'package:smart_care/features/patient/profile/view/widgets/lab_row.dart';

class LabResultsSection extends StatelessWidget {
  final List<MedicalRecord> records;

  const LabResultsSection({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final labRecords = records.where((r) => r.recordType == 'lab').toList();
    if (labRecords.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          'Recent Lab Results',
          icon: Icons.science_rounded,
          color: C.purple,
        ),
        const SizedBox(height: 12),
        ProfileCard(
          padding: 0,
          child: Column(
            children: labRecords.expand((r) {
              final testName = r.diagnosis ?? 'Lab Test';
              final testVal = r.treatment ?? 'Results Pending';
              final refRange = r.notes ?? 'Standard range';
              
              // Read status from doctorNotes (which we populate in AddEditMedicalRecordDialog)
              final rawStatus = r.doctorNotes?.toLowerCase() ?? 'normal';
              final status = LabStatus.values.firstWhere(
                (e) => e.name == rawStatus,
                orElse: () => LabStatus.normal,
              );

              return [
                LabRow(testName, testVal, refRange, status),
                if (r != labRecords.last)
                  const Divider(
                    height: 1,
                    color: C.border,
                    indent: 16,
                    endIndent: 16,
                  ),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }
}
