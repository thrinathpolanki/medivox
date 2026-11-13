import 'package:drift/drift.dart';
import '../../../database/app_database.dart';

class MissedDoseEngine {
  final AppDatabase db;
  MissedDoseEngine(this.db);

  /// Called on every app open and after each schedule change.
  Future<int> markMissedDoses({Duration grace = const Duration(minutes: 30)}) async {
    final cutoff = DateTime.now().subtract(grace);

    // Find all pending/snoozed doses whose scheduledAt is older than the cutoff
    final stale = await (db.select(db.doseHistory)
          ..where((t) =>
              (t.status.equals('pending') | t.status.equals('snoozed')) &
              t.scheduledAt.isSmallerThanValue(cutoff)))
        .get();

    if (stale.isEmpty) return 0;

    for (final dose in stale) {
      await (db.update(db.doseHistory)
            ..where((t) => t.doseId.equals(dose.doseId)))
          .write(const DoseHistoryCompanion(
        status: Value('missed'),
      ));
    }

    return stale.length;
  }
}
