import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/theme3.dart';

// ── Bottom Navigation ──────────────────────────────────────────────────────
class CPBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CPBottomNav(
      {super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.calendar_today_rounded, 'Schedule'),
    (Icons.medical_services_rounded, 'Doctors'),
    (Icons.folder_rounded, 'Records'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, -6))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 44,
                        height: 30,
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(_items[i].$1,
                            size: 19,
                            color: active ? Colors.white : AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(_items[i].$2,
                          style: AppText.label(
                              color: active
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              size: 10)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────
class CPSearchBar extends StatelessWidget {
  final String hint;
  final Widget? trailing;
  const CPSearchBar({super.key, required this.hint, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child:
                Text(hint, style: AppText.body(14, color: AppColors.textMuted)),
          ),
          if (trailing != null) ...[trailing!, const SizedBox(width: 12)],
        ],
      ),
    );
  }
}

// ── Pill chip ──────────────────────────────────────────────────────────────
class CPChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const CPChip(
      {super.key, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppText.body(13,
              color: active ? Colors.white : AppColors.textSecondary,
              weight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Star Rating ────────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const StarRating({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i < rating.floor();
        return Icon(
          full ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: AppColors.accent,
        );
      }),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(
      {super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.display(16)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: AppText.body(13,
                    color: AppColors.primary, weight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ── Stat Badge ────────────────────────────────────────────────────────────
class StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bg;
  const StatBadge(
      {super.key,
      required this.value,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value, style: AppText.display(18, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppText.label(color: color.withOpacity(0.7))),
        ],
      ),
    );
  }
}
