import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              _buildGreeting(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildTodaySchedule(),
              const SizedBox(height: 16),
              _buildVitalsOverview(),
              const SizedBox(height: 16),
              _buildTrendsCard(),
              // const SizedBox(height: 16),
              // _buildIntakeCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: AppColors.primary,
      //   shape: const CircleBorder(),
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, Dr.Rowan',
          style: AppTextStyles.body.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text('Clinical Overview', style: AppTextStyles.heading1),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Text(
            'Quick search patient records...',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: "TODAY'S PATIENTS",
                value: '12',
                // trend: '↑ 24% from yesterday',
                trendPositive: true,
                icon: Icons.people_rounded,
                iconBg: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'PENDING REQUESTS',
                value: '08',
                showBar: true,
                icon: Icons.pending_actions_rounded,
                iconBg: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // _StatCard(
        //   label: "TODAY'S REVENUE",
        //   value: '\$2,480',
        //   subtitle: '4 Unbilled sessions',
        //   icon: Icons.payments_rounded,
        //   iconBg: AppColors.primary,
        //   fullWidth: true,
        // ),
      ],
    );
  }

  Widget _buildTodaySchedule() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text("Today's Schedule", style: AppTextStyles.heading3),
                  ],
                ),
                Text(
                  'View Full Gantt',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _AppointmentItem(
            time: '09:30\nAM',
            name: 'Sarah Jenkins',
            procedure: 'Post-Op Review: Dental Implant Recovery',
            showStart: true,
            isHighlighted: true,
          ),
          const Divider(height: 1, color: AppColors.border),
          _AppointmentItem(
            time: '10:15\nAM',
            name: 'Michael Ross',
            procedure: 'Annual Prophylaxis & Examination',
            showActions: true,
          ),
          const Divider(height: 1, color: AppColors.border),
          _AppointmentItem(
            time: '11:00\nAM',
            name: 'Elena Rodriguez',
            procedure: 'Consultation: Orthodontic Assessment',
            showActions: true,
          ),
          const Divider(height: 1, color: AppColors.border),
          _AppointmentItem(
            time: '02:30\nPM',
            name: 'Arthur P. Fleck',
            procedure: 'Emergency: Acute Pulpitis Treatment',
            showUrgent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsOverview() {
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
          Text('Vitals Overview', style: AppTextStyles.heading3),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety_rounded,
                      color: AppColors.tealLight, size: 20),
                  const SizedBox(width: 8),
                  Text('Clinical Capacity', style: AppTextStyles.body),
                ],
              ),
              Text(
                '82%',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.stable, size: 20),
                  const SizedBox(width: 8),
                  Text('Completed', style: AppTextStyles.body),
                ],
              ),
              Text(
                '04/12',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsCard() {
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
          Text('Trends This Week', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Bar(height: 0.5),
                _Bar(height: 0.6),
                _Bar(height: 0.45),
                _Bar(height: 0.7),
                _Bar(height: 0.55),
                _Bar(height: 0.65),
                _Bar(height: 1.0, isActive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Patient Intake',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Review and approve 3 new patient registrations from the portal.',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Open Intake Queue',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final bool trendPositive;
  final String? subtitle;
  final bool showBar;
  final IconData icon;
  final Color iconBg;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.value,
    this.trend,
    this.trendPositive = false,
    this.subtitle,
    this.showBar = false,
    required this.icon,
    required this.iconBg,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    trend!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          trendPositive ? AppColors.stable : AppColors.critical,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (showBar) ...[
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final String time;
  final String name;
  final String procedure;
  final bool showStart;
  final bool showActions;
  final bool showUrgent;
  final bool isHighlighted;

  const _AppointmentItem({
    required this.time,
    required this.name,
    required this.procedure,
    this.showStart = false,
    this.showActions = false,
    this.showUrgent = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isHighlighted ? AppColors.primary.withOpacity(0.03) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (isHighlighted)
            Container(
              width: 3,
              height: 50,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(procedure, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (showStart)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Start\nVisit',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (showActions)
            Row(
              children: [
                const Icon(Icons.receipt_outlined,
                    color: AppColors.textMuted, size: 18),
                const SizedBox(width: 8),
                const Icon(Icons.more_vert,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
          if (showUrgent)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.urgentLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'URGENT',
                    style:
                        AppTextStyles.label.copyWith(color: AppColors.urgent),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.more_vert,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final bool isActive;

  const _Bar({required this.height, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 60 * height,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
