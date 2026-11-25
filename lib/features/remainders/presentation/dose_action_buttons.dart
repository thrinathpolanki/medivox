import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/format.dart';
import '../../haptics/haptic_service.dart';
import '../../onboarding/data/settings_controller.dart';
import '../data/reminder_providers.dart';
import '../data/reminder_service.dart';
import '../domain/dose_models.dart';

/// Taken / Snooze / Skip. Every status change comes from an explicit press here.
class DoseActionButtons extends ConsumerWidget {
  const DoseActionButtons({super.key, required this.item});
  final DoseItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = item.status;
    final today = dateOnly(DateTime.now());
    final day = dateOnly(item.scheduledAt);
    final canAct = (s == DoseStatus.pending || s == DoseStatus.snoozed || s == DoseStatus.missed) &&
        !day.isAfter(today);
    final canSnooze = (s == DoseStatus.pending || s == DoseStatus.snoozed) && day == today;
    if (!canAct) return const SizedBox.shrink();

    Future<void> run(String message, Future<void> Function(DoseActions) f) async {
      final messenger = ScaffoldMessenger.of(context);
      await f(ref.read(reminderServiceProvider).actions);
      await HapticService.tap(ref.read(settingsProvider));
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }

    final id = item.dose.doseId;
    return Row(children: [
      Expanded(
        child: FilledButton(
          onPressed: () => run('Marked as taken', (a) => a.taken(id)),
          child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Taken')),
        ),
      ),
      if (canSnooze) ...[
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => run('Snoozed', (a) => a.snooze(id)),
            child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Snooze')),
          ),
        ),
      ],
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton(
          onPressed: () => run('Marked as skipped', (a) => a.skipped(id)),
          child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Skip')),
        ),
      ),
    ]);
  }
}
