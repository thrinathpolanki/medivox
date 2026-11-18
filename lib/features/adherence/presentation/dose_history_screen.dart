import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/domain/dose_models.dart';
import '../../reminders/presentation/status_chip.dart';

class DoseHistoryScreen extends ConsumerStatefulWidget {
  const DoseHistoryScreen({super.key});
  @override
  ConsumerState<DoseHistoryScreen> createState() => _State();
}

class _State extends ConsumerState<DoseHistoryScreen> {
  DoseStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final t = dateOnly(DateTime.now());
    final range = (DateTime(t.year, t.month, t.day - 29), DateTime(t.year, t.month, t.day + 1));
    final async = ref.watch(doseRangeProvider(range));
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dose History'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(spacing: 8, children: [
            ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null)),
            for (final s in [DoseStatus.taken, DoseStatus.missed, DoseStatus.skipped])
              ChoiceChip(
                  label: Text(s.label),
                  selected: _filter == s,
                  onSelected: (_) => setState(() => _filter = s)),
          ]),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Could not load history.')),
            data: (items) {
              final list = items
                  .where((i) => i.scheduledAt.isBefore(now) || i.status != DoseStatus.pending)
                  .where((i) => _filter == null || i.status == _filter)
                  .toList()
                  .reversed
                  .toList();
              if (list.isEmpty) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No dose history yet for the last 30 days.', textAlign: TextAlign.center),
                ));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final d = list[i];
                  final at = d.scheduledAt;
                  return Semantics(
                    container: true,
                    label: '${formatDate(at)} ${formatTime(at.hour, at.minute)}. ${d.title}. ${d.status.label}.',
                    child: ExcludeSemantics(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration:
                            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('${formatDate(at)}, ${formatTime(at.hour, at.minute)}'),
                            ]),
                          ),
                          StatusChip(d.status),
                        ]),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
