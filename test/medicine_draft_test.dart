import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/features/medicine/domain/medicine_models.dart';

void main() {
  test('schedule requires a typed dosage and at least one day', () {
    final s = ScheduleDraft.create('a', SchedulePeriod.morning);
    expect(s.error, isNotNull); // dosage never auto-filled
    expect(s.copyWith(dosage: '1 tablet').error, isNull);
    expect(s.copyWith(dosage: 'x', repeatDays: List.filled(7, false)).error, isNotNull);
  });

  test('end date before start date is invalid', () {
    final s = ScheduleDraft.create('a', SchedulePeriod.night).copyWith(dosage: 'x');
    expect(s.copyWith(endDate: s.startDate.subtract(const Duration(days: 1))).error, isNotNull);
    expect(s.copyWith(endDate: s.startDate).error, isNull);
  });

  test('draft needs the configured minimum number of photos', () {
    const d = MedicineDraft(images: {ImageSlot.stripFront1: 'a'});
    expect(d.hasEnoughImages, isFalse);
    final d2 = d.copyWith(images: {...d.images, ImageSlot.stripBack1: 'b'});
    expect(d2.hasEnoughImages, isTrue);
  });

  test('repeat rule and text', () {
    final s = ScheduleDraft.create('a', SchedulePeriod.morning)
        .copyWith(repeatDays: [true, false, true, false, false, false, false]);
    expect(s.repeatRule, '1010000');
    expect(s.repeatText, 'Mon, Wed');
    expect(ScheduleDraft.create('b', SchedulePeriod.night).repeatText, 'Every day');
  });
}
