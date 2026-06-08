import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 25;

  static const List<(String, int)> _days = [
    ('MON', 23),
    ('TUE', 24),
    ('WED', 25),
    ('THU', 26),
    ('FRI', 27),
    ('SAT', 28),
    ('SUN', 29),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCalendarHeader(),
              _buildWeekStrip(),
              _buildTodayLoad(),
              _buildScheduleList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('October', style: AppTextStyles.heading1),
              Text('2023',
                  style: AppTextStyles.heading2
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          Row(
            children: [
              _NavArrow(icon: Icons.chevron_left, onTap: () {}),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('Today',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              _NavArrow(icon: Icons.chevron_right, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _days.map((d) {
          final dayLabel = d.$1;
          final dayNum = d.$2;
          final isSelected = dayNum == _selectedDay;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = dayNum),
            child: Column(
              children: [
                Text(
                  dayLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.accent : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$dayNum',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                    height: 4,
                    child: isSelected
                        ? const Icon(Icons.circle,
                            size: 5, color: AppColors.accent)
                        : const SizedBox()),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTodayLoad() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's Load",
                  style: AppTextStyles.body.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('12 Appointments',
                  style: AppTextStyles.heading2.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text('4 High-priority',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: const Text('Create New\nAppointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Schedule for Oct 25', style: AppTextStyles.heading3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text('Wednesday',
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.tune,
                        size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ScheduleItem(
            time: '09:00',
            name: 'Eleanor Shellstrop',
            typeProcedure: 'Follow-up • Dental Cleaning',
            isCompleted: true,
            hasAvatar: true,
            avatarLetter: 'E',
          ),
          _ScheduleItem(
            time: '10:30',
            name: 'Chidi Anagonye',
            typeProcedure: 'Check-up • Chronic Pain Consultation',
            // isUrgent: true,
            hasAction: true,
            hasAvatar: true,
            avatarLetter: 'C',
          ),
          _ScheduleItem(
            time: '11:15',
            name: 'Tahani Al-Jamil',
            typeProcedure: 'Check-up • Orthodontic Review',
            // showHistory: true,
            hasAvatar: true,
            avatarLetter: 'T',
          ),
          _ScheduleItem(
            time: '14:00',
            name: 'Jason Mendoza',
            typeProcedure: 'Post-Op Check',
            showEdit: true,
            hasAvatar: true,
            avatarLetter: 'J',
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String name;
  final String typeProcedure;
  final bool isCompleted;
  final bool isUrgent;
  final bool hasAction;
  final bool showHistory;
  final bool showEdit;
  final bool hasAvatar;
  final String avatarLetter;

  const _ScheduleItem({
    required this.time,
    required this.name,
    required this.typeProcedure,
    this.isCompleted = false,
    this.isUrgent = false,
    this.hasAction = false,
    this.showHistory = false,
    this.showEdit = false,
    required this.hasAvatar,
    required this.avatarLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isUrgent ? AppColors.critical.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            time,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          if (hasAvatar)
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                avatarLetter,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.textMuted, size: 22),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(typeProcedure, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.stableLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 12, color: AppColors.stable),
                  const SizedBox(width: 4),
                  Text('Completed',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.stable)),
                ],
              ),
            ),
          if (isUrgent) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.criticalLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('URGENT',
                  style:
                      AppTextStyles.label.copyWith(color: AppColors.critical)),
            ),
            if (hasAction) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sta\nConsult',
                  style: AppTextStyles.label
                      .copyWith(color: Colors.white, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
          if (showHistory)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Patient\nHistory',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
          if (showEdit)
            const Icon(Icons.edit_outlined,
                size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
