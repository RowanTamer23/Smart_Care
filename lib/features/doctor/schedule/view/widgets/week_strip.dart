import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class WeekStrip extends StatelessWidget {
  final List<(String, DateTime)> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeekStrip({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
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
        children: days.map((d) {
          final dayLabel = d.$1;
          final date = d.$2;
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          return GestureDetector(
            onTap: () => onDateSelected(date),
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
                    '${date.day}',
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
}
