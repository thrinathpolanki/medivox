import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../core/widgets/option_card.dart';
import '../domain/storage_mode.dart';

/// Nothing is pre-selected: the user must explicitly choose. The choice is
/// only persisted by the next step (local profile saved / Google sign-in OK).
class StorageSelectionScreen extends StatefulWidget {
  const StorageSelectionScreen({super.key});
  @override
  State<StorageSelectionScreen> createState() => _StorageSelectionScreenState();
}

class _StorageSelectionScreenState extends State<StorageSelectionScreen> {
  StorageMode _choice = StorageMode.none;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'How would you like to store your data?',
      subtitle: 'You can change this later in Settings.',
      step: 4,
      primaryLabel: 'Continue',
      onPrimary: _choice == StorageMode.none
          ? null
          : () => context.push(
              _choice == StorageMode.local ? '/local-profile' : '/google-signin'),
      child: Column(
        children: [
          OptionCard(
            icon: Icons.phone_android,
            title: 'Local Storage',
            description:
                'Keep all data on this device. No cloud account needed. Works offline. No Firebase and no uploads.',
            selected: _choice == StorageMode.local,
            onTap: () => setState(() => _choice = StorageMode.local),
          ),
          const SizedBox(height: 16),
          OptionCard(
            icon: Icons.cloud_outlined,
            title: 'Continue with Google',
            description:
                'Sign in with Google for secure cloud backup and sync across devices. Your data is still available offline.',
            selected: _choice == StorageMode.google,
            onTap: () => setState(() => _choice = StorageMode.google),
          ),
        ],
      ),
    );
  }
}
