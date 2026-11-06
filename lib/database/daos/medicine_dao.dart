import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';

class MedicineDao {
  final AppDatabase _db;
  final _uuid = const Uuid();

  MedicineDao(this._db);

  Future<String> insertMedicine({
    required String userId,
    required String name,
    String? genericName,
    String? strength,
    String? composition,
    String? manufacturer,
    String? medicineType,
    String? dosage,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.medicines).insert(
          MedicinesCompanion.insert(
            medicineId: id,
            userId: userId,
            medicineName: name,
            genericName: Value(genericName),
            strength: Value(strength),
            composition: Value(composition),
            manufacturer: Value(manufacturer),
            medicineType: Value(medicineType),
            dosage: Value(dosage),
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }

  Future<String> insertImage({
    required String medicineId,
    required String imageType,
    required int imageSequence,
    required String localPath,
    String? checksum,
  }) async {
    final id = _uuid.v4(); // Generate ID
    await _db.into(_db.medicineImages).insert(
          MedicineImagesCompanion.insert(
            imageId: id,
            medicineId: medicineId,
            imageType: imageType,
            imageSequence: imageSequence,
            localPath: localPath,
            checksum: Value(checksum),
            createdAt: DateTime.now(),
          ),
        );
    return id; // Return it so the Review Screen can use it for the embedding
  }

  Future<void> insertEmbedding({
    required String medicineId,
    required String imageId,
    required String vectorJson,
  }) async {
    await _db.into(_db.imageEmbeddings).insert(
          ImageEmbeddingsCompanion.insert(
            embeddingId: _uuid.v4(),
            medicineId: medicineId,
            imageId: imageId,
            vectorJson: vectorJson,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<ImageEmbedding>> getAllEmbeddings() {
    return _db.select(_db.imageEmbeddings).get();
  }

  Future<void> insertSchedule({
    required String medicineId,
    required String period,
    required String time,
    required String dosage,
    required String foodInstruction,
    required List<int> repeatDays,
    required String timezone,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    await _db.into(_db.medicationSchedules).insert(
          MedicationSchedulesCompanion.insert(
            scheduleId: _uuid.v4(),
            medicineId: medicineId,
            period: period,
            time: time,
            dosage: dosage,
            foodInstruction: foodInstruction,
            repeatDays: jsonEncode(repeatDays),
            timezone: timezone,
            startDate: startDate,
            endDate: Value(endDate),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<Medicine>> getAllMedicines(String userId) {
    return (_db.select(_db.medicines)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Medicine?> getMedicineById(String medicineId) {
    return (_db.select(_db.medicines)
          ..where((t) => t.medicineId.equals(medicineId)))
        .getSingleOrNull();
  }

  Future<List<MedicineImage>> getImagesForMedicine(String medicineId) {
    return (_db.select(_db.medicineImages)
          ..where((t) => t.medicineId.equals(medicineId))
          ..orderBy([(t) => OrderingTerm.asc(t.imageSequence)]))
        .get();
  }

  Future<List<MedicationSchedule>> getSchedulesForMedicine(String medicineId) {
    return (_db.select(_db.medicationSchedules)
          ..where((t) => t.medicineId.equals(medicineId)))
        .get();
  }

  Future<void> deleteMedicine(String medicineId) async {
    await (_db.delete(_db.medicines)
          ..where((t) => t.medicineId.equals(medicineId)))
        .go();
  }
}
