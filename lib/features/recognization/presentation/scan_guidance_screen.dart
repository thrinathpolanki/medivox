import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../speech/speech_providers.dart';

class ScanGuidanceScreen extends ConsumerWidget {
  const ScanGuidanceScreen({super.key});

  static const steps = [
    'Put the medicine on a plain, flat surface in good light.',
    'Hold the phone about 20 to 30 centimetres above it, parallel to the package.',
    'Keep the printed name and strength inside the picture, and keep your hand steady.',
    'Avoid glare: tilt the package slightly if the foil shines.',
    'Take one package at a time for the most reliable result. Several packages side by side also work, but are checked separately.',
    'Tablet colour, shape or size alone can never identify a medicine. MediVox reads printed text only.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to scan'),
        leading: IconButton(
            tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 14, child: Text('${i + 1}')),
              const SizedBox(width: 12),
              Expanded(child: Text(steps[i], style: Theme.of(context).textTheme.bodyLarge)),
            ]),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text('Read these instructions aloud'),
          onPressed: () => speakChecked(context, ref, ['How to scan.', ...steps]),
        ),
        const SizedBox(height: 12),
        const SpeechControls(),
      ]),
    );
  }
}
