import 'dart:ui' show Rect;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../localization/language_registry.dart';
import '../domain/recognition_models.dart';

abstract class OcrService {
  Future<List<OcrLine>> read(String imagePath, Set<OcrScript> scripts);
}

/// On-device text recognition with Google ML Kit. No image leaves the phone.
class MlKitOcrService implements OcrService {
  Future<List<OcrLine>> _run(String path, TextRecognitionScript script) async {
    final recognizer = TextRecognizer(script: script);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(path));
      return [
        for (final b in result.blocks)
          for (final l in b.lines)
            if (l.text.trim().isNotEmpty) OcrLine(l.text, l.boundingBox),
      ];
    } finally {
      await recognizer.close();
    }
  }

  static double _overlapRatio(Rect a, Rect b) {
    final i = a.intersect(b);
    if (i.isEmpty) return 0;
    final area = i.width * i.height;
    final smaller = a.width * a.height < b.width * b.height ? a.width * a.height : b.width * b.height;
    return smaller <= 0 ? 0 : area / smaller;
  }

  @override
  Future<List<OcrLine>> read(String imagePath, Set<OcrScript> scripts) async {
    final lines = await _run(imagePath, TextRecognitionScript.latin);
    if (scripts.contains(OcrScript.devanagari)) {
      try {
        final extra = await _run(imagePath, TextRecognitionScript.devanagiri);
        for (final e in extra) {
          if (!lines.any((l) => _overlapRatio(l.box, e.box) > 0.5)) lines.add(e);
        }
      } catch (_) {
        // The Devanagari model may be missing from the build: keep Latin results.
      }
    }
    return lines;
  }
}
