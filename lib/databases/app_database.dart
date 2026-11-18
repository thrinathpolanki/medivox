import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserProfiles,
  Medicines,
  MedicineImages,
  MedicationSchedules,
  DoseHistoryEntries,
  SyncQueueEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device SQLite database. (Encryption at rest, e.g. SQLCipher,
  /// is planned for the security milestone and is NOT enabled yet.)
  AppDatabase.open() : super(driftDatabase(
          name: 'medivox',
          // Shared so the notification-action background isolate and the UI
          // talk to the same database connection.
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Add stepwise migrations here when schemaVersion increases.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
