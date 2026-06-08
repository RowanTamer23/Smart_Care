import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';

class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const MenuItem({required this.icon, required this.label, this.onTap});
}

Widget buildSection(String title, List<MenuItem> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 18, color: AppColors.primary),
                  ),
                  title: Text(item.label,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textMuted),
                  onTap: item.onTap,
                ),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 64, color: AppColors.border),
              ],
            );
          }).toList(),
        ),
      ),
    ],
  );
}
