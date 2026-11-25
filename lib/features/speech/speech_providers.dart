import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/language_registry.dart';
import '../onboarding/data/settings_controller.dart';
import 'speech_service.dart';

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());
final voiceListenerProvider = Provider<VoiceListener>((ref) => VoiceListener());

/// Speaks [segments] in the user's chosen language using their speed/volume.
/// If the phone has no voice for that language it asks before using English.
Future<void> speakChecked(BuildContext context, WidgetRef ref, List<String> segments) async {
  final settings = ref.read(settingsProvider);
  final lang = languageByCode(settings.preferredLanguage) ?? supportedLanguages.first;
  final svc = ref.read(speechServiceProvider);
  final a = settings.accessibility;
  final avail = await svc.availability(lang.bcp47);
  if (avail == VoiceAvailability.unavailable) {
    if (!context.mounted) return;
    final english = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('No ${lang.englishName} voice on this phone'),
        content: Text('Your phone has no ${lang.englishName} text-to-speech voice. You can install '
            'one in Android Settings > Text-to-speech. Do you want this read in English instead?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Read in English')),
        ],
      ),
    );
    if (english != true) return;
    await svc.speak(segments, locale: 'en-IN', rate: a.speechRate, volume: a.speechVolume);
    return;
  }
  await svc.speak(segments, locale: lang.bcp47, rate: a.speechRate, volume: a.speechVolume);
}

/// Play / Pause / Resume, Replay and Stop for whatever is being read aloud.
/// Three equal, evenly spaced controls with an icon above a one-line label.
class SpeechControls extends ConsumerWidget {
  const SpeechControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.watch(speechServiceProvider);
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<SpeechState>(
      valueListenable: svc.state,
      builder: (context, st, _) {
        final has = svc.hasContent;
        final (icon1, label1, action1) = switch (st) {
          SpeechState.speaking => (Icons.pause_circle_outline, 'Pause', svc.pause),
          SpeechState.paused => (Icons.play_circle_outline, 'Resume', svc.resume),
          SpeechState.idle => (Icons.play_circle_outline, 'Play', has ? svc.repeat : null),
        };
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Expanded(child: _ControlButton(icon: icon1, label: label1, onPressed: action1)),
            Expanded(
              child: _ControlButton(
                  icon: Icons.replay, label: 'Replay', onPressed: has ? svc.repeat : null),
            ),
            Expanded(
              child: _ControlButton(
                  icon: Icons.stop_circle_outlined,
                  label: 'Stop',
                  onPressed: st == SpeechState.idle ? null : svc.stop),
            ),
          ]),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.35);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? () => onPressed!() : null,
          child: SizedBox(
            height: 64,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    maxLines: 1,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Speaks only if the phone has a voice for the user's language; otherwise stays
/// silent (used for optional hints, never for important results).
Future<void> speakQuiet(WidgetRef ref, List<String> segments) async {
  final s = ref.read(settingsProvider);
  final lang = languageByCode(s.preferredLanguage) ?? supportedLanguages.first;
  final svc = ref.read(speechServiceProvider);
  if (await svc.availability(lang.bcp47) == VoiceAvailability.unavailable) return;
  await svc.speak(segments,
      locale: lang.bcp47, rate: s.accessibility.speechRate, volume: s.accessibility.speechVolume);
}
