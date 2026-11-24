import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../localization/language_registry.dart';
import '../../medicine/domain/medicine_models.dart';
import '../../../database/app_database.dart';
import 'ocr_service.dart';

/// Reads the printed text from the photos you saved for each medicine (once)
/// and remembers it. A scanned package can then be matched against what your
/// own saved photos actually say, even if the name you typed differs from the print.
class RegisteredTextIndex {
  RegisteredTextIndex(this._ocr);
  final OcrService _ocr;
  Map<String, String>? _cache;

  Future<File> _file() async {
    final d = await getApplicationDocumentsDirectory();
    return File(p.join(d.path, 'ocr_cache.json'));
  }

  Future<void> _load() async {
    if (_cache != null) return;
    try {
      final f = await _file();
      _cache = f.existsSync()
          ? Map<String, String>.from(jsonDecode(await f.readAsString()) as Map)
          : <String, String>{};
    } catch (_) {
      _cache = <String, String>{};
    }
  }

  Future<void> _save() async {
    try {
      await (await _file()).writeAsString(jsonEncode(_cache));
    } catch (_) {}
  }

  Future<String> _key(MedicineImage img) async {
    final f = File(img.localPath);
    if (!await f.exists()) return '';
    return '${img.localPath}|${await f.length()}|${(await f.lastModified()).millisecondsSinceEpoch}';
  }

  /// Printed text of the medicine's saved strip photos. [onWork] is called when
  /// a photo has to be read for the first time (it can take a moment).
  Future<String> textFor(MedicineDetail m, Set<OcrScript> scripts, {void Function()? onWork}) async {
    await _load();
    final parts = <String>[];
    var dirty = false;
    final imgs = m.sortedImages.where((i) => i.imageType == 'strip_front' || i.imageType == 'strip_back').take(4);
    for (final img in imgs) {
      final key = await _key(img);
      if (key.isEmpty) continue;
      var text = _cache![key];
      if (text == null) {
        onWork?.call();
        try {
          final lines = await _ocr.read(img.localPath, scripts);
          text = lines.map((l) => l.text).join('\n');
        } catch (_) {
          text = '';
        }
        _cache![key] = text;
        dirty = true;
      }
      parts.add(text);
    }
    if (dirty) await _save();
    return parts.join('\n');
  }

  Future<void> warm(List<MedicineDetail> meds, Set<OcrScript> scripts) async {
    for (final m in meds) {
      await textFor(m, scripts);
    }
  }
}
