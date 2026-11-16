import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/medivox_logo.dart';
import '../../localization/language_registry.dart';
import '../../onboarding/data/settings_controller.dart';

/// Milestone 1 home: shows setup status. Feature tiles are visibly DISABLED
/// (and announced as "not available yet") until their modules are built, so
/// nothing looks functional that is not.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static const _tiles = [
    (Icons.camera_alt, 'Scan Medicine'),
    (Icons.add_circle_outline, 'Add Medicine'),
    (Icons.medication, 'My Medicines'),
    (Icons.calendar_today, "Today's Schedule"),
    (Icons.notifications_active, 'Reminders'),
    (Icons.insights, 'Reports'),
  ];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final now = DateTime.now();
    final date =
        '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}';
    final name = (s.displayName == null || s.displayName!.isEmpty)
        ? ''
        : ', ${s.displayName}';
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Align(
                alignment: Alignment.centerLeft, child: MediVoxLogo(size: 36)),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text('${_greeting()}$name',
                  style:
                      t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ),
            Text(date, style: t.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your setup',
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Storage: ${s.storageMode.label}'),
                  Text(
                      'Language: ${languageByCode(s.preferredLanguage)?.englishName ?? 'English'}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                  'This early build contains setup and accessibility only. '
                  'The features below are being added and are not available yet.'),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                for (final tile in _tiles)
                  Semantics(
                    enabled: false,
                    label: '${tile.$2}, not available yet',
                    child: ExcludeSemantics(
                      child: Opacity(
                        opacity: 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(tile.$1, size: 36),
                              const SizedBox(height: 8),
                              Text(tile.$2, textAlign: TextAlign.center),
                              const Text('Coming soon',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(settingsProvider.notifier).resetAll();
                  if (context.mounted) context.go('/welcome');
                },
                child: const Text('Reset setup (debug builds only)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
