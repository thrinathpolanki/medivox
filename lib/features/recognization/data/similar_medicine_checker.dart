import '../../medicine/domain/medicine_models.dart';
import '../domain/text_utils.dart';

enum SimilarityKind { similarName, sameNameDifferentStrength, sharedIngredient }

class SimilarityWarning {
  const SimilarityWarning(this.a, this.b, this.kinds, this.reasons, this.severity);
  final MedicineDetail a, b;
  final Set<SimilarityKind> kinds;
  final List<String> reasons;
  final int severity; // higher = more important
}

class SimilarMedicineChecker {
  static const message =
      'These medicines appear similar. Please verify the name, strength and composition before taking either medicine.';

  /// Compares medicines using the details the user entered. It never says two
  /// medicines are identical and never suggests substituting one for another.
  static List<SimilarityWarning> check(List<MedicineDetail> meds, {double nameThreshold = 0.7}) {
    final out = <SimilarityWarning>[];
    for (var i = 0; i < meds.length; i++) {
      for (var j = i + 1; j < meds.length; j++) {
        final w = comparePair(meds[i], meds[j], nameThreshold: nameThreshold);
        if (w != null) out.add(w);
      }
    }
    out.sort((x, y) => y.severity.compareTo(x.severity));
    return out;
  }

  static SimilarityWarning? comparePair(MedicineDetail x, MedicineDetail y, {double nameThreshold = 0.7}) {
    final a = x.medicine, b = y.medicine;
    final kinds = <SimilarityKind>{};
    final reasons = <String>[];
    var severity = 0;

    final sName = TextUtils.similarity(a.medicineName, b.medicineName);
    final sameName = TextUtils.normalize(a.medicineName) == TextUtils.normalize(b.medicineName);
    final sa = _strengths(a.strength), sb = _strengths(b.strength);
    final strengthDiffers = sa.isNotEmpty && sb.isNotEmpty &&
        !(sa.every((s) => sb.any((t) => t.sameAs(s))) && sb.every((s) => sa.any((t) => t.sameAs(s))));

    if (sameName && strengthDiffers) {
      kinds.add(SimilarityKind.sameNameDifferentStrength);
      reasons.add('Same name, different strengths (${a.strength} and ${b.strength}).');
      severity += 3;
    } else if (!sameName && sName >= nameThreshold) {
      kinds.add(SimilarityKind.similarName);
      reasons.add('The names look or sound alike ("${a.medicineName}" and "${b.medicineName}").');
      severity += 2;
      if (strengthDiffers) {
        reasons.add('Their strengths are different (${a.strength} and ${b.strength}).');
        severity += 1;
      }
    }

    final ia = TextUtils.ingredientTokens('${a.composition ?? ''} ${a.genericName ?? ''}');
    final ib = TextUtils.ingredientTokens('${b.composition ?? ''} ${b.genericName ?? ''}');
    final shared = ia.intersection(ib);
    if (shared.isNotEmpty) {
      kinds.add(SimilarityKind.sharedIngredient);
      reasons.add('Both list the ingredient ${shared.take(3).join(', ')}. Ask your doctor or pharmacist before taking both.');
      severity += 2;
    }
    if (kinds.isEmpty) return null;
    return SimilarityWarning(x, y, kinds, reasons, severity);
  }
}

List<Strength> _strengths(String? s) => s == null ? const [] : Strength.findAll(s);
