import 'package:drift/drift.dart';
import '../../../database/app_database.dart';

class DailyAdherence {
  final DateTime date;
  final int taken;
  final int missed;
  final int skipped;
  final int pending;

  const DailyAdherence({
    required this.date,
    required this.taken,
    required this.missed,
    required this.skipped,
    required this.pending,
  });

  int get total => taken + missed + skipped + pending;
  int get completed => taken + missed + skipped;

  /// Percentage of *completed* doses that were Taken.
  /// Pending doses are excluded so the number doesn't jump up/down during the day.
  double get adherencePercent {
    if (completed == 0) return 0.0;
    return taken / completed;
  }
}

class OverallAdherence {
  final int totalTaken;
  final int totalMissed;
  final int totalSkipped;
  final int totalPending;
  final List<DailyAdherence> daily;

  const OverallAdherence({
    required this.totalTaken,
    required this.totalMissed,
    required this.totalSkipped,
    required this.totalPending,
    required this.daily,
  });

  int get totalCompleted => totalTaken + totalMissed + totalSkipped;

  double get adherencePercent {
    if (totalCompleted == 0) return 0.0;
    return totalTaken / totalCompleted;
  }
}

class AdherenceCalculator {
  final AppDatabase db;
  AdherenceCalculator(this.db);

  /// Adherence for the last [days] days (default 7).
  Future<OverallAdherence> compute({
    int days = 7,
    String? medicineId,
  }) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final end = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));

    // Build query
    var q = db.select(db.doseHistory)
      ..where((t) =>
          t.scheduledAt.isBiggerOrEqualValue(start) &
          t.scheduledAt.isSmallerThanValue(end));

    if (medicineId != null) {
      // Only doses whose schedule belongs to this medicine
      final scheduleIds = await (db.select(db.medicationSchedules)
            ..where((t) => t.medicineId.equals(medicineId)))
          .map((row) => row.scheduleId)
          .get();
      if (scheduleIds.isEmpty) {
        return _empty(days, start);
      }
      q = db.select(db.doseHistory)
        ..where((t) =>
            t.scheduledAt.isBiggerOrEqualValue(start) &
            t.scheduledAt.isSmallerThanValue(end) &
            t.scheduleId.isIn(scheduleIds));
    }

    final rows = await q.get();

    // Bucket by day
    final Map<String, List<DoseHistory>> byDay = {};
    for (final r in rows) {
      final key = '${r.scheduledAt.year}-${r.scheduledAt.month}-${r.scheduledAt.day}';
      byDay.putIfAbsent(key, () => []).add(r);
    }

    final daily = <DailyAdherence>[];
    int totalTaken = 0, totalMissed = 0, totalSkipped = 0, totalPending = 0;

    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      final bucket = byDay[key] ?? [];

      int taken = 0, missed = 0, skipped = 0, pending = 0;
      for (final dose in bucket) {
        switch (dose.status) {
          case 'taken':
            taken++;
            totalTaken++;
            break;
          case 'missed':
            missed++;
            totalMissed++;
            break;
          case 'skipped':
            skipped++;
            totalSkipped++;
            break;
          case 'pending':
          case 'snoozed':
            pending++;
            totalPending++;
            break;
        }
      }

      daily.add(DailyAdherence(
        date: date,
        taken: taken,
        missed: missed,
        skipped: skipped,
        pending: pending,
      ));
    }

    return OverallAdherence(
      totalTaken: totalTaken,
      totalMissed: totalMissed,
      totalSkipped: totalSkipped,
      totalPending: totalPending,
      daily: daily,
    );
  }

  OverallAdherence _empty(int days, DateTime start) {
    final daily = <DailyAdherence>[];
    for (int i = 0; i < days; i++) {
      daily.add(DailyAdherence(
        date: start.add(Duration(days: i)),
        taken: 0, missed: 0, skipped: 0, pending: 0,
      ));
    }
    return OverallAdherence(
      totalTaken: 0, totalMissed: 0, totalSkipped: 0, totalPending: 0,
      daily: daily,
    );
  }
}
