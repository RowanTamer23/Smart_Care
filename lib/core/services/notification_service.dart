import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:smart_care/core/database/cache_helper.dart';
import 'package:smart_care/features/patient/profile/data/model/notification_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ValueNotifier<List<NotificationModel>> notificationsNotifier =
      ValueNotifier<List<NotificationModel>>([]);

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      try {
        // Fallback in case device timezone fails
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked with payload: ${details.payload}');
        },
      );

      // Request permissions for newer Android/iOS versions
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Load cached notifications history
      _loadNotificationsFromCache();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  void _loadNotificationsFromCache() {
    try {
      final jsonStr = CacheHelper().getDataString(key: 'notifications_history');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as List<dynamic>;
        final list = decoded
            .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notificationsNotifier.value = list;
      }
    } catch (e) {
      debugPrint('Error loading notifications cache: $e');
    }
  }

  Future<void> _saveNotificationsToCache() async {
    try {
      final list = notificationsNotifier.value;
      final encoded = jsonEncode(list.map((e) => e.toMap()).toList());
      await CacheHelper()
          .saveData(key: 'notifications_history', value: encoded);
    } catch (e) {
      debugPrint('Error saving notifications cache: $e');
    }
  }

  Future<void> addNotificationToHistory({
    required String title,
    required String body,
    required String type,
    String? refId,
  }) async {
    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          Random().nextInt(1000).toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      refId: refId,
    );

    final updatedList =
        List<NotificationModel>.from(notificationsNotifier.value);
    updatedList.insert(0, newNotification);
    notificationsNotifier.value = updatedList;
    await _saveNotificationsToCache();
  }

  Future<void> addNotificationToHistoryWithTime({
    required String id,
    required String title,
    required String body,
    required String type,
    required DateTime timestamp,
    String? refId,
  }) async {
    final exists = notificationsNotifier.value.any((n) =>
        n.title == title &&
        n.body == body &&
        n.timestamp.year == timestamp.year &&
        n.timestamp.month == timestamp.month &&
        n.timestamp.day == timestamp.day &&
        n.timestamp.hour == timestamp.hour &&
        n.timestamp.minute == timestamp.minute);

    if (exists) return;

    final newNotification = NotificationModel(
      id: id + '_' + DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      isRead: false,
      refId: refId,
    );

    final updatedList =
        List<NotificationModel>.from(notificationsNotifier.value);
    updatedList.insert(0, newNotification);
    updatedList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notificationsNotifier.value = updatedList;
    await _saveNotificationsToCache();
  }

  Future<void> markAsRead(String id) async {
    final updatedList = notificationsNotifier.value.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    notificationsNotifier.value = updatedList;
    await _saveNotificationsToCache();
  }

  Future<void> markAllAsRead() async {
    final updatedList = notificationsNotifier.value.map((n) {
      return n.copyWith(isRead: true);
    }).toList();
    notificationsNotifier.value = updatedList;
    await _saveNotificationsToCache();
  }

  Future<void> clearAll() async {
    notificationsNotifier.value = [];
    await _saveNotificationsToCache();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    required String type,
    String? refId,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'smart_care_instant_channel',
        'Smart Care Instant Alerts',
        channelDescription: 'Immediate alerts and push notices',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final int notifyId = Random().nextInt(100000);
      await _localNotifications.show(
        notifyId,
        title,
        body,
        platformChannelSpecifics,
        payload: type,
      );

      await addNotificationToHistory(
        title: title,
        body: body,
        type: type,
        refId: refId,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String type,
    String? refId,
  }) async {
    try {
      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) return;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'smart_care_scheduled_channel',
        'Smart Care Reminders',
        channelDescription: 'Scheduled alarms for medicine and visits',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // Convert local DateTime to tz.TZDateTime using UTC-aligned scheduling
      final tzDateTime = tz.TZDateTime.from(scheduledTime.toUtc(), tz.UTC);

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: type,
      );

      await addNotificationToHistoryWithTime(
        id: id.toString(),
        title: title,
        body: body,
        type: type,
        timestamp: scheduledTime,
        refId: refId,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  void scheduleMedicineReminders(List<MedicalReminder> reminders) {
    try {
      final today = DateTime.now();
      // Only get reminders matching today
      final todayReminders =
          reminders.where((r) => r.isScheduledForDate(today)).toList();

      for (var reminder in todayReminders) {
        final timeOfDay = reminder.reminderTime;
        final reminderDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );

        final now = DateTime.now();
        if (reminderDateTime.isAfter(now)) {
          final notifyId = reminder.id.hashCode;
          scheduleNotification(
            id: notifyId,
            title: 'Medicine Reminder: ${reminder.medicineName}',
            body:
                'Dose: ${reminder.rawDosage.isEmpty ? "Take as prescribed" : reminder.rawDosage}',
            scheduledTime: reminderDateTime,
            type: 'medicine',
            refId: reminder.id,
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling medicine reminders: $e');
    }
  }

  void scheduleAppointmentNotifications(List<Appointment> appointments) {
    try {
      final now = DateTime.now();

      for (var appt in appointments) {
        if (appt.status != AppointmentStatus.confirmed &&
            appt.status != AppointmentStatus.pending) {
          continue;
        }

        final timeOfDay = appt.appointmentTime;
        final apptDateTime = DateTime(
          appt.appointmentDate.year,
          appt.appointmentDate.month,
          appt.appointmentDate.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );

        if (apptDateTime.isBefore(now)) continue;

        final doctorName = appt.doctorName ?? 'Doctor';
        final notifyIdBase = appt.id.hashCode;

        // Notification exactly at start time
        scheduleNotification(
          id: notifyIdBase,
          title: 'Appointment Starting Now',
          body: 'Your check-up with Dr. $doctorName starts now.',
          scheduledTime: apptDateTime,
          type: 'appointment',
          refId: appt.id,
        );

        // Notification 10 minutes prior
        final tenMinsBefore =
            apptDateTime.subtract(const Duration(minutes: 10));
        if (tenMinsBefore.isAfter(now)) {
          scheduleNotification(
            id: notifyIdBase + 1,
            title: 'Upcoming Appointment in 10 mins',
            body:
                'Reminder: Check-up with Dr. $doctorName starts in 10 minutes.',
            scheduledTime: tenMinsBefore,
            type: 'appointment',
            refId: appt.id,
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling appointment notifications: $e');
    }
  }
}
