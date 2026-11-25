import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reminder_providers.dart';

/// Shows only what is still missing. Permissions are requested ONLY when the
/// user presses a button here (never at app start or during onboarding).
class ReminderPermissionCard extends ConsumerWidget {
  const ReminderPermissionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(reminderPermissionProvider).valueOrNull;
    if (perms == null || perms.allGood) return const SizedBox.shrink();
    final gateway = ref.read(notificationGatewayProvider);
    final theme = Theme.of(context);

    Future<void> after() async {
      ref.invalidate(reminderPermissionProvider);
      await ref.read(reminderServiceProvider).resync();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(
          header: true,
          child: Text('Reminders need your permission',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
        if (!perms.notifications) ...[
          const Text('Allow notifications so MediVox can alert you when it is time '
              'to take a medicine.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await gateway.requestNotifications();
              await after();
            },
            child: const Text('Allow notifications'),
          ),
        ] else ...[
          const Text('Allow exact alarms so reminders arrive on time. Without this, '
              'Android may delay them by several minutes.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await gateway.requestExact();
              await after();
            },
            child: const Text('Allow exact timing'),
          ),
        ],
      ]),
    );
  }
}
