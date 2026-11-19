import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/medicine_providers.dart';
import '../domain/medicine_models.dart';
import 'widgets/medicine_thumbnail.dart';

class MedicineReviewScreen extends ConsumerStatefulWidget {
  const MedicineReviewScreen({super.key});
  @override
  ConsumerState<MedicineReviewScreen> createState() => _State();
}

class _State extends ConsumerState<MedicineReviewScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final userId = await ref.read(activeProfileProvider.future);
      final id = await ref
          .read(medicineRepositoryProvider)
          .registerMedicine(userId: userId, draft: ref.read(medicineDraftProvider));
      // Files are now permanent; clear the draft without deleting them.
      await ref.read(medicineDraftProvider.notifier).reset(keepFiles: true);
      if (mounted) context.go('/medicines/saved/$id');
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not save the medicine. Nothing was changed. '
            'Check free storage and try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _row(String k, String v) => v.trim().isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 130, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text(v)),
          ]),
        );

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(medicineDraftProvider);
    final i = d.info;
    final scheme = Theme.of(context).colorScheme;
    return OnboardingScaffold(
      title: 'Review and save',
      subtitle: 'Please check that everything is correct.',
      step: 4,
      totalSteps: 4,
      primaryLabel: _saving ? 'Saving…' : 'Confirm and save',
      onPrimary: _saving ? null : _save,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in d.images.entries)
            MedicineThumbnail(path: e.value, size: 72, label: e.key.label),
        ]),
        const SizedBox(height: 16),
        _row('Name', i.name),
        _row('Generic name', i.genericName),
        _row('Strength', i.strength),
        _row('Composition', i.composition),
        _row('Manufacturer', i.manufacturer),
        _row('Type', i.medicineType),
        _row('Prescribed dosage', i.dosage),
        _row('Prescription ref.', i.prescriptionReference),
        _row('Notes', i.notes),
        const Divider(height: 28),
        Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
        if (d.schedules.isEmpty) const Text('No schedule. You can add one later.'),
        for (final s in d.schedules)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text('${s.period.label} at ${s.timeText}: ${s.dosage.trim()}, '
                '${s.food.label}. ${s.repeatText}. From ${formatDate(s.startDate)}'
                '${s.endDate == null ? '' : ' to ${formatDate(s.endDate!)}'}.'
                '${s.enabled ? '' : ' (reminder off)'}'),
          ),
        const SizedBox(height: 12),
        const Text('Dosages are exactly what you entered. MediVox never suggests or changes dosages.'),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: scheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_error!),
            ),
          ),
        ],
      ]),
    );
  }
}
