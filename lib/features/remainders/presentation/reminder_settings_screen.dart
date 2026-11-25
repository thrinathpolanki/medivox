import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/reminder_providers.dart';
import '../data/reminder_service.dart';
import 'reminder_permission_card.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});
  @override
  ConsumerState<ReminderSettingsScreen> createState() => _State();
}

class _State extends ConsumerState<ReminderSettingsScreen> {
  int _snooze = 10;

  @override
  void initState() {
    super.initState();
    ReminderPrefs.snoozeMinutes().then((m) {
      if (mounted) setState(() => _snooze = m);
    });
  }

  Widget _row(bool ok, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(ok ? Icons.check_circle : Icons.error_outline,
              color: ok ? const Color(0xFF249B65) : Theme.of(context).colorScheme.error),
          const SizedBox(width: 10),
          Expanded(child: Text('$text: ${ok ? 'allowed' : 'not allowed'}')),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(reminderPermissionProvider).valueOrNull;
    final service = ref.read(reminderServiceProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Permissions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (perms == null)
          const Text('Checking…')
        else ...[
          _row(perms.notifications, 'Notifications'),
          _row(perms.exactAlarms, 'Exact alarms'),
        ],
        const ReminderPermissionCard(),
        const Divider(height: 32),
        Text('Snooze for', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final m in ReminderPrefs.snoozeOptions)
            ChoiceChip(
              label: Text('$m min'),
              selected: _snooze == m,
              onSelected: (_) async {
                await ReminderPrefs.setSnoozeMinutes(m);
                setState(() => _snooze = m);
              },
            ),
        ]),
        const Divider(height: 32),
        Text('Check that reminders work',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await service.gateway.scheduleTest(DateTime.now().add(const Duration(seconds: 10)));
              messenger.showSnackBar(const SnackBar(
                  content: Text('Test reminder set for 10 seconds from now. Lock your screen and wait.')));
            } catch (_) {
              messenger.showSnackBar(const SnackBar(content: Text('Could not schedule the test reminder.')));
            }
          },
          child: const Text('Send a test reminder in 10 seconds'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await service.resync();
            ref.invalidate(reminderPermissionProvider);
            messenger.showSnackBar(SnackBar(
                content: Text(service.lastError ?? 'Reminders refreshed')));
          },
          child: const Text('Refresh reminders'),
        ),
        const Divider(height: 32),
        const Text('How reminders work', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('A reminder never marks a medicine as taken. Only your own Taken, '
            'Skip or Snooze press counts. A dose that gets no answer for 2 hours is '
            'recorded as missed.\n\n'
            'Some phones stop apps in the background to save battery. If reminders are late '
            'or missing, set MediVox to "No restrictions" under the phone\'s battery '
            'settings for this app.\n\n'
            'Reminders are re-planned each time you open the app. If you change time zone, open '
            'MediVox once so times are recalculated.\n\n'
            'Spoken, screen-free reminders will arrive with the voice feature.'),
      ]),
    );
  }
}
