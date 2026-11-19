import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/presentation/status_chip.dart';
import '../data/medicine_providers.dart';
import '../domain/medicine_models.dart';
import 'widgets/medicine_thumbnail.dart';

class MedicineDetailScreen extends ConsumerWidget {
  const MedicineDetailScreen({super.key, required this.medicineId});
  final String medicineId;

  Widget _row(String k, String? v) => (v == null || v.trim().isEmpty)
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 130, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text(v)),
          ]),
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(medicineDetailProvider(medicineId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine details'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/medicines'),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load this medicine.')),
        data: (m) {
          if (m == null) return const Center(child: Text('This medicine no longer exists.'));
          final med = m.medicine;
          return ListView(padding: const EdgeInsets.all(20), children: [
            Semantics(
              header: true,
              child: Text(med.medicineName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            if (m.sortedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (final img in m.sortedImages)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.file(File(img.localPath),
                                  errorBuilder: (_, __, ___) => const Padding(
                                      padding: EdgeInsets.all(24), child: Text('Photo file not found'))),
                            ),
                          ),
                        ),
                        child: MedicineThumbnail(
                            path: img.localPath,
                            size: 120,
                            label: '${img.imageType.replaceAll('_', ' ')} ${img.imageSequence}'),
                      ),
                    ),
                ]),
              ),
            const SizedBox(height: 16),
            _row('Generic name', med.genericName),
            _row('Strength', med.strength),
            _row('Composition', med.composition),
            _row('Manufacturer', med.manufacturer),
            _row('Type', med.medicineType),
            _row('Prescribed dosage', med.dosage),
            _row('Prescription ref.', med.prescriptionReference),
            _row('Notes', med.notes),
            const Divider(height: 32),
            Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            if (m.schedules.isEmpty) const Text('No schedule set.'),
            for (final s in m.sortedSchedules)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(() {
                  final d = ScheduleDraft.fromRow(s);
                  return '${d.period.label} ${d.timeText}: ${d.dosage}, ${d.food.label}. '
                      '${d.repeatText}. From ${formatDate(d.startDate)}'
                      '${d.endDate == null ? '' : ' to ${formatDate(d.endDate!)}'}'
                      '${d.enabled ? '' : ' (reminder off)'}';
                }()),
              ),
            const Divider(height: 32),
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Consumer(builder: (context, ref, _) {
              final doses = ref.watch(medicineDosesProvider(medicineId)).valueOrNull ?? const [];
              if (doses.isEmpty) {
                return const Text('No dose history yet. Taken, skipped and missed doses will appear here.');
              }
              return Column(children: [
                for (final d in doses)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(
                          child: Text('${formatDate(d.scheduledAt)}, '
                              '${formatTime(d.scheduledAt.hour, d.scheduledAt.minute)}')),
                      StatusChip(d.status),
                    ]),
                  ),
              ]);
            }),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              onPressed: () => context.push('/medicines/$medicineId/edit'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              label: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () => context.push('/medicines/$medicineId/delete'),
            ),
          ]);
        },
      ),
    );
  }
}
