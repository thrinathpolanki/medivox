import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';

class AccessibilitySetupScreen extends StatefulWidget {
  const AccessibilitySetupScreen({super.key});

  @override
  State<AccessibilitySetupScreen> createState() =>
      _AccessibilitySetupScreenState();
}

class _AccessibilitySetupScreenState extends State<AccessibilitySetupScreen> {
  bool _voiceNav = true;
  bool _largeText = false;
  bool _highContrast = false;
  bool _haptic = true;
  bool _screenFree = true;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();

    // Rule: Store userId if not already exists
    if (!prefs.containsKey(AppConstants.prefUserId)) {
      await prefs.setString(AppConstants.prefUserId, const Uuid().v4());
    }

    await prefs.setBool('access_voice', _voiceNav);
    await prefs.setBool('access_large_text', _largeText);
    await prefs.setBool('access_high_contrast', _highContrast);
    await prefs.setBool('access_haptic', _haptic);
    await prefs.setBool('access_screen_free', _screenFree);
    await prefs.setBool(AppConstants.prefOnboardingCompleted, true);

    if (mounted) context.go('/onboarding-complete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility Options')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Voice Navigation'),
            subtitle: const Text('Enable spoken feedback for app interactions'),
            value: _voiceNav,
            onChanged: (v) => setState(() => _voiceNav = v),
          ),
          SwitchListTile(
            title: const Text('Large Text'),
            subtitle: const Text(
              'Increase the size of text throughout the app',
            ),
            value: _largeText,
            onChanged: (v) => setState(() => _largeText = v),
          ),
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Improve readability for low vision'),
            value: _highContrast,
            onChanged: (v) => setState(() => _highContrast = v),
          ),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate for confirmations and alerts'),
            value: _haptic,
            onChanged: (v) => setState(() => _haptic = v),
          ),
          SwitchListTile(
            title: const Text('Screen-free Reminders'),
            subtitle: const Text('Voice announcements when reminders trigger'),
            value: _screenFree,
            onChanged: (v) => setState(() => _screenFree = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _finish, child: const Text('Finish Setup')),
        ],
      ),
    );
  }
}
