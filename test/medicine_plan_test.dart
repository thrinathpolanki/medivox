import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/database/app_database.dart';
import 'package:medivox/features/medicine/domain/medicine_models.dart';
import 'package:medivox/features/medicine/domain/medicine_plan.dart';

MedicationSchedule _s(String id, String period, String time, String dosage, String food,
        {String repeat = '1111111', DateTime? start, DateTime? end, bool enabled = true}) =>
    MedicationSchedule(
      scheduleId: id,
      medicineId: 'm',
      period: period,
      time: time,
      dosage: dosage,
      foodInstruction: food,
      repeatRule: repeat,
      timezone: null,
      startDate: start ?? DateTime(2026, 1, 1),
      endDate: end,
      enabled: enabled,
    );

MedicineDetail _d(List<MedicationSchedule> sch, {String? dosage}) {
  final now = DateTime(2026, 1, 1);
  return MedicineDetail(
    Medicine(
      medicineId: 'm', userId: 'u', medicineName: 'Beplex Forte', genericName: null, strength: null,
      composition: null, manufacturer: null, medicineType: null, dosage: dosage,
      prescriptionReference: null, notes: null, startDate: null, endDate: null,
      reminderEnabled: true, createdAt: now, updatedAt: now, revision: 1, syncStatus: 'local_only',
    ),
    const [],
    sch,
  );
}

void main() {
  final now = DateTime(2026, 3, 10, 9);

  test('speaks name, then each time with dosage and food instruction', () {
    final out = MedicinePlan.sentences(
        _d([_s('a', 'morning', '08:00', '1 tablet', 'afterFood'), _s('b', 'night', '20:30', '1 tablet', 'beforeFood')]),
        now: now);
    expect(out, [
      'Beplex Forte.',
      'Take 1 tablet at 8 AM, after food.',
      'Take 1 tablet at 8:30 PM, before food.',
    ]);
  });

  test('mentions days when not every day', () {
    final out = MedicinePlan.sentences(_d([_s('a', 'morning', '08:00', '1 tablet', 'withFood', repeat: '1010000')]), now: now);
    expect(out.last, 'Take 1 tablet at 8 AM on Monday, Wednesday, with food.');
  });

  test('no schedule: reads the saved prescribed dosage, or says nothing is saved', () {
    expect(MedicinePlan.sentences(_d([], dosage: '1 tablet daily'), now: now).last, contains('1 tablet daily'));
    expect(MedicinePlan.sentences(_d([]), now: now).last, contains('No time or dosage'));
  });

  test('an ended course is not presented as current', () {
    final out = MedicinePlan.sentences(
        _d([_s('a', 'morning', '08:00', '1 tablet', 'afterFood', end: DateTime(2026, 3, 1))]), now: now);
    expect(out.last, contains('has ended'));
  });

  test('disabled reminders are said to be off but the saved times are still read', () {
    final out = MedicinePlan.sentences(_d([_s('a', 'morning', '08:00', '1 tablet', 'afterFood', enabled: false)]), now: now);
    expect(out.any((l) => l.contains('Reminders are off')), isTrue);
    expect(out.last, contains('8 AM'));
  });

  test('an "as prescribed" dosage reads naturally', () {
    final out = MedicinePlan.sentences(_d([_s('a', 'morning', '08:00', 'As prescribed', 'asPrescribed')]), now: now);
    expect(out.last, 'Dose As prescribed, at 8 AM, as prescribed.');
  });

  test('time formats', () {
    expect(MedicinePlan.spokenTime(0, 0), '12 AM');
    expect(MedicinePlan.spokenTime(12, 5), '12:05 PM');
    expect(MedicinePlan.displayTime(14, 0), '2:00 PM');
  });
}
