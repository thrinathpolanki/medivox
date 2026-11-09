import 'dart:convert';
import 'dart:math' as math;
import '../../../database/app_database.dart';

class MatchCandidate {
  final Medicine medicine;
  final double confidence;
  final List<String> evidence;

  const MatchCandidate({
    required this.medicine,
    required this.confidence,
    required this.evidence,
  });
}

class MatchingResult {
  final List<MatchCandidate> candidates;
  final String extractedText;

  const MatchingResult({
    required this.candidates,
    required this.extractedText,
  });

  MatchCandidate? get best => candidates.isEmpty ? null : candidates.first;
}

class MatchingEngine {
  static MatchingResult match({
    required String ocrText,
    required List<double> scanEmbedding,
    required List<Medicine> registeredMedicines,
    required List<ImageEmbedding> savedEmbeddings,
  }) {
    final normalizedOcr = ocrText
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final candidates = <MatchCandidate>[];

    // Group saved embeddings by Medicine ID for easy lookup
    final Map<String, List<List<double>>> medEmbeddings = {};
    for (final emb in savedEmbeddings) {
      final vec = (jsonDecode(emb.vectorJson) as List).cast<double>();
      medEmbeddings.putIfAbsent(emb.medicineId, () => []).add(vec);
    }

    for (final medicine in registeredMedicines) {
      final evidence = <String>[];
      double textScore = 0.0;
      double imageScore = 0.0;

      // --- 1. TEXT MATCHING (Max 50%) ---
      final medName = medicine.medicineName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (medName.length > 2) {
        final ocrWords = normalizedOcr.split(' ');
        for (final word in ocrWords) {
          if (word.length < 3) continue;
          final distance = _levenshtein(medName, word);
          if (distance <= (medName.length * 0.35).ceil()) {
            textScore += 0.5;
            evidence.add('Name matched (Text)');
            break;
          }
        }
      }

      // --- 2. IMAGE MATCHING (Max 50%) ---
      final vectors = medEmbeddings[medicine.medicineId];
      if (vectors != null) {
        double bestSimilarity = 0.0;
        for (final savedVec in vectors) {
          final sim = _cosineSimilarity(scanEmbedding, savedVec);
          if (sim > bestSimilarity) bestSimilarity = sim;
        }

        // If visual similarity is > 70%, it's a strong visual match
        if (bestSimilarity > 0.60) {
          imageScore = 0.5; // Award full points
          evidence.add('Strong visual match');
        } else if (bestSimilarity > 0.40) {
          imageScore = 0.25; // Partial points
          evidence.add('Possible visual match');
        }
      }

      final totalConfidence = textScore + imageScore;

      if (totalConfidence > 0.0) {
        candidates.add(MatchCandidate(
          medicine: medicine,
          confidence: totalConfidence.clamp(0.0, 1.0),
          evidence: evidence,
        ));
      }
    }

    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));

    return MatchingResult(
      candidates: candidates,
      extractedText: ocrText,
    );
  }

  static double _cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    List<int> v0 = List<int>.filled(b.length + 1, 0);
    List<int> v1 = List<int>.filled(b.length + 1, 0);
    for (int i = 0; i <= b.length; i++) {
      v0[i] = i;
    }
    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int deletionCost = v0[j + 1] + 1;
        int insertionCost = v1[j] + 1;
        int substitutionCost = a[i] == b[j] ? v0[j] : v0[j] + 1;
        v1[j + 1] = [deletionCost, insertionCost, substitutionCost]
            .reduce((value, element) => value < element ? value : element);
      }
      v0 = List.from(v1);
    }
    return v0[b.length];
  }
}
