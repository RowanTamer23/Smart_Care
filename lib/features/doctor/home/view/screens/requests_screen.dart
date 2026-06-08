import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatusChips(),
              const SizedBox(height: 20),
              _buildSectionTitle('New Requests', hasFilter: true),
              const SizedBox(height: 12),
              _buildRequestCard(
                name: 'Elena Rodriguez',
                patientId: '#ER-9021',
                avatarColor: AppColors.tealLight,
                initials: 'ER',
                requestedTime: 'Today, 2:30 PM',
                reason: 'Post-Op Consultation',
                vitalKey: 'BP',
                vitalValue: '120/80',
              ),
              const SizedBox(height: 10),
              _buildRequestCard(
                name: 'Marcus Chen',
                patientId: '#MC-4452',
                avatarColor: AppColors.stable,
                initials: 'MC',
                requestedTime: 'Tomorrow, 9:00 AM',
                reason: 'Chronic Back Pain',
                vitalKey: 'HR',
                vitalValue: '72 bpm',
              ),
              const SizedBox(height: 10),
              _buildRequestCard(
                name: 'James Smith',
                patientId: '#JS-1120',
                avatarColor: AppColors.primaryLight,
                initials: 'JS',
                requestedTime: 'Nov 24, 11:15 AM',
                reason: 'Annual Physical',
                vitalKey: 'Temp',
                vitalValue: '98.6°F',
                showOnlyReschedule: true,
              ),
              const SizedBox(height: 20),
              _buildPendingFollowUps(),
              const SizedBox(height: 16),
              _buildScheduleTip(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appointment\nRequests', style: AppTextStyles.heading1),
        const SizedBox(height: 6),
        Text(
          'Manage incoming patient bookings and pending follow-up cases.',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatusChips() {
    return Row(
      children: [
        _StatusChip(label: '12 Pending', bgColor: AppColors.primary, textColor: Colors.white),
        const SizedBox(width: 8),
        _StatusChip(
          label: '4 Follow-ups',
          bgColor: AppColors.border,
          textColor: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool hasFilter = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        if (hasFilter)
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Filter', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            ],
          ),
      ],
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String patientId,
    required Color avatarColor,
    required String initials,
    required String requestedTime,
    required String reason,
    required String vitalKey,
    required String vitalValue,
    bool showOnlyReschedule = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColor.withOpacity(0.2),
                child: Text(
                  initials,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: avatarColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      'Patient ID: $patientId',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Requested Time', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    requestedTime,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(reason, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vitals', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    '$vitalKey: $vitalValue',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (!showOnlyReschedule) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Accept', style: AppTextStyles.body.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Reschedule',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingFollowUps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Pending Follow-ups', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 14),
          _FollowUpItem(
            icon: Icons.science_outlined,
            iconBg: AppColors.followUpLight,
            iconColor: AppColors.followUp,
            name: 'Sarah Jenkins',
            description: 'Bloodwork results review',
            dueLabel: 'DUE TODAY',
            dueColor: AppColors.critical,
          ),
          const Divider(height: 20, color: AppColors.border),
          _FollowUpItem(
            icon: Icons.medication_outlined,
            iconBg: AppColors.primaryLight.withOpacity(0.2),
            iconColor: AppColors.primaryLight,
            name: 'Robert Miller',
            description: 'Medication adjustment',
            dueLabel: 'DUE IN 2 DAYS',
            dueColor: AppColors.textMuted,
          ),
          const Divider(height: 20, color: AppColors.border),
          _FollowUpItem(
            icon: Icons.healing_outlined,
            iconBg: AppColors.stableLight,
            iconColor: AppColors.stable,
            name: 'Linda Thompson',
            description: 'Wound healing check',
            dueLabel: 'DUE IN 3 DAYS',
            dueColor: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'View All Follow-ups',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Tip',
            style: AppTextStyles.body.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have a high concentration of consultations tomorrow morning. Consider moving routine follow-ups to Wednesday afternoon to balance your workload.',
            style: AppTextStyles.body.copyWith(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Efficiency +12% this week',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _StatusChip({required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FollowUpItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String name;
  final String description;
  final String dueLabel;
  final Color dueColor;

  const _FollowUpItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.name,
    required this.description,
    required this.dueLabel,
    required this.dueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(description, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                dueLabel,
                style: AppTextStyles.label.copyWith(color: dueColor),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      ],
    );
  }
}
