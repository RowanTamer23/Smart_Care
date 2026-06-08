import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class PatientRecord {
  final String name;
  final String id;
  final int age;
  final String lastVisit;
  final String status;

  const PatientRecord({
    required this.name,
    required this.id,
    required this.age,
    required this.lastVisit,
    required this.status,
  });
}

const _patients = [
  PatientRecord(name: 'Elena Rodriguez', id: '#PX-8821', age: 34, lastVisit: 'Oct 12, 2023', status: 'STABLE'),
  PatientRecord(name: 'Marcus Chen', id: '#PX-3490', age: 52, lastVisit: 'Nov 05, 2023', status: 'FOLLOW-UP'),
  PatientRecord(name: 'Sarah Jenkins', id: '#PX-1120', age: 29, lastVisit: 'Just Now', status: 'CRITICAL'),
  PatientRecord(name: 'David Miller', id: '#PX-9923', age: 45, lastVisit: 'Oct 28, 2023', status: 'STABLE'),
  PatientRecord(name: 'Aria Varma', id: '#PX-5001', age: 19, lastVisit: 'Nov 02, 2023', status: 'FOLLOW-UP'),
  PatientRecord(name: 'Henry Thompson', id: '#PX-2298', age: 61, lastVisit: 'Sep 15, 2023', status: 'STABLE'),
  PatientRecord(name: 'Linda Wu', id: '#PX-7712', age: 42, lastVisit: 'Oct 01, 2023', status: 'STABLE'),
  PatientRecord(name: 'Robert King', id: '#PX-1045', age: 57, lastVisit: 'Nov 10, 2023', status: 'FOLLOW-UP'),
];

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _searchQuery = '';

  List<PatientRecord> get _filtered => _patients
      .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _PatientCard(patient: _filtered[index]),
              ),
            ),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Records', style: AppTextStyles.heading1),
          const SizedBox(height: 4),
          Text(
            'Manage and review secure patient health information with clinical precision.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search by name, ID, or DOB...',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Filters', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'New\nPatient',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageBtn(label: '<', onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '1', isActive: true, onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '2', onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '3', onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '...', onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '12', onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '>', onTap: () {}),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientRecord patient;
  const _PatientCard({required this.patient});

  Color get _statusColor {
    switch (patient.status) {
      case 'STABLE': return AppColors.stable;
      case 'FOLLOW-UP': return AppColors.followUp;
      case 'CRITICAL': return AppColors.critical;
      default: return AppColors.textMuted;
    }
  }

  Color get _statusBg {
    switch (patient.status) {
      case 'STABLE': return AppColors.stableLight;
      case 'FOLLOW-UP': return AppColors.followUpLight;
      case 'CRITICAL': return AppColors.criticalLight;
      default: return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = patient.status == 'CRITICAL';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical ? AppColors.critical.withOpacity(0.3) : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                patient.name,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  patient.status,
                  style: AppTextStyles.label.copyWith(color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${patient.id}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoPill(label: 'AGE', value: '${patient.age} Years'),
              const SizedBox(width: 24),
              _InfoPill(label: 'LAST VISIT', value: patient.lastVisit),
            ],
          ),
          const SizedBox(height: 12),
          if (isCritical) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.critical),
                label: Text(
                  '! Emergency Actions',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.critical,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.critical.withOpacity(0.4)),
                  backgroundColor: AppColors.criticalLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
              label: Text(
                'View History',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_rounded, size: 16, color: AppColors.textSecondary),
              label: Text(
                'Upload Report',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _PageBtn({required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
