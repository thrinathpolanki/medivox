import 'dart:math' as math;

import '../../medicine/domain/medicine_models.dart';
import '../../medicine/domain/medicine_plan.dart';
import '../domain/recognition_models.dart';
import '../domain/text_utils.dart';
import 'packaging_parser.dart';

/// Experimental, configurable. A score is an indicator, never proof.
class MatchConfig {
  const MatchConfig({
    this.wName = 0.40,
    this.wGeneric = 0.10,
    this.wStrength = 0.20,
    this.wComposition = 0.15,
    this.wManufacturer = 0.05,
    this.wLook = 0.05,
    this.wPrint = 0.30,
    this.likelyName = 0.85,
    this.confirmName = 0.90,
    this.possibleName = 0.65,
    this.printAdmit = 0.60,
    this.printStrong = 0.80,
    this.ambiguousGap = 0.08,
    this.minReadableChars = 12,
  });
  final double wName, wGeneric, wStrength, wComposition, wManufacturer, wLook, wPrint;
  final double confirmName, likelyName, possibleName, printAdmit, printStrong, ambiguousGap;
  final int minReadableChars;
}

class MatchOutcome {
  const MatchOutcome(this.matches, this.status, [this.note, this.diagnostics = const []]);
  final List<MedicineMatch> matches;
  final PackageStatus status;
  final String? note;
  final List<String> diagnostics;
}

class MedicineMatcher {
  const MedicineMatcher([this.config = const MatchConfig()]);
  final MatchConfig config;

  static bool isReadable(String text, int minChars) =>
      RegExp(r'[A-Za-z0-9\u0900-\u097F]').allMatches(text).length >= minChars;

