import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../speech/speech_providers.dart';
import '../data/recognition_providers.dart';
import '../domain/recognition_models.dart';

/// Shows exactly what text was read. It never invents a name: no offline
/// medicine catalogue is installed, so unknown medicines are NOT identified.
class UnregisteredMedicineScreen extends ConsumerWidget {
  const UnregisteredMedicineScreen({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scanSessionProvider);
    if (s == null || index >= s.packages.length) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This result is no longer available.')));
    }
    final p = s.packages[index];
    final f = p.fields;
    final theme = Theme.of(context);

    Widget section(String title, List<String> items) => items.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              for (final i in items) Text('• $i'),
            ]),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text read from the package'),
        leading: IconButton(
            tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('This package does not match a registered medicine with enough confidence. '
            'MediVox has no medicine catalogue installed, so it cannot name an unknown medicine. '
            'Below is only the text it could read. It may contain mistakes.'),
        const SizedBox(height: 16),
        section('Possible names (from large text)',
            [for (final n in f.nameCandidates) '${n.value}  (${n.evidence})']),
        section('Strengths', [for (final x in f.strengths) x.value]),
        section('Composition', [if (f.composition != null) f.composition!.value]),
        section('Manufacturer', [if (f.manufacturer != null) f.manufacturer!.value]),
        section('Batch', [if (f.batch != null) f.batch!.value]),
        section('Expiry', [if (f.expiryDate != null) f.expiryDate!.value]),
        ExpansionTile(
          title: const Text('All text that was read'),
          children: [Padding(padding: const EdgeInsets.all(12), child: Text(p.rawText))],
        ),
        if (p.diagnostics.isNotEmpty)
          ExpansionTile(
            title: const Text('How this was checked'),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Closest of your saved medicines (name match and saved-photo text match):'),
                  const SizedBox(height: 6),
                  for (final d in p.diagnostics) Text('• $d'),
                  const SizedBox(height: 6),
                  const Text('A medicine needs a name match of about 65% or more, or matching text from its saved photos, to be suggested.'),
                ]),
              ),
            ],
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: f.isEmpty ? null : () => context.push('/scan/verify/$index'),
          child: const Text('Check details and register'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text('Read aloud'),
          onPressed: () => speakChecked(context, ref, [
            'This does not match your registered medicines.',
            if (f.name != null) 'The package text includes ${f.name!.value}.',
            for (final x in f.strengths) 'Strength ${x.value}.',
            'I have not identified this medicine. Please check the package yourself.',
          ]),
        ),
        const SizedBox(height: 8),
        const SpeechControls(),
        const SizedBox(height: 8),
        TextButton(onPressed: () => context.go('/scan'), child: const Text('Scan again')),
      ]),
    );
  }
}
