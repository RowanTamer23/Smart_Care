import 'package:flutter/material.dart';
import 'package:smart_care/core/services/notification_service.dart';
import 'package:smart_care/features/patient/profile/data/model/notification_model.dart';
import 'package:smart_care/features/patient/theme3.dart';
import 'package:smart_care/features/doctor/home/view/screens/main_layout.dart';

class NotificationScreen extends StatefulWidget {
  final String role;
  const NotificationScreen({super.key, this.role = 'patient'});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatElapsedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppText.display(18, color: AppColors.textPrimary),
        ),
        actions: [
          ValueListenableBuilder<List<NotificationModel>>(
            valueListenable: _notificationService.notificationsNotifier,
            builder: (context, notifications, _) {
              if (notifications.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (value) {
                  if (value == 'read_all') {
                    _notificationService.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All notifications marked as read.')),
                    );
                  } else if (value == 'clear_all') {
                    _notificationService.clearAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification history cleared.')),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'read_all',
                    child: Row(
                      children: [
                        const Icon(Icons.mark_chat_read_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Mark all as read', style: AppText.body(13, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.red),
                        const SizedBox(width: 8),
                        Text('Clear all history', style: AppText.body(13, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        bottom: widget.role == 'doctor'
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppText.label(size: 12, weight: FontWeight.bold),
                    unselectedLabelStyle: AppText.label(size: 12, weight: FontWeight.normal),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Medicine'),
                      Tab(text: 'Visits'),
                    ],
                  ),
                ),
              ),
      ),
      body: ValueListenableBuilder<List<NotificationModel>>(
        valueListenable: _notificationService.notificationsNotifier,
        builder: (context, allNotifications, _) {
          final activeNotifications = allNotifications
              .where((n) => n.timestamp.isBefore(DateTime.now()))
              .toList();

          if (widget.role == 'doctor') {
            final doctorNotifications = activeNotifications
                .where((n) => n.type == 'appointment')
                .toList();
            return _buildNotificationList(doctorNotifications);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(activeNotifications),
              _buildNotificationList(
                activeNotifications.where((n) => n.type == 'medicine').toList(),
              ),
              _buildNotificationList(
                activeNotifications.where((n) => n.type == 'appointment').toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'All caught up!',
              style: AppText.display(16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'No new notifications to display.',
              style: AppText.body(13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = notifications[index];
        final isMedicine = item.type == 'medicine';

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            // Remove from local list
            final updated = List<NotificationModel>.from(_notificationService.notificationsNotifier.value);
            updated.removeWhere((n) => n.id == item.id);
            _notificationService.notificationsNotifier.value = updated;
            _notificationService.clearAll().then((_) {
              // Re-save list to cache
              for (var rem in updated) {
                _notificationService.addNotificationToHistoryWithTime(
                  id: rem.id.split('_')[0],
                  title: rem.title,
                  body: rem.body,
                  type: rem.type,
                  timestamp: rem.timestamp,
                );
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification dismissed.')),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
          ),
          child: GestureDetector(
            onTap: () {
              if (!item.isRead) {
                _notificationService.markAsRead(item.id);
              }
              if (item.type == 'medicine') {
                MainLayout.mainLayoutTabNotifier.value = 3; // Switch to Profile Screen
                Navigator.pop(context); // Go back to Home Layout
              } else if (item.type == 'appointment') {
                MainLayout.mainLayoutTabNotifier.value = 1; // Switch to Schedule Screen
                Navigator.pop(context); // Go back to Home Layout
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.isRead ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isRead ? AppColors.border : AppColors.primary.withOpacity(0.15),
                  width: item.isRead ? 1 : 1.5,
                ),
                boxShadow: item.isRead
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isMedicine
                          ? AppColors.accentLight
                          : AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMedicine ? Icons.medication_rounded : Icons.calendar_today_rounded,
                      color: isMedicine ? AppColors.accent : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isMedicine ? 'Medicine Alert' : 'Appointment Alert',
                              style: AppText.label(
                                color: isMedicine ? AppColors.accent : AppColors.primary,
                                size: 10,
                                weight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _formatElapsedTime(item.timestamp),
                              style: AppText.body(11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: AppText.display(14, color: AppColors.textPrimary, weight: item.isRead ? FontWeight.w600 : FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.body,
                          style: AppText.body(12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(top: 18),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
