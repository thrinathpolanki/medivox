import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../speech/speech_providers.dart';

/// Resolution of the live preview and the captured photo. Higher = sharper small
/// print but slower. Lower to ResolutionPreset.veryHigh on slow phones.
const kScanResolution = ResolutionPreset.ultraHigh;

/// Full-screen in-app camera: edge-to-edge live preview, torch, tap to focus, a
/// gallery button, and a hands-free 3-second timer. It never speaks on its own.
class LiveCameraView extends ConsumerStatefulWidget {
  const LiveCameraView({
    super.key,
    required this.onCaptured,
    this.onGallery,
    this.onBack,
    this.onHelp,
    this.hint = 'Point at the medicine package',
  });
  final ValueChanged<String> onCaptured;
  final VoidCallback? onGallery, onBack, onHelp;
  final String hint;

  @override
  ConsumerState<LiveCameraView> createState() => _State();
}

class _State extends ConsumerState<LiveCameraView> with WidgetsBindingObserver {
  CameraController? _c;
  String? _error;
  bool _initializing = false, _busy = false, _torch = false;
  int? _count;
  Timer? _timer;
  Offset? _focus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _c?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (_initializing) return;
    _initializing = true;
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _error = 'No camera was found on this phone.');
        return;
      }
      final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final c = CameraController(back, kScanResolution, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await c.initialize();
      try {
        await c.setFlashMode(FlashMode.off);
      } catch (_) {}
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _c = c;
        _error = null;
        _torch = false;
      });
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _error = e.code.toLowerCase().contains('denied')
            ? 'Camera permission is off. Allow Camera for MediVox in your phone\'s Settings > Apps > MediVox > Permissions, or use the gallery button.'
            : 'Could not open the camera (${e.code}).');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not open the camera.');
    } finally {
      _initializing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final c = _c;
      if (c != null) {
        _c = null;
        c.dispose();
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed && _c == null) {
      _init();
    }
  }

  Future<void> _shoot() async {
    final c = _c;
    if (c == null || _busy || !c.value.isInitialized) return;
    ref.read(speechServiceProvider).stop();
    setState(() => _busy = true);
    try {
      HapticFeedback.mediumImpact();
      final f = await c.takePicture();
      if (mounted) widget.onCaptured(f.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(const SnackBar(content: Text('Could not take the photo. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleTimer() {
    if (_count != null) {
      _timer?.cancel();
      setState(() => _count = null);
      return;
    }
    ref.read(speechServiceProvider).stop();
    setState(() => _count = 3);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final n = (_count ?? 1) - 1;
      HapticFeedback.selectionClick();
      if (n <= 0) {
        t.cancel();
        setState(() => _count = null);
        _shoot();
      } else {
        setState(() => _count = n);
      }
    });
  }

  Future<void> _toggleTorch() async {
    final c = _c;
    if (c == null) return;
    try {
      await c.setFlashMode(_torch ? FlashMode.off : FlashMode.torch);
      setState(() => _torch = !_torch);
    } catch (_) {}
  }

  Future<void> _tapFocus(TapUpDetails d, Size size) async {
    final c = _c;
    if (c == null) return;
    setState(() => _focus = d.localPosition);
    final p = Offset(d.localPosition.dx / size.width, d.localPosition.dy / size.height);
    try {
      await c.setFocusPoint(p);
      await c.setExposurePoint(p);
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _focus = null);
  }

  Widget _round(IconData icon, String label, VoidCallback? onTap, {bool active = false}) => Semantics(
        button: true,
        label: label,
        child: Tooltip(
          message: label,
          child: Material(
            color: active ? Colors.white : Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(icon, color: active ? Colors.black : Colors.white, size: 28),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(builder: (context, box) {
        final size = Size(box.maxWidth, box.maxHeight);
        final ready = c != null && c.value.isInitialized;
        return Stack(fit: StackFit.expand, children: [
          if (ready)
            ExcludeSemantics(
              child: GestureDetector(
                onTapUp: (d) => _tapFocus(d, size),
                child: ClipRect(
                  child: Transform.scale(
                    scale: () {
                      // Cover the whole screen whichever way the plugin reports the ratio.
                      final ar = c.value.aspectRatio;
                      final p = ar > 1 ? 1 / ar : ar; // portrait width/height of the preview
                      final sa = size.aspectRatio;
                      return p > sa ? p / sa : sa / p;
                    }(),
                    child: Center(child: CameraPreview(c)),
                  ),
                ),
              ),
            )
          else if (_error == null)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (_focus != null)
            Positioned(
              left: _focus!.dx - 32,
              top: _focus!.dy - 32,
              child: IgnorePointer(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          if (_count != null)
            Center(
              child: Semantics(
                liveRegion: true,
                label: 'Taking photo in $_count',
                child: Text('$_count',
                    style: const TextStyle(color: Colors.white, fontSize: 120, fontWeight: FontWeight.w800)),
              ),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.no_photography, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _init, child: const Text('Try again')),
                ]),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(children: [
                  if (widget.onBack != null) _round(Icons.arrow_back, 'Back', widget.onBack),
                  const Spacer(),
                  if (widget.onHelp != null) ...[
                    _round(Icons.help_outline, 'How to scan', widget.onHelp),
                    const SizedBox(width: 12),
                  ],
                  _round(_torch ? Icons.flash_on : Icons.flash_off, _torch ? 'Turn light off' : 'Turn light on',
                      ready ? _toggleTorch : null,
                      active: _torch),
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (ready)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: Text(widget.hint, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  SizedBox(
                    width: 72,
                    child: widget.onGallery == null
                        ? null
                        : Center(child: _round(Icons.photo_library, 'Choose from gallery', widget.onGallery)),
                  ),
                  Semantics(
                    button: true,
                    label: 'Take photo',
                    child: GestureDetector(
                      onTap: ready ? _shoot : null,
                      child: Container(
                        width: 78,
                        height: 78,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _busy ? Colors.white54 : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: Center(
                      child: _round(_count == null ? Icons.timer : Icons.close, _count == null ? 'Take photo in 3 seconds' : 'Cancel timer',
                          ready ? _toggleTimer : null,
                          active: _count != null),
                    ),
                  ),
                  ]),
                ]),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}
