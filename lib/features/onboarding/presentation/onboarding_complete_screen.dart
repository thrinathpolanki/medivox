import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../localization/language_registry.dart';
import '../data/settings_controller.dart';

class OnboardingCompleteScreen extends ConsumerWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final lang = languageByCode(s.preferredLanguage);
    final rows = <String>[
      'Storage: ${s.storageMode.label}',
      'Language: ${lang?.englishName ?? 'English'}',
      'Accessibility settings saved',
    ];
    return OnboardingScaffold(
      title: "You're all set!",
      subtitle:
          'MediVox is configured. You can change any of this in Settings.',
      step: 8,
      primaryLabel: 'Go to Home',
      onPrimary: () async {
        await ref.read(settingsProvider.notifier).completeOnboarding();
        if (context.mounted) context.go('/home');
      },
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 96, color: AppColors.success),
          const SizedBox(height: 16),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                const Icon(Icons.check, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(r,
                        style: Theme.of(context).textTheme.titleMedium)),
              ]),
            ),
        ],
      ),
    );
  }
}
