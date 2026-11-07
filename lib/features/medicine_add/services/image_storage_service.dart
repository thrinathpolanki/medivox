import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  /// Copies a picked/captured image into permanent app storage.
  /// Returns [localPath, checksum].
  static Future<({String localPath, String checksum})> persist({
    required File source,
    required String medicineId,
    required String imageType,
    required int sequence,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'medicines', medicineId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final ext =
        p.extension(source.path).isEmpty ? '.jpg' : p.extension(source.path);
    final destPath = p.join(dir.path, '${imageType}_$sequence$ext');

    final copied = await source.copy(destPath);
    final bytes = await copied.readAsBytes();
    final checksum = sha256.convert(bytes).toString();

    return (localPath: destPath, checksum: checksum);
  }

  static Future<void> deleteMedicineFolder(String medicineId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'medicines', medicineId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
