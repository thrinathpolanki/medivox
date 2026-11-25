import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../localization/language_registry.dart';
import '../../onboarding/data/settings_controller.dart';
import '../../speech/medicine_speech.dart';
import '../../speech/speech_providers.dart';
import '../../speech/speech_service.dart';
import '../../voice_assistant/voice_intents.dart';
import '../data/reminder_providers.dart';
import '../domain/dose_models.dart';
import 'dose_action_buttons.dart';
import 'status_chip.dart';

/// Opened when a reminder is tapped (or when a dose is due while the app is
/// open). With screen-free reminders on, it announces the dose aloud. Nothing is
/// marked as taken until the user presses a button or clearly confirms by voice.
class ReminderNotificationScreen extends ConsumerStatefulWidget {
  const ReminderNotificationScreen({super.key, required this.doseId});
  final String doseId;
  @override
  ConsumerState<ReminderNotificationScreen> createState() => _State();
}

class _State extends ConsumerState<ReminderNotificationScreen> {
  bool _announced = false;
  bool _voiceBusy = false;
  String? _voiceMessage;
  bool _englishOffer = false;

  List<String> _announcement(DoseItem d) => [
        MedicineSpeech.doseAnnouncement(
            title: d.title, dosage: d.dosageText, food: d.food.label, at: d.scheduledAt),
      ];

  Future<void> _announce(DoseItem d, {bool english = false}) async {
    final settings = ref.read(settingsProvider);
    final lang = languageByCode(settings.preferredLanguage) ?? supportedLanguages.first;
    final svc = ref.read(speechServiceProvider);
    final a = settings.accessibility;
    final locale = english ? 'en-IN' : lang.bcp47;
    if (!english && await svc.availability(lang.bcp47) == VoiceAvailability.unavailable) {
      if (mounted) {
        setState(() {
          _englishOffer = true;
          _voiceMessage = 'No ${lang.englishName} voice is installed on this phone, so the reminder was '
              'not spoken. You can install one in Android Settings > Text-to-speech.';
        });
      }
      return;
    }
    await svc.speak(_announcement(d), locale: locale, rate: a.speechRate, volume: a.speechVolume);
  }

  Future<void> _say(String text) async {
    final a = ref.read(settingsProvider).accessibility;
    await ref.read(speechServiceProvider).speak([text], locale: 'en-IN', rate: a.speechRate, volume: a.speechVolume);
  }

  /// Voice answer with an explicit yes/no check before anything is recorded.
  Future<void> _voiceAnswer(DoseItem d) async {
    if (_voiceBusy) return;
    setState(() => _voiceBusy = true);
    final listener = ref.read(voiceListenerProvider);
    try {
      await _say('Say taken, snooze, or skip.');
      final action = VoiceIntentParser.doseAction(await listener.listenOnce());
      if (action == null) {
        await _say('I did not understand. Please use the buttons on the screen.');
        return;
      }
      final word = switch (action) { 'taken' => 'taken', 'snooze' => 'snoozed', _ => 'skipped' };
      await _say('Mark ${d.title} as $word? Say yes or no.');
      final yes = VoiceIntentParser.yesNo(await listener.listenOnce());
      if (yes != true) {
        await _say('Okay. Nothing was changed.');
        return;
      }
      await ref.read(reminderServiceProvider).actions.handle(d.dose.doseId, action);
      await _say('Done. ${d.title} is marked as $word.');
    } finally {
      if (mounted) setState(() => _voiceBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(doseItemProvider(widget.doseId));
    final screenFree = ref.watch(settingsProvider.select((s) => s.accessibility.screenFreeReminders));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(speechServiceProvider).stop();
            context.canPop() ? context.pop() : context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Could not load this reminder.')),
          data: (item) {
            if (item == null) return const Center(child: Text('This reminder no longer exists.'));
            final open = item.status == DoseStatus.pending ||
                item.status == DoseStatus.snoozed ||
                item.status == DoseStatus.missed;
            if (screenFree && open && !_announced) {
              _announced = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => _announce(item));
            }
            final t = item.scheduledAt;
            return ListView(padding: const EdgeInsets.all(24), children: [
              Icon(Icons.alarm, size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Semantics(
                header: true,
                child: Text('Time to take your medicine',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),
              Text(item.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (item.dosageText.isNotEmpty)
                Text(item.dosageText, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              Text(item.food.label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              Text('Scheduled for ${formatTime(t.hour, t.minute)}, ${formatDate(t)}', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Center(child: StatusChip(item.status)),
              if (_voiceMessage != null) ...[
                const SizedBox(height: 12),
                Semantics(liveRegion: true, child: Text(_voiceMessage!, textAlign: TextAlign.center)),
                if (_englishOffer)
                  TextButton(onPressed: () => _announce(item, english: true), child: const Text('Read in English')),
              ],
              const SizedBox(height: 24),
              if (open) ...[
                DoseActionButtons(item: item),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Hear this reminder'),
                  onPressed: () => _announce(item),
                ),
                const SizedBox(height: 8),
                const SpeechControls(),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: Text(_voiceBusy ? 'Listening…' : 'Answer by voice'),
                  onPressed: _voiceBusy ? null : () => _voiceAnswer(item),
                ),
              ] else
                FilledButton(onPressed: () => context.go('/home'), child: const Text('Done')),
              const SizedBox(height: 12),
              const Text('Please check the name and strength on the package before you take it.',
                  textAlign: TextAlign.center),
            ]);
          },
        ),
      ),
    );
  }
}
