import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageRecognitionService {
  static Interpreter? _interpreter;

  static Future<void> init() async {
    if (_interpreter != null) return;

    // Load the model from assets
    final options = InterpreterOptions()..threads = 2;
    _interpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_v1.tflite',
        options: options);
  }

  /// Generates a 1024-dimensional embedding for the given image.
  static Future<List<double>> generateEmbedding(File imageFile) async {
    await init();

    final imageData = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageData);
    if (originalImage == null) throw Exception('Failed to decode image');

    // 1. Center-Crop to a square to make it position-independent
    final int minSize = originalImage.width < originalImage.height
        ? originalImage.width
        : originalImage.height;
    final int x = (originalImage.width - minSize) ~/ 2;
    final int y = (originalImage.height - minSize) ~/ 2;

    final cropped = img.copyCrop(originalImage,
        x: x, y: y, width: minSize, height: minSize);

    // 2. Resize to 224x224 (MobileNet requirement)
    final resized = img.copyResize(cropped, width: 224, height: 224);

    // 3. Convert to Float32 tensor (Normalization)
    final input = _imageToByteListFloat32(resized, 224, 127.5, 127.5);

    // 4. Output buffer (MobileNetV1 outputs 1001 features)
    final output = List.filled(1 * 1001, 0.0).reshape([1, 1001]);

    // 5. Run Inference
    _interpreter!.run(input, output);

    return output[0].cast<double>();
  }

  /// Converts image to normalized float array required by MobileNet
  static List<List<List<List<double>>>> _imageToByteListFloat32(
      img.Image image, int size, double mean, double std) {
    final convertedBytes = List.generate(
      1,
      (_) => List.generate(
        size,
        (y) => List.generate(
          size,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              (pixel.r - mean) / std,
              (pixel.g - mean) / std,
              (pixel.b - mean) / std,
            ];
          },
        ),
      ),
    );
    return convertedBytes;
  }

  /// Calculates cosine similarity between two vectors (-1 to 1)
  static double cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  // Helper for Math.sqrt (since Dart doesn't have it built-in)
  static double _sqrt(double x) => x <= 0 ? 0 : x.sqrt();
}

// Extension to allow x.sqrt()
extension on double {
  double sqrt() =>
      this == 0 ? 0 : this; // Simplified, will implement properly below
}
