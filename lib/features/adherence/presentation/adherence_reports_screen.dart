import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/domain/dose_models.dart';
import '../domain/adherence_stats.dart';

class AdherenceReportsScreen extends ConsumerStatefulWidget {
  const AdherenceReportsScreen({super.key});
  @override
  ConsumerState<AdherenceReportsScreen> createState() => _State();
}

class _State extends ConsumerState<AdherenceReportsScreen> {
  bool _weekly = true;

  @override
  Widget build(BuildContext context) {
    final t = dateOnly(DateTime.now());
    final start = DateTime(t.year, t.month, t.day - 27);
    final end = DateTime(t.year, t.month, t.day + 1);
    final async = ref.watch(doseRangeProvider((start, end)));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Weekly')),
            ButtonSegment(value: false, label: Text('Monthly')),
          ],
          selected: {_weekly},
          onSelectionChanged: (s) => setState(() => _weekly = s.first),
        ),
        const SizedBox(height: 20),
        async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Could not load the report.'),
          data: (items) {
            // Weekly: last 7 days, one bar per day. Monthly: last 28 days, 4 bars of 7 days.
            final bars = <(String, AdherenceStats)>[];
            if (_weekly) {
              for (var i = 6; i >= 0; i--) {
                final day = DateTime(t.year, t.month, t.day - i);
                final next = DateTime(day.year, day.month, day.day + 1);
                bars.add((
                  weekdayShort[day.weekday - 1],
                  AdherenceStats.from(
                      items.where((d) => !d.scheduledAt.isBefore(day) && d.scheduledAt.isBefore(next)))
                ));
              }
            } else {
              for (var w = 0; w < 4; w++) {
                final from = DateTime(start.year, start.month, start.day + w * 7);
                final to = DateTime(from.year, from.month, from.day + 7);
                bars.add((
                  'W${w + 1}',
                  AdherenceStats.from(
                      items.where((d) => !d.scheduledAt.isBefore(from) && d.scheduledAt.isBefore(to)))
                ));
              }
            }
            final scope = _weekly
                ? items.where((d) => !d.scheduledAt.isBefore(DateTime(t.year, t.month, t.day - 6)))
                : items;
            final total = AdherenceStats.from(scope);
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(_weekly ? 'Weekly adherence' : 'Monthly adherence (4 weeks)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Overall: ${total.percentText}'),
              const SizedBox(height: 16),
              _Bars(bars: bars),
              const SizedBox(height: 20),
              Text('Summary', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('Taken: ${total.taken}\nMissed: ${total.missed}\n'
                  'Skipped: ${total.skipped}\nPending: ${total.open}'),
              const SizedBox(height: 20),
              OutlinedButton(
                  onPressed: () => context.push('/reports/medicines'),
                  child: const Text('Adherence by medicine')),
              const SizedBox(height: 12),
              const Text('Reports are built from your recorded doses only. Export is not '
                  'available yet.'),
            ]);
          },
        ),
      ]),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.bars});
  final List<(String, AdherenceStats)> bars;

  @override
  Widget build(BuildContext context) {
    const maxH = 140.0;
    return Semantics(
      label: 'Adherence chart. ${bars.map((b) => '${b.$1} ${b.$2.percentText}').join(', ')}',
      child: ExcludeSemantics(
        child: SizedBox(
          height: maxH + 48,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (final b in bars)
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(b.$2.percentText, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    height: ((b.$2.percent ?? 0) / 100 * maxH).clamp(3, maxH),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: b.$2.percent == null ? const Color(0xFFDDE7EC) : AppColors.teal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(b.$1),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}
