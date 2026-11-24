import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/language_registry.dart';
import '../../medicine/data/medicine_providers.dart';
import '../../medicine/domain/medicine_models.dart';
import '../../onboarding/data/settings_controller.dart';
import '../domain/recognition_models.dart';
import 'image_analysis.dart';
import 'medicine_matcher.dart';
import 'ocr_service.dart';
import 'registered_text_index.dart';
import 'scan_pipeline.dart';
import 'similar_medicine_checker.dart';

final Provider<OcrService> ocrServiceProvider = Provider<OcrService>((ref) => MlKitOcrService());

final Provider<RegisteredTextIndex> registeredTextIndexProvider =
    Provider<RegisteredTextIndex>((ref) => RegisteredTextIndex(ref.watch(ocrServiceProvider)));

/// Reads the printed text of saved medicine photos in the background so scans are fast.
final Provider<Future<void> Function()> textIndexWarmupProvider = Provider<Future<void> Function()>((ref) => () async {
      final userId = await ref.read(activeProfileProvider.future);
      final meds = await ref.read(medicineRepositoryProvider).watchAll(userId).first;
      await ref.read(registeredTextIndexProvider).warm(meds, ref.read(ocrScriptsProvider));
    });

final Provider<ScanPipeline> scanPipelineProvider = Provider<ScanPipeline>((ref) => ScanPipeline(
      index: ref.watch(registeredTextIndexProvider),
      ocr: ref.watch(ocrServiceProvider),
      quality: const ImageQualityAnalyzer(),
      look: LookAnalyzer(),
      matcher: const MedicineMatcher(),
    ));

/// Scripts to run text recognition with, from the user's chosen language.
final Provider<Set<OcrScript>> ocrScriptsProvider = Provider<Set<OcrScript>>((ref) {
  final code = ref.watch(settingsProvider.select((s) => s.preferredLanguage));
  return (languageByCode(code) ?? supportedLanguages.first).ocrScripts;
});

class ScanSessionController extends Notifier<ScanSession?> {
  @override
  ScanSession? build() => null;
  void set(ScanSession? s) => state = s;
}

final scanSessionProvider = NotifierProvider<ScanSessionController, ScanSession?>(ScanSessionController.new);

final registeredMedicinesProvider = FutureProvider.autoDispose<List<MedicineDetail>>((ref) async {
  final userId = await ref.watch(activeProfileProvider.future);
  return ref.watch(medicineRepositoryProvider).watchAll(userId).first;
});

final similarWarningsProvider = Provider.autoDispose<AsyncValue<List<SimilarityWarning>>>(
    (ref) => ref.watch(medicineListProvider('')).whenData(SimilarMedicineChecker.check));

/// Medicine id waiting for a second photo to confirm it.
class ScanConfirmController extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final NotifierProvider<ScanConfirmController, String?> scanConfirmProvider =
    NotifierProvider<ScanConfirmController, String?>(ScanConfirmController.new);
