import 'package:flutter/material.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/core/services/notification_service.dart';
import 'package:smart_care/features/patient/profile/data/model/notification_model.dart';

class SmartCareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmartCareAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            'Smart-Care',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<List<NotificationModel>>(
          valueListenable: NotificationService().notificationsNotifier,
          builder: (context, notifications, _) {
            final unreadCount = notifications
                .where((n) => !n.isRead && n.timestamp.isBefore(DateTime.now()))
                .length;
            return IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimary, size: 24),
                  if (unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.critical,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.notificationScreen);
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child:
                const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
