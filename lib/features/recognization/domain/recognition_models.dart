import 'dart:ui' show Rect;

import '../../medicine/domain/medicine_models.dart';

class OcrLine {
  const OcrLine(this.text, this.box);
  final String text;
  final Rect box;
  double get height => box.height;
}

enum FieldConfidence { low, medium, high }

/// Something read from packaging. NEVER verified by itself: only the user can
/// verify it (by checking and editing it).
class ExtractedField {
  const ExtractedField(this.value, this.confidence, this.evidence);
  final String value;
  final FieldConfidence confidence;
  final String evidence;
}

class PackagingFields {
  const PackagingFields({
    this.nameCandidates = const [],
    this.strengths = const [],
    this.composition,
    this.manufacturer,
    this.batch,
    this.mfgDate,
    this.expiryDate,
    this.otherLines = const [],
  });
  final List<ExtractedField> nameCandidates;
  final List<ExtractedField> strengths;
  final ExtractedField? composition, manufacturer, batch, mfgDate, expiryDate;
  final List<String> otherLines;

  ExtractedField? get name => nameCandidates.isEmpty ? null : nameCandidates.first;
  bool get isEmpty =>
      nameCandidates.isEmpty && strengths.isEmpty && composition == null && manufacturer == null &&
      batch == null && mfgDate == null && expiryDate == null;
}

/// User-editable copy of extracted packaging text.
class PackagingEdit {
  const PackagingEdit({
    this.name = '',
    this.strength = '',
    this.composition = '',
    this.manufacturer = '',
    this.batch = '',
    this.mfgDate = '',
    this.expiryDate = '',
  });
  final String name, strength, composition, manufacturer, batch, mfgDate, expiryDate;

  factory PackagingEdit.fromFields(PackagingFields f) => PackagingEdit(
        name: f.name?.value ?? '',
        strength: f.strengths.map((s) => s.value).join(', '),
        composition: f.composition?.value ?? '',
        manufacturer: f.manufacturer?.value ?? '',
        batch: f.batch?.value ?? '',
        mfgDate: f.mfgDate?.value ?? '',
        expiryDate: f.expiryDate?.value ?? '',
      );

  PackagingEdit copyWith({
    String? name, String? strength, String? composition, String? manufacturer,
    String? batch, String? mfgDate, String? expiryDate,
  }) =>
      PackagingEdit(
        name: name ?? this.name,
        strength: strength ?? this.strength,
        composition: composition ?? this.composition,
        manufacturer: manufacturer ?? this.manufacturer,
        batch: batch ?? this.batch,
        mfgDate: mfgDate ?? this.mfgDate,
        expiryDate: expiryDate ?? this.expiryDate,
      );

  MedicineInfo toMedicineInfo() => MedicineInfo(
        name: name.trim(),
        strength: strength.trim(),
        composition: composition.trim(),
        manufacturer: manufacturer.trim(),
      );
}

/// confirmed = several independent signals agree; likely = name (and usually strength) agree;
/// possible = weaker evidence; conflict = name fits but strength/number does not.
enum MatchLevel { confirmed, likely, possible, conflict }

class MatchEvidence {
  const MatchEvidence(this.label, this.detail, {this.conflict = false});
  final String label, detail;
  final bool conflict;
}

class MedicineMatch {
  const MedicineMatch(this.medicine, this.score, this.level, this.evidence);
  final MedicineDetail medicine;
  final double score; // experimental indicator, NOT proof of identity
  final MatchLevel level;
  final List<MatchEvidence> evidence;
}

enum PackageStatus { unreadable, confirmed, likely, possible, conflict, ambiguous, unmatched }

class PackageResult {
  const PackageResult({
    required this.index,
    required this.bounds,
    required this.lines,
    required this.fields,
    required this.matches,
    required this.status,
    this.note,
    this.diagnostics = const [],
  });
  final int index;
  final Rect bounds;
  final List<OcrLine> lines;
  final PackagingFields fields;
  final List<MedicineMatch> matches; // best first, at most 3
  final PackageStatus status;
  final String? note;
  final List<String> diagnostics; // how each saved medicine scored (for troubleshooting)

  PackageResult withStatus(PackageStatus s) => PackageResult(
        index: index, bounds: bounds, lines: lines, fields: fields, matches: matches,
        status: s, note: note, diagnostics: diagnostics);

  String get rawText => lines.map((l) => l.text).join('\n');
  MedicineMatch? get best => matches.isEmpty ? null : matches.first;
}

class QualityReport {
  const QualityReport({
    required this.width,
    required this.height,
    required this.sharpness,
    required this.brightness,
    required this.problems,
  });
  final int width, height;
  final double sharpness; // Laplacian variance (higher = sharper)
  final double brightness; // 0..255
  final List<String> problems; // empty = acceptable
  bool get ok => problems.isEmpty;
}

class ScanSession {
  const ScanSession({
    required this.imagePath,
    required this.quality,
    required this.allLines,
    required this.packages,
    this.lowQualityOverride = false,
    this.confirmedMedicineId,
  });
  final String imagePath;
  final QualityReport? quality;
  final List<OcrLine> allLines;
  final List<PackageResult> packages;
  final bool lowQualityOverride;

  /// Set when a second photo agreed with the first on the same medicine.
  final String? confirmedMedicineId;
}
