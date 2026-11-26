import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/database/app_database.dart';
import 'package:medivox/features/adherence/domain/adherence_stats.dart';
import 'package:medivox/features/medicine/data/image_storage.dart';
import 'package:medivox/features/medicine/data/medicine_repository.dart';
import 'package:medivox/features/medicine/domain/medicine_models.dart';
import 'package:medivox/features/reminders/data/dose_repository.dart';
import 'package:medivox/features/reminders/data/notification_gateway.dart';
import 'package:medivox/features/reminders/data/reminder_planner.dart';
import 'package:medivox/features/reminders/data/reminder_service.dart';
import 'package:medivox/features/reminders/domain/dose_models.dart';

class _NoImages implements ImageStorage {
  @override
  Future<StagedImage> stage(String p) async => StagedImage(path: p);
  @override
  Future<List<StoredImage>> persistAll(String id, Map<ImageSlot, String> s) async => [];
  @override
  Future<void> deleteMedicineImages(String id) async {}
  @override
  Future<void> discard(Iterable<String> p) async {}
}
class _FakeGateway implements NotificationGateway {
  final pending = <int, ScheduledReminder>{};
  @override
  Future<void> init({void Function(NotificationResponse)? onResponse,
      DidReceiveBackgroundNotificationResponseCallback? onBackground}) async {}
  @override
  Future<bool> notificationsEnabled() async => true;
  @override
  Future<bool> requestNotifications() async => true;
  @override
  Future<bool> canScheduleExact() async => true;
  @override
  Future<void> requestExact() async {}
  @override
  Future<void> schedule(ScheduledReminder r) async => pending[r.id] = r;
  @override
  Future<void> scheduleTest(DateTime at) async {}
  @override
  Future<void> cancel(int id) async => pending.remove(id);
  @override
  Future<Set<int>> pendingIds() async => pending.keys.toSet();
  @override
  Future<String?> launchDoseId() async => null;
}
void main() {
  late AppDatabase db;
  late MedicineRepository meds;
  late DoseRepository doses;
  late _FakeGateway gateway;
  late ReminderService service;
  late String medicineId;
  final now = DateTime(2026, 1, 15, 9, 0);

  ScheduleDraft evening({bool enabled = true}) =>
      ScheduleDraft.create('s1', SchedulePeriod.night)
          .copyWith(dosage: '1 tablet', startDate: DateTime(2026, 1, 1), enabled: enabled);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    meds = MedicineRepository(db, _NoImages());
    doses = DoseRepository(db);
    gateway = _FakeGateway();
    service = ReminderService(doses: doses, gateway: gateway, snoozeMinutes: () async => 10);
    await meds.ensureProfile(userId: 'u1', storageMode: 'local');
    medicineId = await meds.registerMedicine(
      userId: 'u1',
      draft: MedicineDraft(
        info: const MedicineInfo(name: 'Paracetamol', strength: '500 mg'),
        schedules: [evening()],
      ),
    );
  });
  tearDown(() => db.close());
  final firstDoseId = makeDoseId('s1', DateTime(2026, 1, 15, 20));

  test('reconcile creates future doses only and never past slots today', () async {
    await doses.reconcile(now: DateTime(2026, 1, 15, 21)); // after today's 20:00
    final today = await doses.getItem(firstDoseId);
    expect(today, isNull); // not created because it was already in the past
    await doses.reconcile(now: now);
    expect(await doses.getItem(firstDoseId), isNotNull);
  });
  test('unanswered doses become missed after 2 hours; nothing becomes taken', () async {
    await doses.reconcile(now: now);
    await doses.reconcile(now: DateTime(2026, 1, 16, 12));
    final item = (await doses.getItem(firstDoseId))!;
    expect(item.status, DoseStatus.missed);
    expect(item.dose.actionAt, isNull);
  });

  test('taken doses are never reverted by reconcile', () async {
    await doses.reconcile(now: now);
    await service.actions.taken(firstDoseId);
    await doses.reconcile(now: DateTime(2026, 1, 16, 12));
    expect((await doses.getItem(firstDoseId))!.status, DoseStatus.taken);
  });

  test('resync schedules the next 7 days of pending doses', () async {
    await service.resync(now: now);
    expect(gateway.pending.length, 7);
    final r = gateway.pending[notificationIdFor(firstDoseId)]!;
    expect(r.body, contains('Paracetamol 500 mg'));
    expect(r.body, contains('1 tablet'));
  });

  test('snooze keeps its notification through a resync', () async {
    await service.resync(now: now);
    await service.actions.snooze(firstDoseId, now: now);
    expect((await doses.getItem(firstDoseId))!.status, DoseStatus.snoozed);
    expect(gateway.pending[notificationIdFor(firstDoseId)]!.at, now.add(const Duration(minutes: 10)));
    await service.resync(now: now);
    expect(gateway.pending.containsKey(notificationIdFor(firstDoseId)), isTrue);
    expect(gateway.pending.length, 7);
  });

  test('taking a dose cancels its notification', () async {
    await service.resync(now: now);
    await service.actions.taken(firstDoseId);
    expect(gateway.pending.containsKey(notificationIdFor(firstDoseId)), isFalse);
  });

  test('disabling the schedule removes future pending doses but keeps history', () async {
    await service.resync(now: now);
    await service.actions.taken(firstDoseId);
    await meds.updateMedicine(
      medicineId: medicineId,
      info: const MedicineInfo(name: 'Paracetamol', strength: '500 mg'),
      schedules: [evening(enabled: false)],
    );
    await service.resync(now: now);
    expect(gateway.pending, isEmpty);
    expect((await doses.getItem(firstDoseId))!.status, DoseStatus.taken);
    expect(await doses.upcomingPending(now, now.add(const Duration(days: 14))), isEmpty);
  });

  test('deleting the medicine removes its doses and notifications', () async {
    await service.resync(now: now);
    await meds.deleteMedicine(medicineId);
    await service.resync(now: now);
    expect(gateway.pending, isEmpty);
    expect(await doses.getItem(firstDoseId), isNull);
  });

  test('adherence = taken / (taken + missed + skipped); pending excluded', () async {
    await doses.reconcile(now: now);
    final ids = [
      for (var d = 15; d <= 18; d++) makeDoseId('s1', DateTime(2026, 1, d, 20)),
    ];
    await doses.setStatus(ids[0], DoseStatus.taken);
    await doses.setStatus(ids[1], DoseStatus.taken);
    await doses.setStatus(ids[2], DoseStatus.skipped);
    await doses.setStatus(ids[3], DoseStatus.missed);
    final items = [for (final id in ids) (await doses.getItem(id))!];
    final stats = AdherenceStats.from(items);
    expect(stats.taken, 2);
    expect(stats.percent, closeTo(50, 0.001));
    final withPending = AdherenceStats.from([...items, (await doses.getItem(makeDoseId('s1', DateTime(2026, 1, 19, 20))))!]);
    expect(withPending.percent, closeTo(50, 0.001));
    expect(withPending.open, 1);
    expect(const AdherenceStats().percent, isNull);
  });
}
