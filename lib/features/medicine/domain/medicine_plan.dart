import '../../../core/utils/format.dart';
import 'medicine_models.dart';

/// Turns a saved medicine into "what to take, when, and how much", using ONLY
/// what the user saved. It never suggests or changes a dosage.
class MedicinePlan {
  /// "8 AM", "2:30 PM" (spoken form).
  static String spokenTime(int h, int m) {
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final ap = h < 12 ? 'AM' : 'PM';
    return m == 0 ? '$h12 $ap' : '$h12:${m.toString().padLeft(2, '0')} $ap';
  }

  /// "8:00 AM" (screen form).
  static String displayTime(int h, int m) {
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
  }

  static String title(MedicineDetail d) {
    final s = (d.medicine.strength ?? '').trim();
    return s.isEmpty ? d.medicine.medicineName : '${d.medicine.medicineName} $s';
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Schedules that have not ended; enabled ones first choice.
  static List<ScheduleDraft> _usable(MedicineDetail d, DateTime today) => d.sortedSchedules
      .map(ScheduleDraft.fromRow)
      .where((s) => s.endDate == null || !_day(s.endDate!).isBefore(today))
      .toList();

  static String _days(ScheduleDraft s) => s.repeatDays.every((x) => x)
      ? ''
      : ' on ${[for (var i = 0; i < 7; i++) if (s.repeatDays[i]) weekdayLong[i]].join(', ')}';

  static String _prefix(ScheduleDraft s) =>
      s.period == SchedulePeriod.custom ? 'At' : '${s.period.label} at';

  /// Spoken sentences: name, then each time with its dosage and food instruction.
  static List<String> sentences(MedicineDetail d, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final out = <String>['${title(d)}.'];
    final all = d.sortedSchedules;
    if (all.isEmpty) {
      final dose = (d.medicine.dosage ?? '').trim();
      out.add(dose.isEmpty
          ? 'No time or dosage is saved for this medicine.'
          : 'No time is saved. Prescribed dosage: $dose.');
      return out;
    }
    final usable = _usable(d, today);
    if (usable.isEmpty) {
      out.add('The saved schedule for this medicine has ended.');
      return out;
    }
    final enabled = usable.where((s) => s.enabled).toList();
    final use = enabled.isEmpty ? usable : enabled;
    if (enabled.isEmpty) out.add('Reminders are off for this medicine.');
    for (final s in use) {
      final dose = s.dosage.trim();
      // Order: how much first, then when, then the food instruction.
      final head = dose.isEmpty
          ? 'Take'
          : dose.toLowerCase().startsWith('as ')
              ? 'Dose $dose,'
              : 'Take $dose';
      final starts = s.startDate.isAfter(today) ? ' Starts on ${formatDate(s.startDate)}.' : '';
      out.add('$head at ${spokenTime(s.hour, s.minute)}${_days(s)}, ${s.food.label.toLowerCase()}.$starts');
    }
    return out;
  }

  /// Same information as short screen lines (without the name).
  static List<String> lines(MedicineDetail d, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final all = d.sortedSchedules;
    if (all.isEmpty) {
      final dose = (d.medicine.dosage ?? '').trim();
      return [dose.isEmpty ? 'No time or dosage is saved.' : 'No time saved. Prescribed dosage: $dose'];
    }
    final usable = _usable(d, today);
    if (usable.isEmpty) return ['The saved schedule has ended.'];
    final enabled = usable.where((s) => s.enabled).toList();
    final use = enabled.isEmpty ? usable : enabled;
    return [
      if (enabled.isEmpty) 'Reminders are off.',
      for (final s in use)
        '${displayTime(s.hour, s.minute)}${_days(s)}: ${s.dosage.trim().isEmpty ? '' : '${s.dosage.trim()}, '}${s.food.label}',
    ];
  }
}