  /// Evidence used for each saved medicine:
  ///  * its name (without strength / "tablets" words) found in the scanned text,
  ///  * strength and composition agreement,
  ///  * the printed text of its own saved photos ([printText]) found in the scan,
  ///  * an experimental packaging-look signal ([lookScore]).
  Future<MatchOutcome> match(
    PackagingFields fields,
    String fullText,
    List<MedicineDetail> registered, {
    Future<double?> Function(MedicineDetail)? lookScore,
    Future<String?> Function(MedicineDetail)? printText,
  }) async {
    if (!isReadable(fullText, config.minReadableChars)) {
      return const MatchOutcome([], PackageStatus.unreadable,
          'Too little readable text. Retake the photo closer, in good light.');
    }
    final hay = TextUtils.tokens(fullText);
    final haySet = hay.toSet();
    final ocrStrengths = Strength.findAll(fullText);
    final ocrNumbers = {for (final t in hay) if (RegExp(r'^\d{2,4}$').hasMatch(t)) t};
    final matches = <MedicineMatch>[];
    final diag = <(double, String)>[];

    for (final m in registered) {
      final med = m.medicine;
      final evidence = <MatchEvidence>[];

      final core = TextUtils.nameCore(med.medicineName);
      final needle = core.isEmpty ? med.medicineName : core;
      final contiguous = TextUtils.partialSimilarity(needle, hay, fold: true);
      // Words found anywhere count too, but are capped below the "confirmed" name level.
      final nameScore = math.max(contiguous, math.min(0.88, TextUtils.tokenCoverage(needle, hay)));

      final nameNums = TextUtils.nameNumbers(med.medicineName);
      final numberConflict = nameNums.isNotEmpty && ocrNumbers.isNotEmpty && !nameNums.every(ocrNumbers.contains);

      final genericName = (med.genericName ?? '').trim();
      final genericScore = genericName.isEmpty ? null : TextUtils.partialSimilarity(TextUtils.nameCore(genericName), hay, fold: true);

      final regStrengths = Strength.findAll(med.strength ?? '');
      double? strengthScore;
      var strengthConflict = false;
      if (regStrengths.isNotEmpty && ocrStrengths.isNotEmpty) {
        final allFound = regStrengths.every((r) => ocrStrengths.any((o) => o.sameAs(r)));
        strengthScore = allFound ? 1.0 : 0.0;
        strengthConflict = !allFound;
      }

      final regIng = TextUtils.ingredientTokens('${med.composition ?? ''} $genericName');
      double? compScore;
      if (regIng.isNotEmpty) {
        compScore = regIng.where((t) => haySet.contains(t) || TextUtils.partialSimilarity(t, hay, fold: true) >= 0.85).length /
            regIng.length;
      }
      final mfr = (med.manufacturer ?? '').trim();
      final mfrScore = mfr.isEmpty ? null : TextUtils.partialSimilarity(mfr, hay, fold: true);

      double? printScore;
      if (printText != null) {
        final pt = await printText(m);
        if (pt != null && pt.trim().isNotEmpty) {
          printScore = TextUtils.printOverlap(fullText, pt, exclude: TextUtils.tokens(mfr).toSet());
        }
      }

      diag.add((
        math.max(nameScore, printScore ?? 0),
        '${med.medicineName}: name ${(nameScore * 100).round()}%'
            '${printScore == null ? '' : ', saved-photo text ${(printScore * 100).round()}%'}'
            '${strengthScore == null ? '' : strengthScore == 1 ? ', strength matches' : ', strength differs'}'
      ));

      final brandFound = nameScore >= config.possibleName;
      final genericFound = genericScore != null && genericScore >= config.likelyName;
      final printFound = printScore != null && printScore >= config.printAdmit;
      if (!brandFound && !genericFound && !printFound && !(compScore != null && compScore >= 0.7 && nameScore >= 0.5)) {
        continue;
      }

      double? look;
      if (lookScore != null) look = await lookScore(m);

      if (nameScore > 0.4) {
        evidence.add(MatchEvidence('Name',
            'The name "${med.medicineName}" ${nameScore >= 0.999 ? 'appears' : 'looks similar to text'} on the package (${(nameScore * 100).round()}% text match).'));
      }
      if (printFound) {
        evidence.add(MatchEvidence('Saved photos',
            'The printed text on your saved photos matches this package (${(printScore * 100).round()}%).'));
      }
      if (genericFound && !brandFound) {
        evidence.add(MatchEvidence('Generic name',
            'The generic name "$genericName" appears, but not the brand name. This may be a different brand of the same ingredient.'));
      }
      if (strengthScore == 1.0) {
        evidence.add(MatchEvidence('Strength', 'Strength ${med.strength} found on the package.'));
      } else if (strengthConflict) {
        evidence.add(MatchEvidence(
            'Strength',
            'Your record says ${med.strength}, but the package shows ${ocrStrengths.map((s) => s.display).join(', ')}. Please check carefully.',
            conflict: true));
      } else if (regStrengths.isNotEmpty) {
        evidence.add(const MatchEvidence('Strength', 'No strength could be read on the package.'));
      }
      if (numberConflict) {
        evidence.add(MatchEvidence('Number in name',
            'Your medicine name includes ${nameNums.join(', ')}, which was not found on the package. Please check carefully.',
            conflict: true));
      }
      if (compScore != null && compScore > 0) {
        evidence.add(MatchEvidence('Composition', '${(compScore * 100).round()}% of the ingredients you saved were found.'));
      }
      if (mfrScore != null && mfrScore >= 0.8) {
        evidence.add(MatchEvidence('Manufacturer', 'Manufacturer "$mfr" appears on the package.'));
      }
      if (look != null && look >= 0.75) {
        evidence.add(const MatchEvidence('Packaging look (experimental)', 'Looks fairly similar to your saved photos.'));
      }

      var total = config.wName * nameScore, weight = config.wName;
      void add(double? v, double w) {
        if (v == null) return;
        total += w * v;
        weight += w;
      }
      add(genericScore, config.wGeneric);
      add(strengthScore, config.wStrength);
      add(compScore, config.wComposition);
      add(mfrScore, config.wManufacturer);
      add(look, config.wLook);
      add(printScore, config.wPrint);
      var score = total / weight;
      if (!brandFound && !printFound) score = math.min(score, 0.6);

      final conflict = strengthConflict || numberConflict;
      final MatchLevel level;
      if (conflict) {
        level = MatchLevel.conflict;
      } else if (nameScore >= config.likelyName) {
        // "Confirmed" needs the name AND at least two more independent signals,
        // and the strength must agree whenever a strength was saved.
        final signals = [
          nameScore >= config.confirmName,
          strengthScore == 1.0,
          (compScore ?? 0) >= 0.7,
          (mfrScore ?? 0) >= 0.8,
          (printScore ?? 0) >= config.printAdmit,
          (look ?? 0) >= 0.75,
        ].where((x) => x).length;
        final strengthOk = regStrengths.isEmpty || strengthScore == 1.0;
        level = (nameScore >= config.confirmName && strengthOk && signals >= 3)
            ? MatchLevel.confirmed
            : MatchLevel.likely;
      } else if (printScore != null &&
          printScore >= config.printStrong &&
          ((compScore ?? 0) >= 0.7 || strengthScore == 1.0)) {
        level = MatchLevel.likely;
      } else {
        level = MatchLevel.possible;
      }
      matches.add(MedicineMatch(m, score, level, evidence));
    }

    diag.sort((a, b) => b.$1.compareTo(a.$1));
    final diagnostics = [for (final d in diag.take(4)) d.$2];
    matches.sort((a, b) => b.score.compareTo(a.score));
    // The same medicine saved more than once (same name and strength) is ONE medicine.
    final seen = <String, MedicineMatch>{};
    var duplicates = 0;
    for (final mt in matches) {
      final med = mt.medicine.medicine;
      final key = '${TextUtils.normalize(med.medicineName)}|'
          '${Strength.findAll(med.strength ?? '').map((x) => '${x.unitClass}${x.value}').join(',')}';
      final cur = seen[key];
      if (cur == null) {
        seen[key] = mt;
      } else {
        duplicates++;
        final better = mt.score > cur.score + 0.05 ||
            (mt.score >= cur.score - 0.05 && mt.medicine.schedules.length > cur.medicine.schedules.length);
        if (better) seen[key] = mt;
      }
    }
    final top = (seen.values.toList()..sort((a, b) => b.score.compareTo(a.score))).take(3).toList();
    final dupNote = duplicates > 0
        ? 'This medicine is saved more than once in My Medicines. Delete the extra copy to avoid confusion.'
        : null;
    if (top.isEmpty) return MatchOutcome(const [], PackageStatus.unmatched, null, diagnostics);

    if (top.length > 1 && (top[0].score - top[1].score).abs() < config.ambiguousGap) {
      return MatchOutcome(top, PackageStatus.ambiguous,
          'More than one of your medicines fits this text. Check the package yourself.', diagnostics);
    }
    final status = switch (top.first.level) {
      MatchLevel.confirmed => PackageStatus.confirmed,
      MatchLevel.likely => PackageStatus.likely,
      MatchLevel.possible => PackageStatus.possible,
      MatchLevel.conflict => PackageStatus.conflict,
    };
    return MatchOutcome(top, status, dupNote, diagnostics);
  }
}

