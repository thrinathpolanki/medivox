import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String rawText;
  final List<String> lines;
  const OcrResult({required this.rawText, required this.lines});
  bool get isEmpty => rawText.trim().isEmpty;
}

class OcrService {
  static TextRecognizer? _recognizer;

  static TextRecognizer _getRecognizer(String languageCode) {
    _recognizer?.close();

    TextRecognitionScript script = TextRecognitionScript.latin;
    if (['hi', 'mr', 'ne', 'sa'].contains(languageCode)) {
      script = TextRecognitionScript.devanagiri;
    }

    _recognizer = TextRecognizer(script: script);
    return _recognizer!;
  }

  static Future<OcrResult> extractText(
      File imageFile, String languageCode) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizer = _getRecognizer(languageCode);

      final recognizedText = await recognizer.processImage(inputImage);

      final rawText = recognizedText.text;
      final lines = recognizedText.blocks
          .expand((block) => block.lines)
          .map((line) => line.text.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      return OcrResult(rawText: rawText, lines: lines);
    } catch (e) {
      return const OcrResult(rawText: '', lines: []);
    }
  }

  static Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}
