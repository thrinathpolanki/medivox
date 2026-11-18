import '../../reminders/domain/dose_models.dart';

/// Adherence is calculated ONLY from stored dose records and explicit user
/// actions. Pending/snoozed doses are not yet decided, so they are excluded
/// from the percentage.  percent = taken / (taken + missed + skipped).
class AdherenceStats {
  const AdherenceStats({
    this.taken = 0,
    this.missed = 0,
    this.skipped = 0,
    this.pending = 0,
    this.snoozed = 0,
  });

  factory AdherenceStats.from(Iterable<DoseItem> items) {
    var t = 0, m = 0, s = 0, p = 0, z = 0;
    for (final i in items) {
      switch (i.status) {
        case DoseStatus.taken:
          t++;
        case DoseStatus.missed:
          m++;
        case DoseStatus.skipped:
          s++;
        case DoseStatus.pending:
          p++;
        case DoseStatus.snoozed:
          z++;
      }
    }
    return AdherenceStats(taken: t, missed: m, skipped: s, pending: p, snoozed: z);
  }

  final int taken, missed, skipped, pending, snoozed;
  int get resolved => taken + missed + skipped;
  int get open => pending + snoozed;
  int get total => resolved + open;
  double? get percent => resolved == 0 ? null : taken * 100 / resolved;
  String get percentText => percent == null ? '–' : '${percent!.round()}%';
}
