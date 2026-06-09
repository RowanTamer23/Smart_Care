import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/section_header.dart';
import 'package:smart_care/features/patient/profile/view/widgets/doc_card.dart';

class DocumentsSection extends StatelessWidget {
  final List<MedicalRecord> records;

  const DocumentsSection({super.key, required this.records});

  /// Map a record type to display metadata (icon, label, colours).
  static _DocMeta _metaFor(String type) {
    switch (type) {
      case 'surgery':
        return const _DocMeta(Icons.medical_services_rounded, 'Surgery Report', C.red, C.redLight);
      case 'prescription':
        return const _DocMeta(Icons.description_rounded, 'Prescription', C.blue, C.blueLight);
      case 'lab':
        return const _DocMeta(Icons.science_rounded, 'Lab Report', C.purple, C.purpleLight);
      case 'visit':
      default:
        return const _DocMeta(Icons.local_hospital_rounded, 'Visit Report', C.teal, C.tealLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    // All non-lab records are treated as documents.
    final docRecords = records.where((r) => r.recordType != 'lab').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          'Documents & Reports',
          icon: Icons.folder_rounded,
          color: C.amber,
        ),
        const SizedBox(height: 12),
        if (docRecords.isEmpty)
          _EmptyDocState()
        else
          _DocGrid(records: docRecords),
      ],
    );
  }
}

class _DocMeta {
  final IconData icon;
  final String label;
  final Color color, bg;
  const _DocMeta(this.icon, this.label, this.color, this.bg);
}

class _EmptyDocState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: C.amberLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded, color: C.amber, size: 26),
          ),
          const SizedBox(height: 12),
          Text('No documents yet', style: bTextStyle(14, w: FontWeight.w600, c: C.txt2)),
          const SizedBox(height: 4),
          Text('Medical records will appear here', style: bTextStyle(12, c: C.txt3)),
        ],
      ),
    );
  }
}

class _DocGrid extends StatelessWidget {
  final List<MedicalRecord> records;

  const _DocGrid({required this.records});

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (int i = 0; i < records.length; i += 2) {
      final left = records[i];
      final metaLeft = DocumentsSection._metaFor(left.recordType);

      Widget rightWidget;
      if (i + 1 < records.length) {
        final right = records[i + 1];
        final metaRight = DocumentsSection._metaFor(right.recordType);
        rightWidget = Expanded(
          child: DocCard(
            metaRight.icon,
            right.diagnosis ?? metaRight.label,
            _fmtDate(right.recordDate),
            metaRight.color,
            metaRight.bg,
          ),
        );
      } else {
        rightWidget = const Expanded(child: SizedBox.shrink());
      }

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DocCard(
                metaLeft.icon,
                left.diagnosis ?? metaLeft.label,
                _fmtDate(left.recordDate),
                metaLeft.color,
                metaLeft.bg,
              ),
            ),
            const SizedBox(width: 10),
            rightWidget,
          ],
        ),
      );

      if (i + 2 < records.length) {
        rows.add(const SizedBox(height: 10));
      }
    }

    return Column(children: rows);
  }
}
