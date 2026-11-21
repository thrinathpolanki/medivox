import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/widgets/medivox_logo.dart';
import '../../reminders/data/reminder_providers.dart';
import '../data/settings_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(const Duration(milliseconds: 1800), _next);
  }

  Future<void> _next() async {
    // Wait (briefly) for the reminder engine so a tapped reminder can open its screen.
    String? launchDose;
    try {
      launchDose = await ref.read(reminderBootProvider.future).timeout(const Duration(seconds: 3));
    } catch (_) {}
    if (!mounted) return;
    final done = ref.read(settingsProvider).onboardingCompleted;
    context.go(done ? '/home' : '/welcome');
    if (done && launchDose != null) context.push('/reminder/$launchDose');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _c,
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0)
                .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: MediVoxLogo(size: 72, showTagline: true),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('${AppInfo.name} ${AppInfo.version}',
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
