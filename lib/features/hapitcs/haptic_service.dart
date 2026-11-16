import 'package:flutter/services.dart';

import '../onboarding/domain/app_settings.dart';

/// Minimal haptics for Milestone 1. Distinct scan/reminder/error patterns
/// (custom vibration) arrive in Milestone 5. Never the only cue for events.
class HapticService {
  static Future<void> tap(AppSettings s) async {
    if (!s.accessibility.hapticFeedback) return;
    await HapticFeedback.lightImpact();
  }
}
