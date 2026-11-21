import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../domain/dose_models.dart';
import 'reminder_planner.dart';

class DoseRepository {
  DoseRepository(this._db);
  final AppDatabase _db;

  /// A pending or snoozed dose becomes "missed" this long after its time.
  static const missedAfter = Duration(hours: 2);

  JoinedSelectStatement _base() {
    final d = _db.doseHistoryEntries, m = _db.medicines, s = _db.medicationSchedules;
    return _db.select(d).join([
      innerJoin(m, m.medicineId.equalsExp(d.medicineId)),
      leftOuterJoin(s, s.scheduleId.equalsExp(d.scheduleId)),
    ]);
  }

  DoseItem _item(TypedResult r) => DoseItem(
        r.readTable(_db.doseHistoryEntries),
        r.readTable(_db.medicines),
        r.readTableOrNull(_db.medicationSchedules),
      );

  Stream<List<DoseItem>> watchRange(String userId, DateTime from, DateTime to) {
    final d = _db.doseHistoryEntries, m = _db.medicines;
    final q = _base()
      ..where(m.userId.equals(userId) &
          d.scheduledAt.isBiggerOrEqualValue(from) &
          d.scheduledAt.isSmallerThanValue(to))
      ..orderBy([OrderingTerm.asc(d.scheduledAt)]);
    return q.watch().map((rows) => rows.map(_item).toList());
  }

  Stream<DoseItem?> watchOne(String doseId) {
    final q = _base()..where(_db.doseHistoryEntries.doseId.equals(doseId));
    return q.watch().map((rows) => rows.isEmpty ? null : _item(rows.first));
  }

  Future<DoseItem?> getItem(String doseId) async {
    final q = _base()..where(_db.doseHistoryEntries.doseId.equals(doseId));
    final rows = await q.get();
    return rows.isEmpty ? null : _item(rows.first);
  }

  Stream<List<DoseItem>> watchForMedicine(String medicineId, {int limit = 20}) {
    final d = _db.doseHistoryEntries;
    final q = _base()
      ..where(d.medicineId.equals(medicineId) & d.status.isNotValue('pending'))
      ..orderBy([OrderingTerm.desc(d.scheduledAt)])
      ..limit(limit);
    return q.watch().map((rows) => rows.map(_item).toList());
  }

  Future<List<DoseItem>> upcomingPending(DateTime from, DateTime to, {int limit = 150}) async {
    final d = _db.doseHistoryEntries;
    final q = _base()
      ..where(d.status.equals('pending') &
          d.scheduledAt.isBiggerThanValue(from) &
          d.scheduledAt.isSmallerThanValue(to))
      ..orderBy([OrderingTerm.asc(d.scheduledAt)])
      ..limit(limit);
    return (await q.get()).map(_item).toList();
  }

  Future<Set<String>> snoozedDoseIds() async {
    final d = _db.doseHistoryEntries;
    final rows = await (_db.select(d)..where((t) => t.status.equals('snoozed'))).get();
    return rows.map((r) => r.doseId).toSet();
  }

  /// Explicit user actions only. Delivering a notification never calls this.
  Future<void> setStatus(String doseId, DoseStatus status, {DateTime? at}) async {
    await (_db.update(_db.doseHistoryEntries)..where((t) => t.doseId.equals(doseId))).write(
      DoseHistoryEntriesCompanion(
        status: Value(status.name),
        actionAt: Value(at ?? DateTime.now()),
      ),
    );
  }

  /// Brings stored dose occurrences in line with the current schedules:
  ///  1. pending/snoozed doses older than [missedAfter] become "missed";
  ///  2. pending doses from today onward that no schedule produces any more are
  ///     removed (schedule edited, disabled or deleted);
  ///  3. missing future occurrences are inserted (never ones already in the past).
  /// Taken / skipped / snoozed / missed history is never deleted here.
  Future<void> reconcile({required DateTime now, int horizonDays = 14}) async {
    final startOfToday = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day + horizonDays);
    final sched = _db.medicationSchedules, med = _db.medicines, d = _db.doseHistoryEntries;

    final rows = await (_db.select(sched).join([
      innerJoin(med, med.medicineId.equalsExp(sched.medicineId)),
    ])
          ..where(sched.enabled.equals(true) & med.reminderEnabled.equals(true)))
        .get();
    final planned = ReminderPlanner.plan(
      rows.map((r) => PlannerSchedule.fromRow(r.readTable(sched))).toList(),
      from: startOfToday,
      to: end,
    );
    final plannedIds = planned.map((p) => p.doseId).toSet();

    await _db.transaction(() async {
      await (_db.update(d)
            ..where((t) =>
                t.status.isIn(['pending', 'snoozed']) &
                t.scheduledAt.isSmallerThanValue(now.subtract(missedAfter))))
          .write(const DoseHistoryEntriesCompanion(status: Value('missed')));

      await (_db.delete(d)
            ..where((t) =>
                t.status.equals('pending') &
                t.scheduledAt.isBiggerOrEqualValue(startOfToday) &
                t.doseId.isNotIn(plannedIds)))
          .go();

      for (final p in planned) {
        if (!p.scheduledAt.isAfter(now)) continue;
        await _db.into(d).insert(
              DoseHistoryEntriesCompanion.insert(
                doseId: p.doseId,
                medicineId: p.medicineId,
                scheduleId: Value(p.scheduleId),
                scheduledAt: p.scheduledAt,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }
}
