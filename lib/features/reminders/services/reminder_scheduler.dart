import 'package:uuid/uuid.dart';
import '../../../database/app_database.dart';
import 'notification_service.dart';

class ReminderScheduler {
  final AppDatabase db;
  final _uuid = const Uuid();
  ReminderScheduler(this.db);

  /// Schedule all reminders for all schedules of the given medicine.
  /// Generates dose records for the next [daysAhead] days.
  Future<void> scheduleAllForMedicine({
    required Medicine medicine,
    int daysAhead = 7,
  }) async {
    final schedules = await (db.select(db.medicationSchedules)
          ..where((t) => t.medicineId.equals(medicine.medicineId)))
        .get();

    for (final schedule in schedules) {
      await _scheduleForSingle(schedule, medicine, daysAhead);
    }
  }

  Future<void> scheduleAllMedicinesForUser(String userId) async {
    final medicines = await (db.select(db.medicines)
          ..where((t) => t.userId.equals(userId)))
        .get();

    for (final medicine in medicines) {
      await scheduleAllForMedicine(medicine: medicine);
    }
  }

  Future<void> _scheduleForSingle(
    MedicationSchedule schedule,
    Medicine medicine,
    int daysAhead,
  ) async {
    if (!schedule.enabled) return;
    // Parse repeatDays (JSON list like "[1,2,3,4,5,6,7]" — 1=Mon, 7=Sun)
    final List<int> repeatDays = (jsonDecodeList(schedule.repeatDays));s
    final timeParts = schedule.time.split(':');
    if (timeParts.length != 2) return;
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final now = DateTime.now();
    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      // Check if this date's weekday is enabled
      if (!repeatDays.contains(date.weekday)) continue;
      final scheduledAt =
          DateTime(date.year, date.month, date.day, hour, minute);
      if (scheduledAt.isBefore(now)) continue;
      // Create dose history record (status = 'pending')
      final doseId = _uuid.v4();
      await db.into(db.doseHistory).insert(
            DoseHistoryCompanion.insert(
              doseId: doseId,
              scheduleId: schedule.scheduleId,
              scheduledAt: scheduledAt,
              status: 'pending',
            ),
            mode: InsertMode.insertOrIgnore,
          );

      // Schedule the notification (deterministic notificationId from doseId)
      final notificationId = doseId.hashCode & 0x7FFFFFFF;
      await NotificationService.scheduleReminder(
        notificationId: notificationId,
        scheduledAt: scheduledAt,
        medicineName: medicine.medicineName,
        dosage: schedule.dosage,
        foodInstruction: schedule.foodInstruction,
        payload: '${medicine.medicineId}|${schedule.scheduleId}|$doseId',
      );
    }
  }

  List<int> jsonDecodeList(String raw) {
    // Simple parser — expects '[1,2,3]'
    final cleaned = raw.replaceAll('[', '').replaceAll(']', '');
    if (cleaned.trim().isEmpty) return [];
    return cleaned.split(',').map((s) => int.tryParse(s.trim()) ?? 0).toList();
  }

  Future<void> cancelAllForMedicine(String medicineId) async {
    final schedules = await (db.select(db.medicationSchedules)
          ..where((t) => t.medicineId.equals(medicineId)))
        .get();
    for (final schedule in schedules) {
      final doses = await (db.select(db.doseHistory)
            ..where((t) => t.scheduleId.equals(schedule.scheduleId)))
          .get();
      for (final dose in doses) {
        final notificationId = dose.doseId.hashCode & 0x7FFFFFFF;
        await NotificationService.cancel(notificationId);
      }
    }
  }
}