/// Spoken / on-screen wording for a package result. It never names a medicine
/// unless it was found in the user's own registered list.
class ScanWording {
  static const verify = 'Please check the name and strength on the package before you take it.';
  static const footnote =
      'Automatic reading can make mistakes. If the package looks different from the result, scan again.';

  static String headline(PackageResult r) => switch (r.status) {
        PackageStatus.unreadable => 'Could not read this package clearly.',
        PackageStatus.confirmed => 'Matched: ${_t(r.best!)}',
        PackageStatus.likely => 'Likely match: ${r.best!.medicine.medicine.medicineName}',
        PackageStatus.possible => 'Possible match: ${r.best!.medicine.medicine.medicineName}',
        PackageStatus.conflict => 'Name matches ${r.best!.medicine.medicine.medicineName}, but the strength differs',
        PackageStatus.ambiguous => 'More than one possible match',
        PackageStatus.unmatched => 'Not one of your registered medicines',
      };

  /// Only a confident match (Matched / Likely) says what to take: the medicine name,
  /// when to take it and how much, straight from the user's saved data. Anything less
  /// certain says so and gives NO dosage.
  static List<String> spokenSegments(PackageResult r) {
    if ((r.status == PackageStatus.confirmed || r.status == PackageStatus.likely) && r.best != null) {
      return MedicinePlan.sentences(r.best!.medicine);
    }
    return [spoken(r)];
  }

  static String spoken(PackageResult r) {
    final b = r.best;
    switch (r.status) {
      case PackageStatus.unreadable:
        return 'I could not read this package clearly. Please retake the photo in good light, closer to the package.';
      case PackageStatus.confirmed:
      case PackageStatus.likely:
        return MedicinePlan.sentences(b!.medicine).join(' ');
      case PackageStatus.possible:
        return 'I am not sure which medicine this is. It may be ${_t(b!)}. Please scan again or check the package yourself.';
      case PackageStatus.conflict:
        return 'The name looks like ${b!.medicine.medicine.medicineName}, but the strength on the package does not match your record. Please check very carefully before taking it.';
      case PackageStatus.ambiguous:
        return 'More than one of your medicines could fit. I cannot tell which. Please check the package yourself.';
      case PackageStatus.unmatched:
        final n = r.fields.name?.value;
        return n == null
            ? 'This does not match your registered medicines, and I could not read a clear name. Please check the package yourself.'
            : 'This does not match your registered medicines. The package text includes "$n", but I have not identified the medicine. Please check the package yourself.';
    }
  }

  static String _t(MedicineMatch m) {
    final med = m.medicine.medicine;
    final s = (med.strength ?? '').trim();
    return s.isEmpty ? med.medicineName : '${med.medicineName} $s';
  }

  static String expiryWarning(ExpiryState s) => switch (s) {
        ExpiryState.expired => 'The expiry date looks like it has passed. If it was read correctly, do not take this medicine. Ask a pharmacist.',
        ExpiryState.expiringSoon => 'This medicine expires within 30 days, if the date was read correctly.',
        _ => '',
      };
}
