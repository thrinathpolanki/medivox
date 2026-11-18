import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../database/app_database.dart';
import '../domain/medicine_models.dart';
import 'image_storage.dart';

class MedicineRepository {
  MedicineRepository(this._db, this._images, {this.onChanged});
  final AppDatabase _db;
  final ImageStorage _images;

  /// Called after schedules/medicines change so reminders can be re-planned.
  /// Failures here never fail the save itself.
  final Future<void> Function()? onChanged;
  static const _uuid = Uuid();

  Future<void> _notify() async {
    try {
      await onChanged?.call();
    } catch (_) {}
  }

  String? _nz(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  Future<void> ensureProfile({
    required String userId,
    String? displayName,
    required String storageMode,
    String? language,
  }) async {
    await _db.into(_db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            displayName: Value(displayName),
            storageMode: storageMode,
            preferredLanguage: Value(language),
            createdAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await (_db.update(_db.userProfiles)..where((p) => p.userId.equals(userId))).write(
      UserProfilesCompanion(
        displayName: Value(displayName),
        storageMode: Value(storageMode),
        preferredLanguage: Value(language),
      ),
    );
  }

  Future<MedicineDetail> _load(Medicine m) async {
    final imgs = await (_db.select(_db.medicineImages)
          ..where((i) => i.medicineId.equals(m.medicineId)))
        .get();
    final sch = await (_db.select(_db.medicationSchedules)
          ..where((s) => s.medicineId.equals(m.medicineId)))
        .get();
    return MedicineDetail(m, imgs, sch);
  }

  Stream<List<MedicineDetail>> watchAll(String userId, {String query = ''}) {
    final q = query.trim();
    final sel = _db.select(_db.medicines)..where((m) => m.userId.equals(userId));
    if (q.isNotEmpty) {
      final like = '%$q%';
      sel.where((m) =>
          m.medicineName.like(like) | m.genericName.like(like) | m.strength.like(like));
    }
    sel.orderBy([(m) => OrderingTerm.asc(m.medicineName)]);
    return sel.watch().asyncMap((rows) => Future.wait(rows.map(_load)));
  }

  Stream<MedicineDetail?> watchOne(String medicineId) {
    final sel = _db.select(_db.medicines)..where((m) => m.medicineId.equals(medicineId));
    return sel.watchSingleOrNull().asyncMap<MedicineDetail?>(
        (m) async => m == null ? null : await _load(m));
  }

  MedicationSchedulesCompanion _scheduleRow(String medicineId, ScheduleDraft s) {
    return MedicationSchedulesCompanion.insert(
      scheduleId: s.id,
      medicineId: medicineId,
      period: s.period.name,
      time: s.timeText,
      dosage: s.dosage.trim(),
      foodInstruction: s.food.name,
      repeatRule: s.repeatRule,
      timezone: Value(DateTime.now().timeZoneName),
      startDate: s.startDate,
      endDate: Value(s.endDate),
      enabled: Value(s.enabled),
    );
  }

  /// Saves medicine + schedules + image records in ONE transaction. Photos are
  /// moved to permanent storage first and removed again if the save fails.
  Future<String> registerMedicine({
    required String userId,
    required MedicineDraft draft,
  }) async {
    final id = _uuid.v4();
    final stored = await _images.persistAll(id, draft.images);
    final now = DateTime.now();
    final info = draft.info;
    try {
      await _db.transaction(() async {
        await _db.into(_db.medicines).insert(MedicinesCompanion.insert(
              medicineId: id,
              userId: userId,
              medicineName: info.name.trim(),
              genericName: Value(_nz(info.genericName)),
              strength: Value(_nz(info.strength)),
              composition: Value(_nz(info.composition)),
              manufacturer: Value(_nz(info.manufacturer)),
              medicineType: Value(_nz(info.medicineType)),
              dosage: Value(_nz(info.dosage)),
              prescriptionReference: Value(_nz(info.prescriptionReference)),
              notes: Value(_nz(info.notes)),
              reminderEnabled: Value(draft.schedules.any((s) => s.enabled)),
              createdAt: now,
              updatedAt: now,
            ));
        for (final img in stored) {
          await _db.into(_db.medicineImages).insert(MedicineImagesCompanion.insert(
                imageId: _uuid.v4(),
                medicineId: id,
                imageType: img.slot.type,
                imageSequence: img.slot.sequence,
                localPath: img.path,
                checksum: Value(img.checksum),
              ));
        }
        for (final s in draft.schedules) {
          await _db.into(_db.medicationSchedules).insert(_scheduleRow(id, s));
        }
      });
    } catch (_) {
      await _images.deleteMedicineImages(id);
      rethrow;
    }
    await _notify();
    return id;
  }

  /// Updates info and schedules. Existing schedule ids are kept so dose
  /// history stays linked. Bumps [revision] for future sync conflict handling.
  Future<void> updateMedicine({
    required String medicineId,
    required MedicineInfo info,
    required List<ScheduleDraft> schedules,
  }) async {
    await _db.transaction(() async {
      final current = await (_db.select(_db.medicines)
            ..where((m) => m.medicineId.equals(medicineId)))
          .getSingle();
      await (_db.update(_db.medicines)..where((m) => m.medicineId.equals(medicineId)))
          .write(MedicinesCompanion(
        medicineName: Value(info.name.trim()),
        genericName: Value(_nz(info.genericName)),
        strength: Value(_nz(info.strength)),
        composition: Value(_nz(info.composition)),
        manufacturer: Value(_nz(info.manufacturer)),
        medicineType: Value(_nz(info.medicineType)),
        dosage: Value(_nz(info.dosage)),
        prescriptionReference: Value(_nz(info.prescriptionReference)),
        notes: Value(_nz(info.notes)),
        reminderEnabled: Value(schedules.any((s) => s.enabled)),
        updatedAt: Value(DateTime.now()),
        revision: Value(current.revision + 1),
      ));
      final existing = await (_db.select(_db.medicationSchedules)
            ..where((s) => s.medicineId.equals(medicineId)))
          .get();
      final keep = schedules.map((s) => s.id).toSet();
      for (final e in existing) {
        if (!keep.contains(e.scheduleId)) {
          await (_db.delete(_db.medicationSchedules)
                ..where((s) => s.scheduleId.equals(e.scheduleId)))
              .go();
        }
      }
      for (final s in schedules) {
        await _db
            .into(_db.medicationSchedules)
            .insertOnConflictUpdate(_scheduleRow(medicineId, s));
      }
    });
    await _notify();
  }

  /// Deletes the medicine; schedules, image records and dose history are
  /// removed by foreign-key cascade. Then photo files are deleted.
  /// Reminders for it are cancelled by the re-plan triggered below.
  /// TODO(M5): write sync tombstone.
  Future<void> deleteMedicine(String medicineId) async {
    await (_db.delete(_db.medicines)..where((m) => m.medicineId.equals(medicineId))).go();
    await _images.deleteMedicineImages(medicineId);
    await _notify();
  }
}
