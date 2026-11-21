import '../../../database/app_database.dart';

String makeDoseId(String scheduleId, DateTime at) =>
    '$scheduleId|${at.millisecondsSinceEpoch ~/ 1000}';

class PlannerSchedule {
  const PlannerSchedule({
    required this.scheduleId,
    required this.medicineId,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.startDate,
    this.endDate,
  });

  factory PlannerSchedule.fromRow(MedicationSchedule s) {
    final t = s.time.split(':');
    return PlannerSchedule(
      scheduleId: s.scheduleId,
      medicineId: s.medicineId,
      hour: int.tryParse(t.first) ?? 0,
      minute: int.tryParse(t.length > 1 ? t[1] : '0') ?? 0,
      repeatDays: [for (var i = 0; i < 7; i++) i < s.repeatRule.length && s.repeatRule[i] == '1'],
      startDate: s.startDate,
      endDate: s.endDate,
    );
  }

  final String scheduleId, medicineId;
  final int hour, minute;
  final List<bool> repeatDays; // Mon..Sun
  final DateTime startDate;
  final DateTime? endDate;
}

class PlannedDose {
  const PlannedDose(this.scheduleId, this.medicineId, this.scheduledAt);
  final String scheduleId, medicineId;
  final DateTime scheduledAt;
  String get doseId => makeDoseId(scheduleId, scheduledAt);
}

/// Pure function: which dose occurrences does a set of schedules produce
/// between [from] (inclusive) and [to] (exclusive)? Start/end dates are inclusive.
class ReminderPlanner {
  static List<PlannedDose> plan(
    List<PlannerSchedule> schedules, {
    required DateTime from,
    required DateTime to,
  }) {
    final out = <PlannedDose>[];
    for (final s in schedules) {
      final startDay = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
      final endDay = s.endDate == null
          ? null
          : DateTime(s.endDate!.year, s.endDate!.month, s.endDate!.day);
      for (var day = DateTime(from.year, from.month, from.day);
          day.isBefore(to);
          day = DateTime(day.year, day.month, day.day + 1)) {
        if (day.isBefore(startDay)) continue;
        if (endDay != null && day.isAfter(endDay)) continue;
        if (!s.repeatDays[day.weekday - 1]) continue;
        final at = DateTime(day.year, day.month, day.day, s.hour, s.minute);
        if (at.isBefore(from) || !at.isBefore(to)) continue;
        out.add(PlannedDose(s.scheduleId, s.medicineId, at));
      }
    }
    out.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return out;
  }
}
