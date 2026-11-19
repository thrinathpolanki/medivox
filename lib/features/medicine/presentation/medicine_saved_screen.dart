import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../reminders/presentation/reminder_permission_card.dart';

class MedicineSavedScreen extends StatelessWidget {
  const MedicineSavedScreen({super.key, required this.medicineId});
  final String medicineId;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Medicine saved',
      subtitle: 'It is now in My Medicines. Reminders are planned from the schedule you set.',
      totalSteps: 4,
      primaryLabel: 'View medicine',
      onPrimary: () => context.go('/medicines/$medicineId'),
      secondaryLabel: 'Add another medicine',
      onSecondary: () => context.go('/medicines/add'),
      child: Column(children: [
        const Icon(Icons.check_circle, size: 96, color: AppColors.success),
        const ReminderPermissionCard(),
        const SizedBox(height: 8),
        TextButton(onPressed: () => context.go('/home'), child: const Text('Go to Home')),
      ]),
    );
  }
}
