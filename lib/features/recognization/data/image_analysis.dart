import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../domain/recognition_models.dart';

/// Experimental thresholds. They were NOT calibrated on a medicine dataset
/// yet and must be tuned with real photos (see README, "AI validation").
class QualityConfig {
  const QualityConfig({this.minSharpness = 60, this.minBrightness = 50, this.maxBrightness = 225, this.minSide = 600});
  final double minSharpness, minBrightness, maxBrightness;
  final int minSide;
}

class _QArgs {
  const _QArgs(this.bytes, this.cfg);
  final Uint8List bytes;
  final QualityConfig cfg;
}

QualityReport _qualityIsolate(_QArgs a) {
  var image = img.decodeImage(a.bytes);
  if (image == null) {
    return const QualityReport(
        width: 0, height: 0, sharpness: 0, brightness: 0, problems: ['This file could not be read as an image.']);
  }
  image = img.bakeOrientation(image);
  final w = image.width, h = image.height;
  var small = image;
  if (w > 640) small = img.copyResize(image, width: 640);
  small = img.grayscale(small);
  final sw = small.width, sh = small.height;
  final lum = List<double>.filled(sw * sh, 0);
  var sum = 0.0;
  for (var y = 0; y < sh; y++) {
    for (var x = 0; x < sw; x++) {
      final v = small.getPixel(x, y).luminance.toDouble();
      lum[y * sw + x] = v;
      sum += v;
    }
  }
  final mean = sum / (sw * sh);
  // Variance of the Laplacian: low value = few sharp edges = blurred.
  var lapSum = 0.0, lapSq = 0.0;
  var n = 0;
  for (var y = 1; y < sh - 1; y++) {
    for (var x = 1; x < sw - 1; x++) {
      final i = y * sw + x;
      final l = lum[i - 1] + lum[i + 1] + lum[i - sw] + lum[i + sw] - 4 * lum[i];
      lapSum += l;
      lapSq += l * l;
      n++;
    }
  }
  final mLap = n == 0 ? 0 : lapSum / n;
  final variance = n == 0 ? 0.0 : lapSq / n - mLap * mLap;

  final problems = <String>[];
  if (math.min(w, h) < a.cfg.minSide) problems.add('The photo is too small. Move closer to the package.');
  if (variance < a.cfg.minSharpness) problems.add('The photo looks blurred. Hold the phone steady and let it focus.');
  if (mean < a.cfg.minBrightness) problems.add('The photo is too dark. Move to a brighter place.');
  if (mean > a.cfg.maxBrightness) problems.add('The photo is too bright or has glare. Tilt the package slightly.');
  return QualityReport(width: w, height: h, sharpness: variance, brightness: mean, problems: problems);
}

class ImageQualityAnalyzer {
  const ImageQualityAnalyzer([this.config = const QualityConfig()]);
  final QualityConfig config;
  Future<QualityReport> analyze(Uint8List bytes) => compute(_qualityIsolate, _QArgs(bytes, config));
}

/// Cheap "packaging look" signature: 64-bit difference hash plus a coarse colour
/// histogram. Experimental and WEAK: lighting and angle change it a lot. It is
/// only ever supporting evidence, never the reason for a match.
class LookSignature {
  const LookSignature(this.hash, this.hist);
  final List<int> hash; // 64 bits as 0/1
  final List<double> hist; // 64 bins, sums to 1

  double similarity(LookSignature o) {
    var diff = 0;
    for (var i = 0; i < 64; i++) {
      if (hash[i] != o.hash[i]) diff++;
    }
    var inter = 0.0;
    for (var i = 0; i < 64; i++) {
      inter += math.min(hist[i], o.hist[i]);
    }
    return 0.5 * (1 - diff / 64) + 0.5 * inter;
  }
}

class _LArgs {
  const _LArgs(this.bytes, this.crop);
  final Uint8List bytes;
  final List<double>? crop; // left, top, width, height in pixels
}

