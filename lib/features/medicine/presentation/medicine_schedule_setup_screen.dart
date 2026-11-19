import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/medicine_providers.dart';
import 'widgets/schedule_list_editor.dart';

class MedicineScheduleSetupScreen extends ConsumerWidget {
  const MedicineScheduleSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(medicineDraftProvider);
    return OnboardingScaffold(
      title: 'Medicine schedule',
      subtitle: 'Add one entry for each time of day. Dosage is entered by you.',
      step: 3,
      totalSteps: 4,
      primaryLabel: 'Next',
      onPrimary: d.schedulesValid ? () => context.push('/medicines/add/review') : null,
      child: ScheduleListEditor(
        schedules: d.schedules,
        onChanged: (l) =>
            ref.read(medicineDraftProvider.notifier).update((x) => x.copyWith(schedules: l)),
      ),
    );
  }
}
