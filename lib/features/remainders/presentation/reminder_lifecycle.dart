import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routing/app_router.dart';
import '../../onboarding/data/settings_controller.dart';
import '../data/reminder_providers.dart';

/// Starts the reminder engine and refreshes it whenever the app returns to the
/// foreground. While the app is open and screen-free reminders are on, a dose
/// that becomes due opens its reminder screen (which announces it aloud).
/// (Speaking while the phone is locked and the app is closed would need an
/// Android foreground service and is NOT implemented.)
class ReminderLifecycle extends ConsumerStatefulWidget {
  const ReminderLifecycle({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<ReminderLifecycle> createState() => _State();
}

class _State extends ConsumerState<ReminderLifecycle> with WidgetsBindingObserver {
  Timer? _timer;
  AppLifecycleState _life = AppLifecycleState.resumed;
  final _announced = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(reminderBootProvider));
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkDue());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkDue() async {
    if (_life != AppLifecycleState.resumed) return;
    final s = ref.read(settingsProvider);
    if (!s.onboardingCompleted || !s.accessibility.screenFreeReminders) return;
    try {
      final due = await ref.read(doseRepositoryProvider).dueDoses(DateTime.now());
      for (final d in due) {
        if (_announced.add(d.dose.doseId)) {
          ref.read(routerProvider).push('/reminder/${d.dose.doseId}');
          break;
        }
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _life = state;
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(reminderPermissionProvider);
      ref.read(reminderServiceProvider).resync();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
