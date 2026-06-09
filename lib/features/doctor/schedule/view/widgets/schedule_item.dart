import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class ScheduleItem extends StatelessWidget {
  final String time;
  final String name;
  final String typeProcedure;
  final bool isCompleted;
  final bool isConfirmed;
  final bool isPending;
  final bool isCancelled;
  final bool isUrgent;
  final bool hasAction;
  final bool showHistory;
  final bool showEdit;
  final bool hasAvatar;
  final String avatarLetter;
  final VoidCallback? onChatTap;

  const ScheduleItem({
    super.key,
    required this.time,
    required this.name,
    required this.typeProcedure,
    this.isCompleted = false,
    this.isConfirmed = false,
    this.isPending = false,
    this.isCancelled = false,
    this.isUrgent = false,
    this.hasAction = false,
    this.showHistory = false,
    this.showEdit = false,
    required this.hasAvatar,
    required this.avatarLetter,
    this.onChatTap,
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
          color: isUrgent
              ? AppColors.critical.withValues(alpha: 0.3)
              : AppColors.border,
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
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
          const SizedBox(width: 8),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (isCompleted) ...[
              const SizedBox(width: 8),
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
            ],
            if (isConfirmed) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 156, 55)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Confirmed',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
            if (isPending) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.followUpLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_empty_rounded,
                        size: 12, color: AppColors.followUp),
                    const SizedBox(width: 4),
                    Text('Pending',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.followUp)),
                  ],
                ),
              ),
            ],
            if (isCancelled) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.criticalLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel_outlined,
                        size: 12, color: AppColors.critical),
                    const SizedBox(width: 4),
                    Text('Cancelled',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.critical)),
                  ],
                ),
              ),
            ],
            if (isUrgent) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.criticalLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('URGENT',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.critical)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            // Chat button — tappable
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onChatTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: onChatTap != null
                      ? AppColors.primary.withValues(alpha: 0.10)
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: onChatTap != null
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Chat',
                      style: AppTextStyles.label.copyWith(
                        color: onChatTap != null
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
