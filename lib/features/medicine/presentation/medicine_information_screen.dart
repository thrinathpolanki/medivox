import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/medicine_providers.dart';
import 'widgets/medicine_info_form.dart';

class MedicineInformationScreen extends ConsumerStatefulWidget {
  const MedicineInformationScreen({super.key});
  @override
  ConsumerState<MedicineInformationScreen> createState() => _State();
}

class _State extends ConsumerState<MedicineInformationScreen> {
  final _key = GlobalKey<FormState>();
  late var _info = ref.read(medicineDraftProvider).info;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Medicine details',
      subtitle: 'Type exactly what is on the package or prescription.',
      step: 2,
      totalSteps: 4,
      primaryLabel: 'Next',
      onPrimary: () {
        if (!(_key.currentState?.validate() ?? false)) return;
        ref.read(medicineDraftProvider.notifier).update((d) => d.copyWith(info: _info));
        context.push('/medicines/add/schedule');
      },
      child: MedicineInfoForm(
        formKey: _key,
        initial: _info,
        onChanged: (i) => _info = i,
      ),
    );
  }
}
