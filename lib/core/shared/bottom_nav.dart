import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class SmartCareBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String role;

  const SmartCareBottomNav(
      {super.key,
      required this.currentIndex,
      required this.onTap,
      required this.role});

  @override
  Widget build(BuildContext context) {
    final items = role == "patient"
        ? [
            _NavItem(icon: Icons.grid_view_rounded, label: 'Home'),
            _NavItem(icon: Icons.calendar_today_rounded, label: 'Schedule'),
            _NavItem(icon: Icons.people_rounded, label: 'Doctors'),
            _NavItem(icon: Icons.inbox_rounded, label: 'Records'),
            _NavItem(icon: Icons.person_rounded, label: 'Profile'),
          ]
        : [
            _NavItem(icon: Icons.grid_view_rounded, label: 'Home'),
            _NavItem(icon: Icons.calendar_today_rounded, label: 'Schedule'),
            _NavItem(icon: Icons.people_rounded, label: 'Patients'),
            _NavItem(icon: Icons.inbox_rounded, label: 'Requests'),
            _NavItem(icon: Icons.person_rounded, label: 'Profile'),
          ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: isActive
                      ? BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index].icon,
                        size: 20,
                        color: isActive ? Colors.white : AppColors.textMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[index].label,
                        style: AppTextStyles.label.copyWith(
                          color: isActive ? Colors.white : AppColors.textMuted,
                        ),
                      ),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
