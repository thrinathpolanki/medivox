import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.doseId,
    required this.title,
    required this.body,
    required this.at,
  });
  final int id;
  final String doseId;
  final String title, body;
  final DateTime at;
}

/// Stable 31-bit id for a dose (FNV-1a), identical in every isolate and run.
int notificationIdFor(String doseId) {
  var h = 0x811c9dc5;
  for (final c in doseId.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h & 0x7FFFFFFF;
}

abstract class NotificationGateway {
  static const testId = 1;

  Future<void> init({
    void Function(NotificationResponse)? onResponse,
    DidReceiveBackgroundNotificationResponseCallback? onBackground,
  });
  Future<bool> notificationsEnabled();
  Future<bool> requestNotifications();
  Future<bool> canScheduleExact();
  Future<void> requestExact();
  Future<void> schedule(ScheduledReminder r);
  Future<void> scheduleTest(DateTime at);
  Future<void> cancel(int id);
  Future<Set<int>> pendingIds();
  Future<String?> launchDoseId();
}

class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin])
      : _p = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _p;

  static const channelId = 'medivox_dose_reminders';
  bool _tzReady = false;

  Future<void> _initTz() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
    _tzReady = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init({
    void Function(NotificationResponse)? onResponse,
    DidReceiveBackgroundNotificationResponseCallback? onBackground,
  }) async {
    await _initTz();
    await _p.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackground,
    );
    await _android?.createNotificationChannel(const AndroidNotificationChannel(
      channelId,
      'Medicine reminders',
      description: 'Reminders to take your medicines',
      importance: Importance.max,
    ));
  }

  NotificationDetails _details({bool actions = true}) => NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Medicine reminders',
          channelDescription: 'Reminders to take your medicines',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.private,
          enableVibration: true,
          actions: actions
              ? const [
                  AndroidNotificationAction('taken', 'Taken', cancelNotification: true),
                  AndroidNotificationAction('snooze', 'Snooze', cancelNotification: true),
                  AndroidNotificationAction('skip', 'Skip', cancelNotification: true),
                ]
              : null,
        ),
      );

  @override
  Future<bool> notificationsEnabled() async => await _android?.areNotificationsEnabled() ?? false;
  @override
  Future<bool> requestNotifications() async =>
      await _android?.requestNotificationsPermission() ?? false;
  @override
  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? false;
  @override
  Future<void> requestExact() async {
    await _android?.requestExactAlarmsPermission();
  }

  Future<void> _zoned(int id, String title, String body, DateTime at, String? payload,
      {bool actions = true}) async {
    await _initTz();
    final exact = await canScheduleExact();
    await _p.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(at, tz.local),
      _details(actions: actions),
      androidScheduleMode:
          exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> schedule(ScheduledReminder r) async {
    if (!r.at.isAfter(DateTime.now())) return;
    await _zoned(r.id, r.title, r.body, r.at, r.doseId);
  }

  @override
  Future<void> scheduleTest(DateTime at) => _zoned(
      NotificationGateway.testId,
      'MediVox test reminder',
      'If you can see this, reminders can reach you on this phone.',
      at,
      null,
      actions: false);

  @override
  Future<void> cancel(int id) => _p.cancel(id);

  @override
  Future<Set<int>> pendingIds() async =>
      (await _p.pendingNotificationRequests()).map((e) => e.id).toSet();

  @override
  Future<String?> launchDoseId() async {
    final d = await _p.getNotificationAppLaunchDetails();
    if (d?.didNotificationLaunchApp != true) return null;
    final r = d!.notificationResponse;
    return r?.actionId == null ? r?.payload : null;
  }
}
