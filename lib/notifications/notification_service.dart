import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Wraps flutter_local_notifications for target-reached, milestone,
/// and daily-reminder notifications.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'mantra_counter';
  static const _channelName = 'Mantra Counter';
  static const _channelDescription = 'Session and streak notifications';

  /// Call once during app bootstrap.
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Request permission on iOS
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Immediate notification when session target is reached.
  static Future<void> showTargetReached({
    required String mantraName,
    required int count,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      0, // notification id
      'Target Reached! 🙏',
      '$mantraName — $count chants completed',
      details,
    );
  }

  /// Notification for lifetime milestones (e.g. 1 000, 10 000).
  static Future<void> showMilestone(int lifetimeCount) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      1,
      'Milestone! ✨',
      '$lifetimeCount lifetime chants across all mantras',
      details,
    );
  }

  /// Schedule (or reschedule) the daily chanting reminder.
  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Cancel existing daily reminder
    await _plugin.cancel(99);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    // If the time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      99,
      'Time to Chant 🙏',
      'Start your daily mantra practice',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
