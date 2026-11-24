import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../speech/speech_providers.dart';
import '../data/recognition_providers.dart';
import '../data/similar_medicine_checker.dart';

class SimilarMedicineWarningScreen extends ConsumerWidget {
  const SimilarMedicineWarningScreen({super.key, this.focusId});
  final String? focusId;

  String _t(w, bool first) {
    final m = (first ? w.a : w.b).medicine;
    final s = (m.strength ?? '').trim();
    return s.isEmpty ? m.medicineName : '${m.medicineName} $s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(similarWarningsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar medicines'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/medicines'),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not check your medicines.')),
        data: (all) {
          final list = focusId == null
              ? all
              : all.where((w) => w.a.medicine.medicineId == focusId || w.b.medicine.medicineId == focusId).toList();
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Compared using the details you entered for your registered medicines. MediVox '
                'only warns you: it never says medicines are the same and never suggests swapping one for another.'),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No similar medicines found among your registered medicines.',
                    textAlign: TextAlign.center),
              ),
            for (final w in list)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.error.withOpacity(0.6)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${_t(w, true)}  and  ${_t(w, false)}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  for (final r in w.reasons) Text('• $r'),
                  const SizedBox(height: 8),
                  const Text(SimilarMedicineChecker.message, style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
                      onPressed: () => context.push('/medicines/${w.a.medicine.medicineId}'),
                      child: Text(w.a.medicine.medicineName),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
                      onPressed: () => context.push('/medicines/${w.b.medicine.medicineId}'),
                      child: Text(w.b.medicine.medicineName),
                    ),
                    IconButton(
                      tooltip: 'Read this warning aloud',
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => speakChecked(context, ref, [
                        'Warning. ${_t(w, true)} and ${_t(w, false)}.',
                        ...w.reasons,
                        SimilarMedicineChecker.message,
                      ]),
                    ),
                  ]),
                ]),
              ),
            const SpeechControls(),
          ]);
        },
      ),
    );
  }
}
