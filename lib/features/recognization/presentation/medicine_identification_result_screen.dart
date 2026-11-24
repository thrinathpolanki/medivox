import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../haptics/haptic_service.dart';
import '../../medicine/domain/medicine_plan.dart';
import '../../onboarding/data/settings_controller.dart';
import '../../speech/speech_providers.dart';
import '../data/medicine_matcher.dart';
import '../data/packaging_parser.dart';
import '../data/recognition_providers.dart';
import '../data/similar_medicine_checker.dart';
import '../domain/recognition_models.dart';
import 'status_banner.dart';

class MedicineIdentificationResultScreen extends ConsumerStatefulWidget {
  const MedicineIdentificationResultScreen({super.key, required this.index});
  final int index;
  @override
  ConsumerState<MedicineIdentificationResultScreen> createState() => _State();
}

class _State extends ConsumerState<MedicineIdentificationResultScreen> {
  bool _spoke = false;

  PackageResult? _pkg() {
    final s = ref.read(scanSessionProvider);
    if (s == null || widget.index >= s.packages.length) return null;
    return s.packages[widget.index];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = _pkg();
      if (p == null || _spoke) return;
      _spoke = true;
      final settings = ref.read(settingsProvider);
      if (p.best != null &&
          (p.status == PackageStatus.confirmed || p.status == PackageStatus.likely || p.status == PackageStatus.possible)) {
        await HapticService.identified(settings);
      }
      if (settings.accessibility.voiceNavigation && mounted) {
        final exp = PackagingParser.expiryState(p.fields.expiryDate?.value, DateTime.now());
        final warn = ScanWording.expiryWarning(exp);
        await speakChecked(context, ref, [...ScanWording.spokenSegments(p), if (warn.isNotEmpty) warn]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scanSessionProvider);
    final p = _pkg();
    if (session == null || p == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This result is no longer available.')));
    }
    final theme = Theme.of(context);
    final exp = PackagingParser.expiryState(p.fields.expiryDate?.value, DateTime.now());
    final expText = ScanWording.expiryWarning(exp);
    final registered = ref.watch(registeredMedicinesProvider).valueOrNull ?? const [];
    final best = p.best;
    final similar = <SimilarityWarning>[];
    if (best != null) {
      for (final other in registered) {
        if (other.medicine.medicineId == best.medicine.medicine.medicineId) continue;
        final w = SimilarMedicineChecker.comparePair(best.medicine, other);
        if (w != null) similar.add(w);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.packages.length > 1 ? 'Package ${p.index + 1}' : 'Scan result'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/scan'),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        StatusBanner.forStatus(p.status, ScanWording.headline(p),
            detail: (session.confirmedMedicineId != null && p.best?.medicine.medicine.medicineId == session.confirmedMedicineId)
                ? 'Two separate photos agree.'
                : p.note),
        if (session.lowQualityOverride) ...[
          const SizedBox(height: 8),
          const Text('The photo quality was low, so this result may be wrong.'),
        ],
        if (expText.isNotEmpty) ...[
          const SizedBox(height: 12),
          StatusBanner(icon: Icons.event_busy, color: theme.colorScheme.error, text: expText),
        ],
        const SizedBox(height: 12),
        if (p.status == PackageStatus.confirmed || p.status == PackageStatus.likely)
          Text(ScanWording.footnote, style: theme.textTheme.bodySmall)
        else
          Text(ScanWording.verify, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (best != null && (p.status == PackageStatus.confirmed || p.status == PackageStatus.likely)) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(MedicinePlan.title(best.medicine),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Your saved plan', style: theme.textTheme.labelLarge),
              for (final l in MedicinePlan.lines(best.medicine))
                Padding(padding: const EdgeInsets.only(top: 4), child: Text(l, style: const TextStyle(fontSize: 17))),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        for (final m in p.matches) ...[
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                [m.medicine.medicine.medicineName, if ((m.medicine.medicine.strength ?? '').isNotEmpty) m.medicine.medicine.strength!].join(' '),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Text('Match indicator ${(m.score * 100).round()}% (experimental, not proof)',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              for (final e in m.evidence)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(e.conflict ? Icons.warning_amber_rounded : Icons.check,
                        size: 18, color: e.conflict ? theme.colorScheme.error : null),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${e.label}: ${e.detail}')),
                  ]),
                ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await HapticService.identified(ref.read(settingsProvider));
                      if (context.mounted) context.push('/medicines/${m.medicine.medicine.medicineId}');
                    },
                    child: Text(p.status == PackageStatus.confirmed || p.status == PackageStatus.likely
                        ? 'Open medicine details'
                        : 'Matches my package'),
                  ),
                ),
              ]),
            ]),
          ),
        ],
        if (similar.isNotEmpty)
          StatusBanner(
            icon: Icons.compare_arrows,
            color: theme.colorScheme.error,
            text: 'Similar medicine warning',
            detail: SimilarMedicineChecker.message,
          ),
        if (similar.isNotEmpty)
          TextButton(
            onPressed: () => context.push('/similar?focus=${best!.medicine.medicine.medicineId}'),
            child: const Text('See similar medicines'),
          ),
        const SizedBox(height: 8),
        if (best != null && (p.status == PackageStatus.likely || p.status == PackageStatus.possible))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Double-check with another photo')),
              onPressed: () {
                ref.read(scanConfirmProvider.notifier).set(best.medicine.medicine.medicineId);
                context.go('/scan');
              },
            ),
          ),
        OutlinedButton(
          onPressed: () => context.push('/scan/unregistered/${p.index}'),
          child: Text(p.matches.isEmpty ? 'See what was read' : 'None of these match: see what was read'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
            onPressed: () => context.go('/scan'),
            child: const Text('Scan again')),
        const Divider(height: 28),
        FilledButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text('Read result aloud'),
          onPressed: () => speakChecked(context, ref, [...ScanWording.spokenSegments(p), if (expText.isNotEmpty) expText]),
        ),
        const SizedBox(height: 8),
        const SpeechControls(),
      ]),
    );
  }
}
