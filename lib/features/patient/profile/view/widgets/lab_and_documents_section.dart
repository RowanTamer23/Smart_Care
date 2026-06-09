import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/lab_results_section.dart';
import 'package:smart_care/features/patient/profile/view/widgets/documents_section.dart';

/// A combined section that shows a segment control switching between
/// "Lab Results" and "Documents & Reports", both driven from [records].
class LabAndDocumentsSection extends StatefulWidget {
  final List<MedicalRecord> records;

  const LabAndDocumentsSection({super.key, required this.records});

  @override
  State<LabAndDocumentsSection> createState() => _LabAndDocumentsSectionState();
}

class _LabAndDocumentsSectionState extends State<LabAndDocumentsSection>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final labCount = widget.records.where((r) => r.recordType == 'lab').length;
    final docCount = widget.records.where((r) => r.recordType != 'lab').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Segment control header ────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.border),
          ),
          child: Row(
            children: [
              _SegmentTab(
                icon: Icons.science_rounded,
                label: 'Lab Results',
                count: labCount,
                color: C.purple,
                isSelected: _selectedIndex == 0,
                isFirst: true,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _SegmentTab(
                icon: Icons.folder_rounded,
                label: 'Documents',
                count: docCount,
                color: C.amber,
                isSelected: _selectedIndex == 1,
                isFirst: false,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Content ───────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _selectedIndex == 0
              ? KeyedSubtree(
                  key: const ValueKey('lab'),
                  child: LabResultsSection(records: widget.records),
                )
              : KeyedSubtree(
                  key: const ValueKey('docs'),
                  child: DocumentsSection(records: widget.records),
                ),
        ),
      ],
    );
  }
}

// ─── Internal segment tab ───────────────────────────────────────────────────

class _SegmentTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final bool isFirst;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isFirst
        ? const BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          );

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 0.9,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected ? color : C.txt3,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: bTextStyle(
                  13,
                  w: isSelected ? FontWeight.w700 : FontWeight.w500,
                  c: isSelected ? color : C.txt3,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? color : C.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: lblTextStyle(
                      s: 10,
                      w: FontWeight.w700,
                      c: isSelected ? Colors.white : C.txt3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
