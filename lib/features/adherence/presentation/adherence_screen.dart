import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../reminders/data/reminder_providers.dart';
import '../domain/adherence_stats.dart';

enum AdherenceRange { day, week, month }

class AdherenceScreen extends ConsumerStatefulWidget {
  const AdherenceScreen({super.key});
  @override
  ConsumerState<AdherenceScreen> createState() => _State();
}

class _State extends ConsumerState<AdherenceScreen> {
  AdherenceRange _range = AdherenceRange.day;

  (DateTime, DateTime) _bounds() {
    final t = dateOnly(DateTime.now());
    final end = DateTime(t.year, t.month, t.day + 1);
    final start = switch (_range) {
      AdherenceRange.day => t,
      AdherenceRange.week => DateTime(t.year, t.month, t.day - 6),
      AdherenceRange.month => DateTime(t.year, t.month, t.day - 29),
    };
    return (start, end);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(doseRangeProvider(_bounds()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        SegmentedButton<AdherenceRange>(
          segments: const [
            ButtonSegment(value: AdherenceRange.day, label: Text('Day')),
            ButtonSegment(value: AdherenceRange.week, label: Text('Week')),
            ButtonSegment(value: AdherenceRange.month, label: Text('Month')),
          ],
          selected: {_range},
          onSelectionChanged: (s) => setState(() => _range = s.first),
        ),
        const SizedBox(height: 24),
        async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Could not load adherence.'),
          data: (items) {
            final s = AdherenceStats.from(items);
            final pct = s.percent;
            return Column(children: [
              Semantics(
                label: pct == null
                    ? 'No completed doses yet'
                    : 'Adherence ${pct.round()} percent',
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: pct == null ? 0 : pct / 100,
                          strokeWidth: 14,
                          backgroundColor: const Color(0xFFDDE7EC),
                          color: AppColors.success,
                        ),
                      ),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(s.percentText,
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                        const Text('Adherence'),
                      ]),
                    ]),
                  ),
                ),
              ),
              if (pct == null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('No completed doses in this period yet.'),
                ),
              const SizedBox(height: 24),
              Row(children: [
                _stat('Taken', s.taken, Icons.check_circle, AppColors.success),
                _stat('Missed', s.missed, Icons.cancel, AppColors.error),
                _stat('Skipped', s.skipped, Icons.skip_next, AppColors.warning),
                _stat('Pending', s.open, Icons.schedule, AppColors.navy),
              ]),
              const SizedBox(height: 8),
              const Text('Adherence counts taken doses out of taken, missed and skipped doses. '
                  'Pending doses are not counted yet.', textAlign: TextAlign.center),
            ]);
          },
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => context.push('/history'), child: const Text('Dose history')),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => context.push('/reports'), child: const Text('Reports')),
      ]),
    );
  }

  Widget _stat(String label, int n, IconData icon, Color color) => Expanded(
        child: Semantics(
          label: '$label: $n',
          child: ExcludeSemantics(
            child: Column(children: [
              Icon(icon, color: color),
              Text('$n', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label),
            ]),
          ),
        ),
      );
}
