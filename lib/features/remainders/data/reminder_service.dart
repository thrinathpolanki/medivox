import 'dart:async';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../database/app_database.dart';
import '../domain/dose_models.dart';
import 'dose_repository.dart';
import 'notification_gateway.dart';

class ReminderPrefs {
  static const _snooze = 'reminders.snoozeMinutes';
  static const snoozeOptions = [5, 10, 15, 20];

  static Future<int> snoozeMinutes() async {
    final p = await SharedPreferences.getInstance();
    await p.reload(); // may have been changed by another isolate
    return p.getInt(_snooze) ?? 10;
  }

  static Future<void> setSnoozeMinutes(int m) async =>
      (await SharedPreferences.getInstance()).setInt(_snooze, m);
}

/// Explicit user actions on a dose. Used by in-app buttons AND by the
/// notification action buttons (Taken / Snooze / Skip).
class DoseActions {
  DoseActions(this._doses, this._gateway, {Future<int> Function()? snoozeMinutes})
      : _snoozeMinutes = snoozeMinutes ?? ReminderPrefs.snoozeMinutes;
  final DoseRepository _doses;
  final NotificationGateway _gateway;
  final Future<int> Function() _snoozeMinutes;

  Future<void> taken(String doseId) async {
    await _doses.setStatus(doseId, DoseStatus.taken);
    await _gateway.cancel(notificationIdFor(doseId));
  }

  Future<void> skipped(String doseId) async {
    await _doses.setStatus(doseId, DoseStatus.skipped);
    await _gateway.cancel(notificationIdFor(doseId));
  }

  Future<void> snooze(String doseId, {DateTime? now}) async {
    final item = await _doses.getItem(doseId);
    if (item == null) return;
    if (item.status != DoseStatus.pending && item.status != DoseStatus.snoozed) return;
    final n = now ?? DateTime.now();
    final minutes = await _snoozeMinutes();
    await _doses.setStatus(doseId, DoseStatus.snoozed, at: n);
    await _gateway.schedule(ScheduledReminder(
      id: notificationIdFor(doseId),
      doseId: doseId,
      title: ReminderText.title,
      body: ReminderText.body(item),
      at: n.add(Duration(minutes: minutes)),
    ));
  }

  Future<void> handle(String doseId, String action) async {
    switch (action) {
      case 'taken':
        await taken(doseId);
      case 'skip':
        await skipped(doseId);
      case 'snooze':
        await snooze(doseId);
    }
  }
}

/// Runs in a separate background isolate when a notification action button is
/// pressed while the app is not in the foreground.
@pragma('vm:entry-point')
Future<void> reminderBackgroundHandler(NotificationResponse r) async {
  DartPluginRegistrant.ensureInitialized();
  final action = r.actionId, doseId = r.payload;
  if (action == null || doseId == null) return;
  final db = AppDatabase.open();
  try {
    final gateway = LocalNotificationGateway();
    await gateway.init();
    await DoseActions(DoseRepository(db), gateway).handle(doseId, action);
  } finally {
    await db.close();
  }
}

class ReminderService {
  ReminderService({
    required this.doses,
    required this.gateway,
    Future<int> Function()? snoozeMinutes,
  }) {
    actions = DoseActions(doses, gateway, snoozeMinutes: snoozeMinutes);
  }
  final DoseRepository doses;
  final NotificationGateway gateway;
  late final DoseActions actions;

  /// Set by the app to open the reminder screen when a notification is tapped.
  void Function(String doseId)? onOpenDose;
  String? lastError;
  Future<void> _tail = Future.value();

  Future<void> start() async {
    try {
      await gateway.init(onResponse: _onResponse, onBackground: reminderBackgroundHandler);
      await resync();
    } catch (e) {
      lastError = 'Reminders could not start: $e';
    }
  }

  void _onResponse(NotificationResponse r) {
    final id = r.payload;
    if (id == null) return;
    if (r.actionId == null) {
      onOpenDose?.call(id);
    } else {
      unawaited(actions.handle(id, r.actionId!));
    }
  }

  Future<String?> launchDoseId() => gateway.launchDoseId();

  /// Re-plans doses and brings scheduled notifications in line with them.
  /// Safe to call often; calls run one after another.
  Future<void> resync({DateTime? now}) {
    final f = _tail.then((_) => _resync(now ?? DateTime.now()));
    _tail = f.catchError((_) {});
    return f;
  }

  Future<void> _resync(DateTime now) async {
    await doses.reconcile(now: now);
    final upcoming = await doses.upcomingPending(now, now.add(const Duration(days: 7)));
    final snoozedIds = (await doses.snoozedDoseIds()).map(notificationIdFor).toSet();
    final desired = {for (final d in upcoming) notificationIdFor(d.dose.doseId): d};

    for (final id in await gateway.pendingIds()) {
      if (id == NotificationGateway.testId) continue;
      if (!desired.containsKey(id) && !snoozedIds.contains(id)) await gateway.cancel(id);
    }
    for (final e in desired.entries) {
      try {
        await gateway.schedule(ScheduledReminder(
          id: e.key,
          doseId: e.value.dose.doseId,
          title: ReminderText.title,
          body: ReminderText.body(e.value),
          at: e.value.scheduledAt,
        ));
      } catch (err) {
        lastError = 'Could not schedule a reminder: $err';
      }
    }
  }
}
