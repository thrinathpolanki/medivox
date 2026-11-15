import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/settings_controller.dart';

class LocalProfileSetupScreen extends ConsumerStatefulWidget {
  const LocalProfileSetupScreen({super.key});
  @override
  ConsumerState<LocalProfileSetupScreen> createState() =>
      _LocalProfileSetupScreenState();
}

class _LocalProfileSetupScreenState
    extends ConsumerState<LocalProfileSetupScreen> {
  late final TextEditingController _name =
      TextEditingController(text: ref.read(settingsProvider).displayName ?? '');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Set up your profile',
      subtitle:
          'Your name is optional. No email or phone number is needed. Data stays on this device.',
      step: 5,
      primaryLabel: 'Continue',
      onPrimary: () async {
        await ref.read(settingsProvider.notifier).setLocalProfile(_name.text);
        if (context.mounted) context.push('/language');
      },
      child: TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Display name (optional)',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
    );
  }
}
