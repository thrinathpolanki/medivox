import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String channelId = 'medivox_reminders';
  static const String channelName = 'Medication Reminders';
  static const String channelDescription =
      'Reminders for your scheduled medicines';

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    // Payload is expected to be "medicineId|scheduleId"
    // In Phase 5 we just note the tap. In Phase 6 we'll navigate to the schedule.
    debugPrint('Notification tapped: ${response.payload} action: ${response.actionId}');
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('Background notification action: ${response.actionId}');
  }

  /// Schedule a single reminder. Idempotent for a given [doseId].
  static Future<void> scheduleReminder({
    required int notificationId,
    required DateTime scheduledAt,
    required String medicineName,
    required String dosage,
    required String foodInstruction,
    required String payload,
  }) async {
    if (!_initialized) await init();

    // Do not schedule in the past
    if (scheduledAt.isBefore(DateTime.now())) return;

    final foodText = {
      'before_food': 'before food',
      'after_food': 'after food',
      'with_food': 'with food',
      'as_prescribed': 'as prescribed',
    }[foodInstruction] ?? foodInstruction;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'taken',
          'Taken ✓',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          'Snooze 10m',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'skip',
          'Skip',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      notificationId,
      '💊 Time for $medicineName',
      'Take $dosage ($foodText). Tap to mark Taken.',
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> cancel(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> showInstant({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    await _plugin.show(
      999999,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }
}
