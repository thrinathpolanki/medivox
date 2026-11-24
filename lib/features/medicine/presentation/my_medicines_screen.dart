import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/medicine_providers.dart';
import '../domain/medicine_models.dart';
import 'widgets/medicine_thumbnail.dart';

enum _Filter { all, withSchedule, noSchedule }

class MyMedicinesScreen extends ConsumerStatefulWidget {
  const MyMedicinesScreen({super.key});
  @override
  ConsumerState<MyMedicinesScreen> createState() => _State();
}

class _State extends ConsumerState<MyMedicinesScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;

  bool _match(MedicineDetail m) => switch (_filter) {
        _Filter.all => true,
        _Filter.withSchedule => m.schedules.isNotEmpty,
        _Filter.noSchedule => m.schedules.isEmpty,
      };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(medicineListProvider(_query));
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
        leading: IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            tooltip: 'Check for similar medicines',
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => context.push('/similar'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/medicines/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add medicine'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
                hintText: 'Search medicines', prefixIcon: Icon(Icons.search)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(spacing: 8, children: [
            for (final f in _Filter.values)
              ChoiceChip(
                label: Text(switch (f) {
                  _Filter.all => 'All',
                  _Filter.withSchedule => 'With schedule',
                  _Filter.noSchedule => 'No schedule',
                }),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
          ]),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Could not load your medicines. Please restart the app.'),
            )),
            data: (all) {
              final list = all.where(_match).toList();
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      all.isEmpty && _query.isEmpty
                          ? 'No medicines yet. Tap "Add medicine" to register your first one.'
                          : 'No medicines match your search or filter.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final m = list[i];
                  final med = m.medicine;
                  final title = [med.medicineName, if ((med.strength ?? '').isNotEmpty) med.strength!].join(' ');
                  return Semantics(
                    button: true,
                    label: '$title. ${med.dosage ?? ''}. ${m.scheduleSummary}. '
                        '${med.reminderEnabled ? 'Reminders on' : 'Reminders off'}',
                    child: ExcludeSemantics(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/medicines/${med.medicineId}'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            MedicineThumbnail(path: m.thumbnailPath, size: 72),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(title,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                                if ((med.dosage ?? '').isNotEmpty) Text(med.dosage!),
                                Text(m.scheduleSummary, style: Theme.of(context).textTheme.bodySmall),
                                Row(children: [
                                  Icon(med.reminderEnabled ? Icons.alarm_on : Icons.alarm_off, size: 16),
                                  const SizedBox(width: 4),
                                  Text(med.reminderEnabled ? 'Reminders on' : 'Reminders off',
                                      style: Theme.of(context).textTheme.bodySmall),
                                ]),
                              ]),
                            ),
                            const Icon(Icons.chevron_right),
                          ]),
                        ),
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
