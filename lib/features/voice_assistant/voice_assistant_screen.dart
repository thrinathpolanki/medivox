import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/format.dart';
import '../medicine/data/medicine_providers.dart';
import '../onboarding/data/settings_controller.dart';
import '../recognition/data/recognition_providers.dart';
import '../reminders/data/reminder_providers.dart';
import '../reminders/domain/dose_models.dart';
import '../speech/speech_providers.dart';
import 'voice_intents.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});
  @override
  ConsumerState<VoiceAssistantScreen> createState() => _State();
}

class _State extends ConsumerState<VoiceAssistantScreen> {
  bool _listening = false;
  String _heard = '';
  String _reply = 'Tap the microphone, then say a command. Say "help" to hear what I can do.';

  static const helpText = 'You can say: scan medicine. Read the medicine packaging. Read my medicines. '
      'What medicines should I take today. What medicines have I missed. Show my reminders. '
      'Open my reports. Go home.';

  Future<void> _say(String text) async {
    final a = ref.read(settingsProvider).accessibility;
    // Replies are English text, so they are spoken with an English voice.
    await ref.read(speechServiceProvider).speak([text], locale: 'en-IN', rate: a.speechRate, volume: a.speechVolume);
  }

  Future<void> _listen() async {
    if (_listening) return;
    await ref.read(speechServiceProvider).stop();
    setState(() {
      _listening = true;
      _heard = '';
    });
    final listener = ref.read(voiceListenerProvider);
    final words = await listener.listenOnce();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _heard = words ?? '';
    });
    if (words == null) {
      final err = listener.lastError;
      final msg = err == null
          ? 'I did not hear anything. Tap the microphone and try again.'
          : 'Speech recognition did not work ($err). It may need microphone permission or an internet connection.';
      setState(() => _reply = msg);
      await _say(msg);
      return;
    }
    final reply = await _handle(VoiceIntentParser.parse(words), words);
    if (!mounted) return;
    setState(() => _reply = reply);
    await _say(reply);
  }

  Future<String> _handle(VoiceIntent intent, String words) async {
    switch (intent) {
      case VoiceIntent.scanMedicine:
        context.push('/scan');
        return 'Opening the scanner. Take a photo of the medicine package.';
      case VoiceIntent.readPackaging:
        context.push('/packaging');
        return 'Opening the packaging reader.';
      case VoiceIntent.showReminders:
        context.push('/schedule');
        return 'Showing your schedule and reminders.';
      case VoiceIntent.openReports:
        context.push('/reports');
        return 'Opening your reports.';
      case VoiceIntent.goHome:
        context.go('/home');
        return 'Going home.';
      case VoiceIntent.openSettings:
        return 'The settings screen is not available yet in this version.';
      case VoiceIntent.help:
        return helpText;
      case VoiceIntent.readMedicines:
        final meds = await ref.read(registeredMedicinesProvider.future);
        if (meds.isEmpty) return 'You have no registered medicines yet.';
        final names = meds.map((m) {
          final s = (m.medicine.strength ?? '').trim();
          return s.isEmpty ? m.medicine.medicineName : '${m.medicine.medicineName} $s';
        }).join('. ');
        return 'You have ${meds.length} medicine${meds.length == 1 ? '' : 's'}. $names.';
      case VoiceIntent.todayDoses:
        final userId = await ref.read(activeProfileProvider.future);
        final day = dateOnly(DateTime.now());
        final items = await ref
            .read(doseRepositoryProvider)
            .watchRange(userId, day, DateTime(day.year, day.month, day.day + 1))
            .first;
        if (items.isEmpty) return 'You have no doses scheduled for today.';
        final open = items.where((d) => d.status == DoseStatus.pending || d.status == DoseStatus.snoozed).toList();
        final taken = items.where((d) => d.status == DoseStatus.taken).length;
        if (open.isEmpty) return 'You have no doses left today. You have taken $taken.';
        final parts = open.map((d) =>
            '${d.title}${d.dosageText.isEmpty ? '' : ', ${d.dosageText}'}, ${d.food.label}, at ${formatTime(d.scheduledAt.hour, d.scheduledAt.minute)}');
        return 'You have ${open.length} dose${open.length == 1 ? '' : 's'} left today. ${parts.join('. ')}.';
      case VoiceIntent.missedDoses:
        final userId = await ref.read(activeProfileProvider.future);
        final day = dateOnly(DateTime.now());
        final items = await ref
            .read(doseRepositoryProvider)
            .watchRange(userId, DateTime(day.year, day.month, day.day - 6), DateTime(day.year, day.month, day.day + 1))
            .first;
        final missed = items.where((d) => d.status == DoseStatus.missed).toList();
        if (missed.isEmpty) return 'You have not missed any doses in the last 7 days.';
        final parts = missed.map((d) => '${d.title} on ${formatDate(d.scheduledAt)} at ${formatTime(d.scheduledAt.hour, d.scheduledAt.minute)}');
        return 'You missed ${missed.length} dose${missed.length == 1 ? '' : 's'} in the last 7 days. ${parts.join('. ')}.';
      case VoiceIntent.unknown:
        return 'Sorry, I did not understand "$words". Say help to hear what I can do.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(
          child: Semantics(
            button: true,
            label: _listening ? 'Listening' : 'Tap to speak a command',
            child: ExcludeSemantics(
              child: GestureDetector(
                onTap: _listening ? null : _listen,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _listening ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                  child: Icon(_listening ? Icons.hearing : Icons.mic, size: 64, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text(_listening ? 'Listening…' : 'Tap to speak', style: theme.textTheme.titleMedium)),
        const SizedBox(height: 24),
        if (_heard.isNotEmpty) ...[
          Text('You said', style: theme.textTheme.labelLarge),
          Text('"$_heard"', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
        ],
        Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Text(_reply, style: theme.textTheme.bodyLarge),
          ),
        ),
        const SizedBox(height: 12),
        const SpeechControls(),
        const Divider(height: 32),
        const Text('Good to know', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('MediVox listens only after you tap the microphone, and stops by itself. '
            'Commands are understood in English for now. Your phone\'s speech recognizer does the '
            'listening, and on many phones it needs an internet connection. Without it, use the '
            'buttons on screen.'),
      ]),
    );
  }
}
