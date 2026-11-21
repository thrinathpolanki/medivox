import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medivox_logo.dart';
import '../data/settings_controller.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const _features = [
    (Icons.record_voice_over, 'Voice assistance'),
    (Icons.medication, 'Medicine identification'),
    (Icons.alarm, 'Smart reminders'),
    (Icons.translate, 'Multilingual support'),
    (Icons.accessibility_new, 'Accessibility features'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(child: MediVoxLogo(size: 44)),
              const SizedBox(height: 32),
              Semantics(
                header: true,
                child: Text('Welcome to MediVox',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 8),
              Text('Your intelligent medicine companion',
                  textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final f in _features)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          Icon(f.$1, color: AppColors.teal, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Text(f.$2, style: theme.textTheme.titleMedium)),
                        ]),
                      ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await ref.read(settingsProvider.notifier).markFirstLaunch();
                  if (context.mounted) context.push('/terms');
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
