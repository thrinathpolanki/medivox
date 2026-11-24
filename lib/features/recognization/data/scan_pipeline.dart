import 'dart:io';
import 'dart:typed_data';

import '../../localization/language_registry.dart';
import '../../medicine/domain/medicine_models.dart';
import '../domain/recognition_models.dart';
import 'image_analysis.dart';
import 'medicine_matcher.dart';
import 'ocr_service.dart';
import 'package_clusterer.dart';
import 'packaging_parser.dart';
import '../domain/text_utils.dart';
import 'registered_text_index.dart';

/// quality check -> OCR (+ enhanced second pass if nothing matched) -> split into
/// packages -> parse -> match each package against your registered medicines using
/// name, strength, composition AND the printed text of your saved photos.
/// Information from different packages is never combined (except when YOU say it
/// is one package, or when separate parts matched nothing but the whole photo does).
class ScanPipeline {
  ScanPipeline({
    required this.ocr,
    required this.quality,
    required this.look,
    required this.matcher,
    required this.index,
  });
  final OcrService ocr;
  final ImageQualityAnalyzer quality;
  final LookAnalyzer look;
  final MedicineMatcher matcher;
  final RegisteredTextIndex index;

  final Map<String, LookSignature?> _registeredLooks = {};

  Future<QualityReport> checkQuality(String imagePath) async =>
      quality.analyze(await File(imagePath).readAsBytes());

  static bool _anyMatch(ScanSession s) => s.packages.any((p) => p.matches.isNotEmpty);

  static List<OcrLine> _mergeLines(List<OcrLine> a, List<OcrLine> b) {
    final out = [...a];
    for (final e in b) {
      if (!out.any((l) => overlapRatio(l.box, e.box) > 0.5)) out.add(e);
    }
    return out;
  }

  Future<ScanSession> run(
    String imagePath, {
    required List<MedicineDetail> registered,
    required Set<OcrScript> scripts,
    QualityReport? report,
    bool lowQualityOverride = false,
    void Function(String)? onProgress,
  }) async {
    onProgress?.call('Reading the text…');
    var lines = await ocr.read(imagePath, scripts);
    Future<ScanSession> build(List<PackageCluster> c) =>
        _build(imagePath, report, lines, c, registered, scripts, lowQualityOverride, onProgress);

    var session = await build(PackageClusterer.cluster(lines));

    if (!_anyMatch(session)) {
      onProgress?.call('Trying an enhanced reading…');
      try {
        final enhanced = await enhanceToFile(imagePath);
        if (enhanced != null) {
          final merged = _mergeLines(lines, await ocr.read(enhanced, scripts));
          if (merged.length > lines.length) {
            lines = merged;
            session = await build(PackageClusterer.cluster(lines));
          }
        }
      } catch (_) {}
    }
    if (!_anyMatch(session) && session.packages.length > 1) {
      final single = await build([PackageClusterer.single(lines)]);
      if (_anyMatch(single)) session = single;
    }
    if (!_anyMatch(session)) {
      // The package may have been photographed sideways: try both quarter turns.
      onProgress?.call('Checking the other orientation…');
      for (final turns in [1, 3]) {
        try {
          final rotated = await rotateToFile(imagePath, turns);
          if (rotated == null) continue;
          final rl = await ocr.read(rotated, scripts);
          if (rl.length < 2) continue;
          final s2 = await _build(imagePath, report, rl, [PackageClusterer.single(rl)], registered, scripts,
              lowQualityOverride, onProgress);
          if (_anyMatch(s2)) {
            session = s2;
            break;
          }
        } catch (_) {}
      }
    }
    return _collapseSameMedicine(session, (c) => build(c), lines);
  }

  static String _medKey(MedicineDetail m) {
    final med = m.medicine;
    return '${TextUtils.normalize(med.medicineName)}|'
        '${Strength.findAll(med.strength ?? '').map((x) => '${x.unitClass}${x.value}').join(',')}';
  }

