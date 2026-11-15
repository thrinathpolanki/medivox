import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../../haptics/haptic_service.dart';
import '../data/settings_controller.dart';
import '../domain/app_settings.dart';

class AccessibilitySetupScreen extends ConsumerWidget {
  const AccessibilitySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final a = settings.accessibility;
    final ctrl = ref.read(settingsProvider.notifier);

    Future<void> update(AccessibilitySettings n) async {
      await ctrl.updateAccessibility(n);
      await HapticService.tap(ref.read(settingsProvider));
    }

    Widget sw(String title, String sub, bool v,
            AccessibilitySettings Function(bool) f) =>
        SwitchListTile(
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(sub),
          value: v,
          onChanged: (x) => update(f(x)),
        );

    return OnboardingScaffold(
      title: 'Accessibility options',
      subtitle: 'You can change these any time in Settings.',
      step: 7,
      primaryLabel: 'Continue',
      onPrimary: () => context.push('/complete'),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              sw(
                  'Voice navigation',
                  'Control the app by voice. The microphone is only used after you start it, and permission is asked then.',
                  a.voiceNavigation,
                  (x) => a.copyWith(voiceNavigation: x)),
              sw(
                  'Screen reader support',
                  'Extra spoken labels for TalkBack.',
                  a.screenReaderSupport,
                  (x) => a.copyWith(screenReaderSupport: x)),
              sw('Large text', 'Increase text size by 25%.', a.largeText,
                  (x) => a.copyWith(largeText: x)),
              sw('High contrast', 'Stronger colours and borders.',
                  a.highContrast, (x) => a.copyWith(highContrast: x)),
              sw(
                  'Haptic feedback',
                  'Gentle vibration cues. Never the only signal.',
                  a.hapticFeedback,
                  (x) => a.copyWith(hapticFeedback: x)),
              sw(
                  'Screen-free reminders',
                  'Spoken reminders without looking at the screen (activated with the reminder feature).',
                  a.screenFreeReminders,
                  (x) => a.copyWith(screenFreeReminders: x)),
            ]),
          ),
          const SizedBox(height: 16),
          _SliderTile(
            label: 'Text size',
            value: a.fontScale,
            min: 0.8,
            max: 1.6,
            divisions: 8,
            display: '${(a.fontScale * 100).round()}%',
            onChanged: (v) =>
                ctrl.updateAccessibility(a.copyWith(fontScale: v)),
          ),
          _SliderTile(
            label: 'Speech speed',
            value: a.speechRate,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            display: a.speechRate.toStringAsFixed(1),
            note: 'Takes effect when voice output is added.',
            onChanged: (v) =>
                ctrl.updateAccessibility(a.copyWith(speechRate: v)),
          ),
          _SliderTile(
            label: 'Speech volume',
            value: a.speechVolume,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            display: '${(a.speechVolume * 100).round()}%',
            note: 'Takes effect when voice output is added.',
            onChanged: (v) =>
                ctrl.updateAccessibility(a.copyWith(speechVolume: v)),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child:
                const Text('Preview: Paracetamol 500 mg, 1 tablet after food.'),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
    this.note,
  });
  final String label, display;
  final String? note;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $display',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: display,
          semanticFormatterCallback: (_) => '$label $display',
          onChanged: onChanged,
        ),
        if (note != null)
          Text(note!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
