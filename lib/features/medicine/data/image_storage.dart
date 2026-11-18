import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/medicine_models.dart';

class StagedImage {
  const StagedImage({this.path, this.problem});
  final String? path;
  final String? problem; // user-facing reason when rejected
}

class StoredImage {
  const StoredImage(this.slot, this.path, this.checksum);
  final ImageSlot slot;
  final String path;
  final String checksum;
}

abstract class ImageStorage {
  /// Copies a picked photo to app storage after basic quality checks.
  Future<StagedImage> stage(String sourcePath);
  Future<List<StoredImage>> persistAll(String medicineId, Map<ImageSlot, String> staged);
  Future<void> deleteMedicineImages(String medicineId);
  Future<void> discard(Iterable<String> stagedPaths);
}

/// Stores photographs as files (never Base64 in the database).
class FileImageStorage implements ImageStorage {
  Future<Directory> _dir(String name) async {
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(docs.path, name));
    await d.create(recursive: true);
    return d;
  }

  @override
  Future<StagedImage> stage(String sourcePath) async {
    final src = File(sourcePath);
    final bytes = await src.readAsBytes();
    if (bytes.length < 20 * 1024) {
      return const StagedImage(
          problem: 'This photo is too small or empty. Please retake it.');
    }
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final shortSide = frame.image.width < frame.image.height
          ? frame.image.width
          : frame.image.height;
      frame.image.dispose();
      codec.dispose();
      if (shortSide < MedicineConfig.minImageSide) {
        return const StagedImage(
            problem: 'The photo resolution is too low. Move closer, use good '
                'light, and retake it.');
      }
    } catch (_) {
      return const StagedImage(problem: 'This file is not a readable image.');
    }
    final drafts = await _dir('medicine_drafts');
    final dest = File(p.join(drafts.path, '${const Uuid().v4()}.jpg'));
    await src.copy(dest.path);
    return StagedImage(path: dest.path);
  }

  @override
  Future<List<StoredImage>> persistAll(
      String medicineId, Map<ImageSlot, String> staged) async {
    final root = await _dir(p.join('medicine_images', medicineId));
    final out = <StoredImage>[];
    for (final e in staged.entries) {
      final dest = File(p.join(root.path, '${e.key.type}_${e.key.sequence}.jpg'));
      final src = File(e.value);
      try {
        await src.rename(dest.path);
      } on FileSystemException {
        await src.copy(dest.path);
        await src.delete();
      }
      final digest = sha256.convert(await dest.readAsBytes()).toString();
      out.add(StoredImage(e.key, dest.path, digest));
    }
    return out;
  }

  @override
  Future<void> deleteMedicineImages(String medicineId) async {
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(docs.path, 'medicine_images', medicineId));
    if (await d.exists()) await d.delete(recursive: true);
  }

  @override
  Future<void> discard(Iterable<String> stagedPaths) async {
    for (final path in stagedPaths) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }
}
