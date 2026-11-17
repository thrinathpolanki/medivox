import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/database/app_database.dart';
import 'package:medivox/features/medicine/data/image_storage.dart';
import 'package:medivox/features/medicine/data/medicine_repository.dart';
import 'package:medivox/features/medicine/domain/medicine_models.dart';

class _FakeStorage implements ImageStorage {
  final deleted = <String>[];
  @override
  Future<StagedImage> stage(String sourcePath) async =>
      StagedImage(path: sourcePath);
  @override
  Future<List<StoredImage>> persistAll(
          String id, Map<ImageSlot, String> staged) async =>
      [
        for (final e in staged.entries)
          StoredImage(e.key, '/fake/$id/${e.key.name}.jpg', 'sum'),
      ];
  @override
  Future<void> deleteMedicineImages(String id) async => deleted.add(id);
  @override
  Future<void> discard(Iterable<String> p) async {}
}

void main() {
  late AppDatabase db;
  late _FakeStorage storage;
  late MedicineRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = _FakeStorage();
    repo = MedicineRepository(db, storage);
    await repo.ensureProfile(userId: 'u1', storageMode: 'local');
  });
  tearDown(() => db.close());

  MedicineDraft draft() => MedicineDraft(
        info: const MedicineInfo(
            name: ' Paracetamol ', strength: '500 mg', dosage: '1 tablet'),
        images: const {
          ImageSlot.stripFront1: '/tmp/a.jpg',
          ImageSlot.stripBack1: '/tmp/b.jpg'
        },
        schedules: [
          ScheduleDraft.create('s1', SchedulePeriod.morning)
              .copyWith(dosage: '1 tablet'),
          ScheduleDraft.create('s2', SchedulePeriod.night)
              .copyWith(dosage: '1 tablet'),
        ],
      );

  test('register saves medicine, images and schedules together', () async {
    final id = await repo.registerMedicine(userId: 'u1', draft: draft());
    final d = (await repo.watchOne(id).first)!;
    expect(d.medicine.medicineName, 'Paracetamol');
    expect(d.images.length, 2);
    expect(d.schedules.length, 2);
    expect(d.medicine.revision, 1);
    expect(d.medicine.reminderEnabled, isTrue);
    expect(d.thumbnailPath, contains('stripFront1'));
  });

  test(
      'update keeps existing schedule ids, removes dropped ones, bumps revision',
      () async {
    final id = await repo.registerMedicine(userId: 'u1', draft: draft());
    final before = (await repo.watchOne(id).first)!;
    final kept = ScheduleDraft.fromRow(
        before.schedules.firstWhere((s) => s.scheduleId == 's1'));
    await repo.updateMedicine(
      medicineId: id,
      info: const MedicineInfo(name: 'Paracetamol', strength: '650 mg'),
      schedules: [kept.copyWith(dosage: '2 tablets')],
    );
    final after = (await repo.watchOne(id).first)!;
    expect(after.medicine.revision, 2);
    expect(after.medicine.strength, '650 mg');
    expect(after.schedules.map((s) => s.scheduleId), ['s1']);
    expect(after.schedules.single.dosage, '2 tablets');
  });

  test('delete cascades to children and removes photo files', () async {
    final id = await repo.registerMedicine(userId: 'u1', draft: draft());
    await repo.deleteMedicine(id);
    expect(await repo.watchOne(id).first, isNull);
    expect(await db.select(db.medicationSchedules).get(), isEmpty);
    expect(await db.select(db.medicineImages).get(), isEmpty);
    expect(storage.deleted, contains(id));
  });

  test('search matches name and is scoped to the user', () async {
    await repo.registerMedicine(userId: 'u1', draft: draft());
    await repo.ensureProfile(userId: 'u2', storageMode: 'local');
    await repo.registerMedicine(userId: 'u2', draft: draft());
    expect((await repo.watchAll('u1', query: 'para').first).length, 1);
    expect(await repo.watchAll('u1', query: 'zzz').first, isEmpty);
  });
}
