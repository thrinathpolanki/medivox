import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../camera/live_camera_view.dart';
import '../../haptics/haptic_service.dart';
import '../../onboarding/data/settings_controller.dart';
import '../../speech/speech_providers.dart';
import '../data/recognition_providers.dart';
import '../domain/recognition_models.dart';

enum _Stage { idle, checking, reading, issues, noText, error }

/// Opens the in-app camera straight away (like a QR scanner). A photo from the
/// gallery can be used instead with the gallery button inside the camera.
class MedicineScanScreen extends ConsumerStatefulWidget {
  const MedicineScanScreen({super.key});
  @override
  ConsumerState<MedicineScanScreen> createState() => _State();
}

class _State extends ConsumerState<MedicineScanScreen> {
  _Stage _stage = _Stage.idle;
  String? _path;
  QualityReport? _report;
  String? _message;
  String _progress = 'Reading the text…';

  Future<void> _gallery() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 92, maxWidth: 2400);
      if (x == null) return;
      await _process(x.path);
    } catch (_) {
      await _fail('Could not get the photo. Check photo access and try again.');
    }
  }

  Future<void> _fail(String msg) async {
    if (!mounted) return;
    setState(() {
      _stage = _Stage.error;
      _message = msg;
    });
    await HapticService.error(ref.read(settingsProvider));
  }

  Future<void> _process(String path, {bool override = false}) async {
    _path = path;
    final pipeline = ref.read(scanPipelineProvider);
    final settings = ref.read(settingsProvider);
    try {
      setState(() => _stage = _Stage.checking);
      final report = await pipeline.checkQuality(path);
      _report = report;
      if (!report.ok && !override) {
        if (!mounted) return;
        setState(() => _stage = _Stage.issues);
        await HapticService.error(settings);
        if (settings.accessibility.voiceNavigation && mounted) {
          await speakChecked(context, ref, ['The photo is not clear enough.', ...report.problems]);
        }
        return;
      }
      if (!mounted) return;
      setState(() {
        _stage = _Stage.reading;
        _progress = 'Reading the text…';
      });
      final registered = await ref.read(registeredMedicinesProvider.future);
      final session = await pipeline.run(
        path,
        registered: registered,
        scripts: ref.read(ocrScriptsProvider),
        report: report,
        lowQualityOverride: !report.ok,
        onProgress: (m) {
          if (mounted) setState(() => _progress = m);
        },
      );
      var finalSession = session;
      final pending = ref.read(scanConfirmProvider);
      if (pending != null) {
        ref.read(scanConfirmProvider.notifier).set(null);
        final agrees = session.packages.any((p) =>
            p.best?.medicine.medicine.medicineId == pending &&
            (p.status == PackageStatus.likely || p.status == PackageStatus.confirmed));
        if (agrees) {
          // Two separate photos agree on the same medicine.
          finalSession = ScanSession(
            imagePath: session.imagePath,
            quality: session.quality,
            allLines: session.allLines,
            lowQualityOverride: session.lowQualityOverride,
            confirmedMedicineId: pending,
            packages: [
              for (final p in session.packages)
                p.best?.medicine.medicine.medicineId == pending ? p.withStatus(PackageStatus.confirmed) : p,
            ],
          );
        }
      }
      ref.read(scanSessionProvider.notifier).set(finalSession);
      if (!mounted) return;
      if (finalSession.packages.isEmpty) {
        setState(() {
          _stage = _Stage.noText;
          _message = 'No readable text was found. Move closer to the package, in good light, and try again.';
        });
        await HapticService.error(settings);
        return;
      }
      setState(() => _stage = _Stage.idle);
      await HapticService.scanDone(settings);
      if (!mounted) return;
      if (finalSession.packages.length == 1) {
        context.push('/scan/result/0');
      } else {
        context.push('/scan/results');
      }
    } catch (e) {
      await _fail('Something went wrong while reading the photo. Please try again.');
    }
  }

  Widget _card(Widget child) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: child,
        ),
      );

  Widget _overlay(BuildContext context) {
    final theme = Theme.of(context);
    switch (_stage) {
      case _Stage.idle:
        return const SizedBox.shrink();
      case _Stage.checking:
      case _Stage.reading:
        return _card(Semantics(
          liveRegion: true,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(width: 16),
            Flexible(child: Text(_stage == _Stage.checking ? 'Checking the photo…' : _progress,
                style: theme.textTheme.titleMedium)),
          ]),
        ));
      case _Stage.issues:
        return _card(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(
            liveRegion: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text('This photo is not clear enough',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
              ]),
              const SizedBox(height: 8),
              for (final p in _report?.problems ?? const <String>[]) Text('• $p'),
            ]),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => setState(() => _stage = _Stage.idle), child: const Text('Retake photo')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _path == null ? null : () => _process(_path!, override: true),
            child: const Text('Try anyway (results may be wrong)'),
          ),
        ]));
      case _Stage.noText:
      case _Stage.error:
        return _card(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(liveRegion: true, child: Text(_message ?? '', style: theme.textTheme.titleMedium)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => setState(() => _stage = _Stage.idle), child: const Text('Try again')),
        ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(fit: StackFit.expand, children: [
          LiveCameraView(
            onCaptured: _process,
            onGallery: _stage == _Stage.idle ? _gallery : null,
            onBack: () => context.canPop() ? context.pop() : context.go('/home'),
            onHelp: () => context.push('/scan/guidance'),
          ),
          if (_stage != _Stage.idle) Positioned.fill(child: ColoredBox(color: Colors.black54, child: _overlay(context))),
        ]),
      ),
    );
  }
}
