import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../haptics/haptic_service.dart';
import '../../onboarding/data/settings_controller.dart';
import '../../speech/medicine_speech.dart';
import '../../speech/speech_providers.dart';
import '../data/medicine_matcher.dart';
import '../data/packaging_parser.dart';
import '../data/recognition_providers.dart';
import '../domain/recognition_models.dart';
import 'packaging_editor.dart';
import 'status_banner.dart';

/// Reads the printed information on a package and speaks it. The text is
/// editable so the user can correct it; nothing read here is treated as verified.
class PackagingReaderScreen extends ConsumerStatefulWidget {
  const PackagingReaderScreen({super.key});
  @override
  ConsumerState<PackagingReaderScreen> createState() => _State();
}

class _State extends ConsumerState<PackagingReaderScreen> {
  bool _busy = false;
  String? _path;
  QualityReport? _report;
  PackagingFields? _fields;
  String _raw = '';
  PackagingEdit _edit = const PackagingEdit();
  int _editKey = 0;
  String? _error;

  Future<void> _pick(ImageSource src) async {
    try {
      final String? path;
      if (src == ImageSource.camera) {
        path = await context.push<String>('/camera');
      } else {
        path = (await ImagePicker().pickImage(source: src, imageQuality: 92, maxWidth: 2400))?.path;
      }
      if (path == null) return;
      _path = path;
      await _read(path);
    } catch (_) {
      setState(() => _error = 'Could not get the photo. Check camera or photo access.');
    }
  }

  Future<void> _read(String path, {bool override = false}) async {
    final settings = ref.read(settingsProvider);
    final pipeline = ref.read(scanPipelineProvider);
    setState(() {
      _busy = true;
      _error = null;
      _fields = null;
    });
    try {
      final report = await pipeline.checkQuality(path);
      _report = report;
      if (!report.ok && !override) {
        setState(() => _busy = false);
        await HapticService.error(settings);
        if (settings.accessibility.voiceNavigation && mounted) {
          await speakChecked(context, ref, ['The photo is not clear enough.', ...report.problems]);
        }
        return;
      }
      final lines = await ref.read(ocrServiceProvider).read(path, ref.read(ocrScriptsProvider));
      if (lines.isEmpty) {
        setState(() {
          _busy = false;
          _error = 'No readable text was found. Retake the photo closer, in good light.';
        });
        await HapticService.error(settings);
        return;
      }
      final fields = PackagingParser.parse(lines);
      setState(() {
        _fields = fields;
        _raw = (lines.toList()..sort((a, b) => a.box.top.compareTo(b.box.top))).map((l) => l.text).join('\n');
        _edit = PackagingEdit.fromFields(fields);
        _editKey++;
        _busy = false;
      });
      await HapticService.scanDone(settings);
      if (settings.accessibility.voiceNavigation && mounted) {
        await speakChecked(context, ref, MedicineSpeech.packaging(_edit));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Something went wrong while reading the photo. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiry = PackagingParser.expiryState(_edit.expiryDate, DateTime.now());
    final expText = ScanWording.expiryWarning(expiry);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Packaging'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Photograph the front or back of a package. MediVox reads the printed text on your '
            'phone and can read it aloud. Please check it against the package.'),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.photo_camera),
          label: const Text('Take photo'),
          onPressed: _busy ? null : () => _pick(ImageSource.camera),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose from gallery'),
          onPressed: _busy ? null : () => _pick(ImageSource.gallery),
        ),
        const SizedBox(height: 16),
        if (_busy)
          Semantics(
            liveRegion: true,
            child: const Row(children: [
              SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
              SizedBox(width: 14),
              Text('Reading the package…'),
            ]),
          ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Text(_error!),
            ),
          ),
        if (!_busy && _fields == null && _report != null && !_report!.ok) ...[
          StatusBanner(
            icon: Icons.visibility_off,
            color: theme.colorScheme.error,
            text: 'This photo is not clear enough',
            detail: _report!.problems.join(' '),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _path == null ? null : () => _read(_path!, override: true),
            child: const Text('Try anyway (results may be wrong)'),
          ),
        ],
        if (_fields != null) ...[
          if (_report != null && !_report!.ok)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('The photo quality was low, so some text may be wrong.'),
            ),
          if (expText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StatusBanner(icon: Icons.event_busy, color: theme.colorScheme.error, text: expText),
            ),
          if (_fields!.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Text was found but no medicine details could be recognised. See "All text that was read".'),
            ),
          PackagingEditor(
            key: ValueKey(_editKey),
            initial: _edit,
            showReaderFields: true,
            onChanged: (e) => setState(() => _edit = e),
            onSpeak: (label, value) => speakChecked(context, ref, MedicineSpeech.field(label, value)),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.volume_up),
            label: const Text('Speak all information'),
            onPressed: () => speakChecked(context, ref, MedicineSpeech.packaging(_edit)),
          ),
          const SizedBox(height: 8),
          const SpeechControls(),
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('All text that was read'),
            children: [Padding(padding: const EdgeInsets.all(12), child: Text(_raw))],
          ),
        ],
      ]),
    );
  }
}