LookSignature? _lookIsolate(_LArgs a) {
  var image = img.decodeImage(a.bytes);
  if (image == null) return null;
  image = img.bakeOrientation(image);
  final c = a.crop;
  if (c != null) {
    final x = c[0].clamp(0, image.width - 1).toInt(), y = c[1].clamp(0, image.height - 1).toInt();
    final w = c[2].clamp(1, image.width - x).toInt(), h = c[3].clamp(1, image.height - y).toInt();
    image = img.copyCrop(image, x: x, y: y, width: w, height: h);
  }
  final g = img.grayscale(img.copyResize(image, width: 9, height: 8, interpolation: img.Interpolation.average));
  final bits = <int>[];
  for (var y = 0; y < 8; y++) {
    for (var x = 0; x < 8; x++) {
      bits.add(g.getPixel(x, y).luminance > g.getPixel(x + 1, y).luminance ? 1 : 0);
    }
  }
  final s = img.copyResize(image, width: 64, height: 64, interpolation: img.Interpolation.average);
  final hist = List<double>.filled(64, 0);
  for (var y = 0; y < 64; y++) {
    for (var x = 0; x < 64; x++) {
      final p = s.getPixel(x, y);
      final bin = ((p.r.toInt() >> 6) << 4) | ((p.g.toInt() >> 6) << 2) | (p.b.toInt() >> 6);
      hist[bin] += 1 / 4096;
    }
  }
  return LookSignature(bits, hist);
}

class LookAnalyzer {
  Future<LookSignature?> signature(Uint8List bytes, {List<double>? crop}) =>
      compute(_lookIsolate, _LArgs(bytes, crop));
}

class _CArgs {
  const _CArgs(this.bytes, this.r);
  final Uint8List bytes;
  final List<double> r;
}

Uint8List? _cropIsolate(_CArgs a) {
  var image = img.decodeImage(a.bytes);
  if (image == null) return null;
  image = img.bakeOrientation(image);
  final pad = 0.03 * image.width;
  final x = (a.r[0] - pad).clamp(0, image.width - 1).toInt();
  final y = (a.r[1] - pad).clamp(0, image.height - 1).toInt();
  final w = (a.r[2] + 2 * pad).clamp(1, image.width - x).toInt();
  final h = (a.r[3] + 2 * pad).clamp(1, image.height - y).toInt();
  return Uint8List.fromList(img.encodeJpg(img.copyCrop(image, x: x, y: y, width: w, height: h), quality: 92));
}

/// Saves the region of a photo that holds one package, so it can become that
/// medicine's registration photo.
Future<String?> cropRegionToFile(String imagePath, Rect region) async {
  final bytes = await File(imagePath).readAsBytes();
  final out = await compute(_cropIsolate, _CArgs(bytes, [region.left, region.top, region.width, region.height]));
  if (out == null) return null;
  final f = File('${Directory.systemTemp.path}/medivox_crop_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await f.writeAsBytes(out);
  return f.path;
}

Uint8List? _enhanceIsolate(Uint8List bytes) {
  var image = img.decodeImage(bytes);
  if (image == null) return null;
  image = img.bakeOrientation(image);
  image = img.grayscale(image);
  image = img.normalize(image, min: 0, max: 255); // stretch contrast
  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

/// A grayscale, contrast-stretched copy (same size, orientation baked in) used
/// for a second text-recognition pass on foil strips and glare.
Future<String?> enhanceToFile(String imagePath) async {
  final out = await compute(_enhanceIsolate, await File(imagePath).readAsBytes());
  if (out == null) return null;
  final f = File('${Directory.systemTemp.path}/medivox_enh_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await f.writeAsBytes(out);
  return f.path;
}

class _RArgs {
  const _RArgs(this.bytes, this.turns);
  final Uint8List bytes;
  final int turns;
}

Uint8List? _rotateIsolate(_RArgs a) {
  var image = img.decodeImage(a.bytes);
  if (image == null) return null;
  image = img.bakeOrientation(image);
  image = img.copyRotate(image, angle: 90.0 * a.turns);
  return Uint8List.fromList(img.encodeJpg(image, quality: 92));
}

/// Copy of the photo turned by [quarterTurns] x 90 degrees clockwise, for strips
/// photographed sideways.
Future<String?> rotateToFile(String imagePath, int quarterTurns) async {
  final out = await compute(_rotateIsolate, _RArgs(await File(imagePath).readAsBytes(), quarterTurns));
  if (out == null) return null;
  final f = File('${Directory.systemTemp.path}/medivox_rot${quarterTurns}_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await f.writeAsBytes(out);
  return f.path;
}
