import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/medicine_providers.dart';
import '../domain/medicine_models.dart';

class AddMedicineScreen extends ConsumerWidget {
  const AddMedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const steps = [
      (Icons.photo_camera, '1. Photos', 'Photograph the strip front, back and the tablet.'),
      (Icons.edit_note, '2. Details', 'Name, strength, composition and prescribed dosage.'),
      (Icons.alarm, '3. Schedule', 'Times, food instructions and repeat days.'),
      (Icons.fact_check, '4. Review and save', 'Check everything before saving.'),
    ];
    return OnboardingScaffold(
      title: 'Add a medicine',
      subtitle: 'Four short steps. Everything is stored on this device.',
      totalSteps: 4,
      primaryLabel: 'Start',
      onPrimary: () async {
        await ref.read(medicineDraftProvider.notifier).reset();
        if (context.mounted) context.push('/medicines/add/photos');
      },
      child: Column(children: [
        for (final s in steps)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration:
                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Icon(s.$1, size: 30, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(s.$3),
                ]),
              ),
            ]),
          ),
        Text('At least ${MedicineConfig.minImages} photos are needed to save. '
            'MediVox never suggests or changes dosages: you enter them from your prescription.'),
      ]),
    );
  }
}
