import 'package:flutter/services.dart';

import '../onboarding/domain/app_settings.dart';

/// Simple haptic patterns. Never the only signal for an important event.
/// (Custom vibration waveforms and intensity arrive with the `vibration` package later.)
class HapticService {
  static Future<void> tap(AppSettings s) async {
    if (!s.accessibility.hapticFeedback) return;
    await HapticFeedback.lightImpact();
  }

  /// One short vibration: photo captured / scan completed.
  static Future<void> scanDone(AppSettings s) => tap(s);

  /// Two short vibrations: a medicine was matched.
  static Future<void> identified(AppSettings s) async {
    if (!s.accessibility.hapticFeedback) return;
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await HapticFeedback.mediumImpact();
  }

  /// One longer, heavier pattern: something went wrong.
  static Future<void> error(AppSettings s) async {
    if (!s.accessibility.hapticFeedback) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.vibrate();
  }
}
