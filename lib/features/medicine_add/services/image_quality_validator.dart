import 'dart:io';
import 'package:image/image.dart' as img;

class ImageQualityResult {
  final bool isAcceptable;
  final String? reason;

  const ImageQualityResult.acceptable()
      : isAcceptable = true,
        reason = null;
  const ImageQualityResult.rejected(this.reason) : isAcceptable = false;
}

class ImageQualityValidator {
  /// Basic quality check — rejects images that are very dark or very small.
  /// This is NOT a full blur-detection algorithm; that comes in Phase 5.
  static Future<ImageQualityResult> validate(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length < 5000) {
        return const ImageQualityResult.rejected('Image file is too small.');
      }

      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return const ImageQualityResult.rejected('Could not decode image.');
      }

      if (decoded.width < 400 || decoded.height < 400) {
        return const ImageQualityResult.rejected(
            'Image resolution is too low.');
      }

      // Compute average brightness on a downsampled version
      final small = img.copyResize(decoded, width: 100);
      int total = 0;
      int count = 0;
      for (var y = 0; y < small.height; y++) {
        for (var x = 0; x < small.width; x++) {
          final pixel = small.getPixel(x, y);
          final luminance =
              (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);
          total += luminance.toInt();
          count++;
        }
      }
      final avgBrightness = total / count;
      if (avgBrightness < 30) {
        return const ImageQualityResult.rejected(
            'Image is too dark. Please retake in better lighting.');
      }

      return const ImageQualityResult.acceptable();
    } catch (e) {
      return ImageQualityResult.rejected('Image validation error: $e');
    }
  }
}
