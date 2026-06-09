import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_card.dart';
import 'package:smart_care/features/patient/profile/view/widgets/section_header.dart';
import 'package:smart_care/features/patient/profile/view/widgets/history_item.dart';
import 'package:smart_care/features/patient/profile/view/widgets/add_edit_medical_record_dialog.dart';

class MedicalHistorySection extends StatelessWidget {
  final PatientProfile profile;
  final List<MedicalRecord> records;

  const MedicalHistorySection({
    super.key,
    required this.profile,
    required this.records,
  });

  void _showAddEditMedicalRecordDialog(
      BuildContext context, String patientProfileId, MedicalRecord? record) {
    showDialog(
      context: context,
      builder: (context) => AddEditMedicalRecordDialog(
        patientProfileId: patientProfileId,
        record: record,
      ),
    );
  }

  Widget _buildConditions(BuildContext context, PatientProfile profile, List<MedicalRecord> records) {
    final conditionRecords = records
        .where((r) => r.recordType == 'visit' || r.recordType == 'condition')
        .toList();
    final List<Map<String, dynamic>> items = [];

    // Add chronic diseases from patient profile
    for (final cd in profile.chronicDiseases) {
      items.add({
        'name': cd,
        'year': 'Chronic',
        'note': 'Logged in patient profile',
        'record': null,
      });
    }

    // Add medical records that are conditions/visits
    for (final r in conditionRecords) {
      if (r.diagnosis != null && r.diagnosis!.isNotEmpty) {
        items.add({
          'name': r.diagnosis!,
          'year': '${r.recordDate.year}',
          'note': r.treatment ?? r.symptoms ?? 'No details provided',
          'record': r,
        });
      }
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No health conditions logged yet.',
            style: bTextStyle(13, c: C.txt2),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final record = item['record'] as MedicalRecord?;
        return HistoryItem(
          item['name']!,
          item['year']!,
          C.blue,
          item['note']!,
          onEdit: record != null
              ? () => _showAddEditMedicalRecordDialog(context, profile.id, record)
              : null,
        );
      },
    );
  }

  Widget _buildSurgeries(BuildContext context, String patientProfileId, List<MedicalRecord> records) {
    final surgeryRecords =
        records.where((r) => r.recordType == 'surgery').toList();

    if (surgeryRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No surgeries logged yet.',
            style: bTextStyle(13, c: C.txt2),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: surgeryRecords.length,
      itemBuilder: (context, index) {
        final r = surgeryRecords[index];
        return HistoryItem(
          r.diagnosis ?? r.treatment ?? 'Surgery',
          '${r.recordDate.year}',
          C.orange,
          r.notes ?? 'No additional details',
          onEdit: () =>
              _showAddEditMedicalRecordDialog(context, patientProfileId, r),
        );
      },
    );
  }

  Widget _buildFamilyHistory() {
    final items = [
      ('Father — Heart Disease', 'Paternal', C.red, 'Diagnosed at 58'),
      ('Mother — Type 2 Diabetes', 'Maternal', C.blue, 'Managed with insulin'),
      ('Grandfather — Hypertension', 'Paternal', C.orange, 'Stroke history'),
    ];
    return ListView(
      children: items.map((e) => HistoryItem(e.$1, e.$2, e.$3, e.$4)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Medical History',
          icon: Icons.history_edu_rounded,
          color: C.teal,
          action: 'Add Record',
          onAction: () =>
              _showAddEditMedicalRecordDialog(context, profile.id, null),
        ),
        const SizedBox(height: 12),
        DefaultTabController(
          length: 3,
          child: ProfileCard(
            child: Column(
              children: [
                TabBar(
                  labelColor: C.primary,
                  unselectedLabelColor: C.txt3,
                  indicatorColor: C.teal,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: C.border,
                  labelStyle: bTextStyle(13, w: FontWeight.w700),
                  unselectedLabelStyle: bTextStyle(13),
                  tabs: const [
                    Tab(text: 'Conditions'),
                    Tab(text: 'Surgeries'),
                    Tab(text: 'Family'),
                  ],
                ),
                SizedBox(
                  height: 150, // Expanded slightly for better scrollability
                  child: TabBarView(
                    children: [
                      _buildConditions(context, profile, records),
                      _buildSurgeries(context, profile.id, records),
                      _buildFamilyHistory(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
