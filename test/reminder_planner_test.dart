import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/features/reminders/data/notification_gateway.dart';
import 'package:medivox/features/reminders/data/reminder_planner.dart';

PlannerSchedule _s({
  List<bool>? days,
  DateTime? start,
  DateTime? end,
  int hour = 8,
  int minute = 0,
}) =>
    PlannerSchedule(
      scheduleId: 's1',
      medicineId: 'm1',
      hour: hour,
      minute: minute,
      repeatDays: days ?? List.filled(7, true),
      startDate: start ?? DateTime(2026, 1, 1),
      endDate: end,
    );
void main() {
  test('daily schedule yields one dose per day inside the window', () {
    final out = ReminderPlanner.plan([_s()],
        from: DateTime(2026, 1, 15), to: DateTime(2026, 1, 18));
    expect(out.map((d) => d.scheduledAt),
        [DateTime(2026, 1, 15, 8), DateTime(2026, 1, 16, 8), DateTime(2026, 1, 17, 8)]);
  });
  test('start and end dates are inclusive', () {
    final out = ReminderPlanner.plan(
      [_s(start: DateTime(2026, 1, 16), end: DateTime(2026, 1, 17))],
      from: DateTime(2026, 1, 15),
      to: DateTime(2026, 1, 20),
    );
    expect(out.length, 2);
    expect(out.first.scheduledAt, DateTime(2026, 1, 16, 8));
    expect(out.last.scheduledAt, DateTime(2026, 1, 17, 8));
  });
  test('repeat days are respected (Mon=index 0)', () {
    // 2026-01-19 is a Monday.
    final mondays = [true, false, false, false, false, false, false];
    final out = ReminderPlanner.plan([_s(days: mondays)],
        from: DateTime(2026, 1, 15), to: DateTime(2026, 1, 27));
    expect(out.map((d) => d.scheduledAt), [DateTime(2026, 1, 19, 8), DateTime(2026, 1, 26, 8)]);
  });

  test('window start is a real time: earlier slots today are excluded', () {
    final out = ReminderPlanner.plan([_s()],
        from: DateTime(2026, 1, 15, 9), to: DateTime(2026, 1, 16, 12));
    expect(out.map((d) => d.scheduledAt), [DateTime(2026, 1, 16, 8)]);
  });

  test('dose ids are deterministic', () {
    final a = ReminderPlanner.plan([_s()], from: DateTime(2026, 1, 15), to: DateTime(2026, 1, 16));
    final b = ReminderPlanner.plan([_s()], from: DateTime(2026, 1, 15), to: DateTime(2026, 1, 16));
    expect(a.single.doseId, b.single.doseId);
  });
  test('notification ids are stable and positive 31-bit', () {
    final id = notificationIdFor('s1|1768464000');
    expect(id, notificationIdFor('s1|1768464000'));
    expect(id, inInclusiveRange(0, 0x7FFFFFFF));
    expect(id, isNot(notificationIdFor('s1|1768464001')));
  });
}
