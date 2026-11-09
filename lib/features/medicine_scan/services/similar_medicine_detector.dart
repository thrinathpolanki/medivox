import '../../../database/app_database.dart';

class SimilarMedicineWarning {
  final Medicine target;
  final List<Medicine> similar;
  final String reason;

  const SimilarMedicineWarning({
    required this.target,
    required this.similar,
    required this.reason,
  });
}

class SimilarMedicineDetector {
  /// Returns warnings for medicines that look/sound similar to [target].
  static List<SimilarMedicineWarning> findSimilar({
    required Medicine target,
    required List<Medicine> allMedicines,
  }) {
    final warnings = <SimilarMedicineWarning>[];

    for (final other in allMedicines) {
      if (other.medicineId == target.medicineId) continue;

      // Same active ingredient, different strengths → warn
      if (target.composition != null &&
          target.composition!.isNotEmpty &&
          other.composition != null &&
          other.composition!.isNotEmpty &&
          target.composition!.toLowerCase() ==
              other.composition!.toLowerCase() &&
          target.strength != other.strength) {
        warnings.add(SimilarMedicineWarning(
          target: target,
          similar: [other],
          reason:
              'Same composition as "${other.medicineName}" but different strength. Verify before taking.',
        ));
        continue;
      }

      // Names differ by small edit distance
      final distance = _levenshtein(
          target.medicineName.toLowerCase(), other.medicineName.toLowerCase());
      if (distance <= 2 &&
          target.medicineName.length > 3 &&
          target.medicineName.toLowerCase() !=
              other.medicineName.toLowerCase()) {
        warnings.add(SimilarMedicineWarning(
          target: target,
          similar: [other],
          reason: 'Name is similar to "${other.medicineName}". Please verify.',
        ));
      }
    }

    return warnings;
  }

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final matrix = List.generate(
      a.length + 1,
      (i) => List<int>.filled(b.length + 1, 0),
    );
    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
    }
    return matrix[a.length][b.length];
  }
}
