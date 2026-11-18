import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/domain/dose_models.dart';
import '../domain/adherence_stats.dart';

class MedicineWiseAdherenceScreen extends ConsumerWidget {
  const MedicineWiseAdherenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = dateOnly(DateTime.now());
    final async = ref.watch(
        doseRangeProvider((DateTime(t.year, t.month, t.day - 29), DateTime(t.year, t.month, t.day + 1))));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence by medicine'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/reports'),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load the report.')),
        data: (items) {
          final byMed = <String, List<DoseItem>>{};
          for (final i in items) {
            byMed.putIfAbsent(i.medicine.medicineId, () => []).add(i);
          }
          if (byMed.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No doses recorded in the last 30 days.', textAlign: TextAlign.center),
            ));
          }
          final entries = byMed.values.toList()
            ..sort((a, b) => a.first.medicine.medicineName.compareTo(b.first.medicine.medicineName));
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Last 30 days'),
            const SizedBox(height: 8),
            for (final list in entries) ...[
              Builder(builder: (_) {
                final s = AdherenceStats.from(list);
                return Semantics(
                  container: true,
                  label: '${list.first.title}. Adherence ${s.percentText}. Taken ${s.taken}, '
                      'missed ${s.missed}, skipped ${s.skipped}, pending ${s.open}.',
                  child: ExcludeSemantics(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration:
                          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(list.first.title,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text('Taken ${s.taken} · Missed ${s.missed} · Skipped ${s.skipped} · '
                                'Pending ${s.open}'),
                          ]),
                        ),
                        Text(s.percentText,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                );
              }),
            ],
          ]);
        },
      ),
    );
  }
}
