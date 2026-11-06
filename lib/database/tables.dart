import 'package:drift/drift.dart';

// ─────────────────────────────────────────────────────────
// 1. UserProfiles
// ─────────────────────────────────────────────────────────
class UserProfiles extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get storageMode => text()();
  TextColumn get preferredLanguage =>
      text().withDefault(const Constant('en'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

// ─────────────────────────────────────────────────────────
// 2. Medicines  (must come BEFORE tables that reference it)
// ─────────────────────────────────────────────────────────
class Medicines extends Table {
  TextColumn get medicineId => text()();
  TextColumn get userId => text()();
  TextColumn get medicineName => text()();
  TextColumn get genericName => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get composition => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get medicineType => text().nullable()();
  TextColumn get dosage => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {medicineId};
}

// ─────────────────────────────────────────────────────────
// 3. MedicineImages  (references Medicines — defined above)
// ─────────────────────────────────────────────────────────
class MedicineImages extends Table {
  TextColumn get imageId => text()();
  TextColumn get medicineId =>
      text().references(Medicines, #medicineId, onDelete: KeyAction.cascade)();
  TextColumn get imageType => text()();
  IntColumn get imageSequence => integer()();
  TextColumn get localPath => text()();
  TextColumn get cloudPath => text().nullable()();
  TextColumn get checksum => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {imageId};
}

// ─────────────────────────────────────────────────────────
// 4. MedicationSchedules  (references Medicines — defined above)
// ─────────────────────────────────────────────────────────
class MedicationSchedules extends Table {
  TextColumn get scheduleId => text()();
  TextColumn get medicineId =>
      text().references(Medicines, #medicineId, onDelete: KeyAction.cascade)();
  TextColumn get period => text()();
  TextColumn get time => text()();
  TextColumn get dosage => text()();
  TextColumn get foodInstruction => text()();
  TextColumn get repeatDays => text()();
  TextColumn get timezone => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {scheduleId};
}

// ─────────────────────────────────────────────────────────
// 5. DoseHistory
// ─────────────────────────────────────────────────────────
class DoseHistory extends Table {
  TextColumn get doseId => text()();
  TextColumn get scheduleId => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get actionAt => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {doseId};
}

class ImageEmbeddings extends Table {
  TextColumn get embeddingId => text()();
  TextColumn get medicineId =>
      text().references(Medicines, #medicineId, onDelete: KeyAction.cascade)();
  TextColumn get imageId => text()
      .references(MedicineImages, #imageId, onDelete: KeyAction.cascade)();
  TextColumn get vectorJson =>
      text()(); // Store the 1024-float array as a JSON string
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {embeddingId};
}
