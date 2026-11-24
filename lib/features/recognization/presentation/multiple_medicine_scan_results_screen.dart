import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/data/settings_controller.dart';
import '../../speech/speech_providers.dart';
import '../data/medicine_matcher.dart';
import '../data/recognition_providers.dart';
import '../domain/recognition_models.dart';
import 'status_banner.dart';

class MultipleMedicineScanResultsScreen extends ConsumerStatefulWidget {
  const MultipleMedicineScanResultsScreen({super.key});
  @override
  ConsumerState<MultipleMedicineScanResultsScreen> createState() => _State();
}

class _State extends ConsumerState<MultipleMedicineScanResultsScreen> {
  bool _merging = false;
  bool _spoke = false;

  List<String> _segments(ScanSession s) => [
        for (final p in s.packages) ...['Package ${p.index + 1}.', ...ScanWording.spokenSegments(p)],
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final s = ref.read(scanSessionProvider);
      if (s == null || _spoke || !ref.read(settingsProvider).accessibility.voiceNavigation) return;
      _spoke = true;
      if (mounted) await speakChecked(context, ref, _segments(s));
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scanSessionProvider);
    if (session == null) {
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text('No scan yet. Go back and scan a medicine.')));
    }
    final n = session.packages.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan results'),
        leading: IconButton(
            tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(session.imagePath), height: 160, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        ),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Text('Found $n possible package${n == 1 ? '' : 's'}. Each one is checked separately and '
              'information from different packages is never mixed. Open each result to hear it.'),
        ),
        const SizedBox(height: 12),
        for (final p in session.packages)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              button: true,
              label: 'Package ${p.index + 1}. ${ScanWording.headline(p)}. Open result.',
              child: ExcludeSemantics(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push('/scan/result/${p.index}'),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text('Package ${p.index + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    StatusBanner.forStatus(p.status, ScanWording.headline(p)),
                  ]),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _merging
              ? null
              : () async {
                  setState(() => _merging = true);
                  final registered = await ref.read(registeredMedicinesProvider.future);
                  final merged = await ref.read(scanPipelineProvider).mergeAll(session, registered, ref.read(ocrScriptsProvider));
                  ref.read(scanSessionProvider.notifier).set(merged);
                  if (mounted) {
                    setState(() => _merging = false);
                    context.pushReplacement('/scan/result/0');
                  }
                },
          child: Text(_merging ? 'Working…' : 'This is only one package'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => speakChecked(context, ref, _segments(session)),
          child: const Text('Read all results aloud'),
        ),
        const SizedBox(height: 8),
        const SpeechControls(),
      ]),
    );
  }
}