  /// One strip often prints the name several times and gets split into several
  /// "packages". When EVERY part matched the same medicine, it is one result:
  /// re-read all the text together as a single package.
  Future<ScanSession> _collapseSameMedicine(
    ScanSession s,
    Future<ScanSession> Function(List<PackageCluster>) build,
    List<OcrLine> lines,
  ) async {
    if (s.packages.length < 2) return s;
    final keys = <String>{};
    for (final p in s.packages) {
      final b = p.best;
      final ok = b != null &&
          (p.status == PackageStatus.confirmed ||
              p.status == PackageStatus.likely ||
              p.status == PackageStatus.possible);
      if (!ok) return s;
      keys.add(_medKey(b.medicine));
    }
    if (keys.length != 1) return s;
    final merged = await build([PackageClusterer.single(lines)]);
    return merged.packages.any((p) => p.best != null) ? merged : s;
  }

  /// Treats all text as ONE package (when the clusterer split a single package).
  Future<ScanSession> mergeAll(ScanSession s, List<MedicineDetail> registered, Set<OcrScript> scripts) =>
      _build(s.imagePath, s.quality, s.allLines, [PackageClusterer.single(s.allLines)], registered, scripts,
          s.lowQualityOverride, null);

  Future<ScanSession> _build(
    String imagePath,
    QualityReport? report,
    List<OcrLine> all,
    List<PackageCluster> clusters,
    List<MedicineDetail> registered,
    Set<OcrScript> scripts,
    bool lowOverride,
    void Function(String)? onProgress,
  ) async {
    final bytes = clusters.isEmpty ? null : await File(imagePath).readAsBytes();
    final printCache = <String, Future<String>>{};
    Future<String?> printText(MedicineDetail m) => printCache.putIfAbsent(
        m.medicine.medicineId,
        () => index.textFor(m, scripts, onWork: () => onProgress?.call('Preparing your saved medicines…')));

    final packages = <PackageResult>[];
    for (var i = 0; i < clusters.length; i++) {
      final c = clusters[i];
      final fields = PackagingParser.parse(c.lines);
      final text = (c.lines.toList()..sort((a, b) => a.box.top.compareTo(b.box.top))).map((l) => l.text).join('\n');
      final crop = clusters.length == 1 ? null : [c.bounds.left, c.bounds.top, c.bounds.width, c.bounds.height];
      final outcome = await matcher.match(
        fields,
        text,
        registered,
        lookScore: (m) => _lookScore(bytes!, crop, m),
        printText: printText,
      );
      // A low-quality photo can never give a "Matched" (fully confirmed) result.
      final status = (lowOverride && outcome.status == PackageStatus.confirmed)
          ? PackageStatus.likely
          : outcome.status;
      packages.add(PackageResult(
        index: i,
        bounds: c.bounds,
        lines: c.lines,
        fields: fields,
        matches: outcome.matches,
        status: status,
        note: outcome.note,
        diagnostics: outcome.diagnostics,
      ));
    }
    return ScanSession(
        imagePath: imagePath, quality: report, allLines: all, packages: packages, lowQualityOverride: lowOverride);
  }

  Future<double?> _lookScore(Uint8List bytes, List<double>? crop, MedicineDetail m) async {
    final query = await look.signature(bytes, crop: crop);
    if (query == null) return null;
    double? best;
    for (final img in m.sortedImages.where((i) => i.imageType == 'strip_front' || i.imageType == 'strip_back').take(4)) {
      final sig = _registeredLooks.containsKey(img.localPath)
          ? _registeredLooks[img.localPath]
          : await _loadSig(img.localPath);
      if (sig == null) continue;
      final s = query.similarity(sig);
      if (best == null || s > best) best = s;
    }
    return best;
  }

  Future<LookSignature?> _loadSig(String path) async {
    try {
      final sig = await look.signature(await File(path).readAsBytes());
      _registeredLooks[path] = sig;
      return sig;
    } catch (_) {
      return null;
    }
  }
}
