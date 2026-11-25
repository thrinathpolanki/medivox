import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SpeechState { idle, speaking, paused }

enum VoiceAvailability { available, unavailable, unknown }

/// Text-to-speech. The text is split into segments so Pause / Resume / Repeat
/// work the same on every Android version. If the phone has no voice for the
/// requested language this reports it; the app asks the user before using a
/// different language and never switches silently.
class SpeechService {
  SpeechService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();
  final FlutterTts _tts;

  final ValueNotifier<SpeechState> state = ValueNotifier(SpeechState.idle);
  List<String> _segments = const [];
  int _index = 0;
  bool _ready = false;
  String _locale = 'en-IN';
  double _rate = 0.5, _volume = 1.0;

  Future<void> _init() async {
    if (_ready) return;
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  bool get hasContent => _segments.isNotEmpty;

  Future<VoiceAvailability> availability(String bcp47) async {
    try {
      await _init();
      final r = await _tts.isLanguageAvailable(bcp47);
      return (r == true || r == 1) ? VoiceAvailability.available : VoiceAvailability.unavailable;
    } catch (_) {
      return VoiceAvailability.unknown;
    }
  }

  Future<void> speak(
    List<String> segments, {
    required String locale,
    required double rate,
    required double volume,
  }) async {
    await stop();
    await _init();
    _segments = segments.where((s) => s.trim().isNotEmpty).toList();
    _locale = locale;
    _rate = rate;
    _volume = volume;
    _index = 0;
    await _configure();
    state.value = SpeechState.speaking;
    await _run();
  }

  Future<void> _configure() async {
    await _tts.setLanguage(_locale);
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(_volume);
  }

  Future<void> _run() async {
    while (_index < _segments.length && state.value == SpeechState.speaking) {
      final i = _index;
      await _tts.speak(_segments[i]);
      if (state.value == SpeechState.speaking) _index = i + 1;
    }
    if (state.value == SpeechState.speaking) {
      state.value = SpeechState.idle;
      _index = 0;
    }
  }

  Future<void> pause() async {
    if (state.value != SpeechState.speaking) return;
    state.value = SpeechState.paused;
    await _tts.stop();
  }

  Future<void> resume() async {
    if (state.value != SpeechState.paused) return;
    state.value = SpeechState.speaking;
    await _run();
  }

  Future<void> repeat() async {
    if (_segments.isEmpty) return;
    final s = _segments;
    await speak(s, locale: _locale, rate: _rate, volume: _volume);
  }

  Future<void> stop() async {
    state.value = SpeechState.idle;
    _index = 0;
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// One-shot speech recognition. Started only by a button press (never listens
/// in the background). Uses the phone's recognizer, which on many phones needs
/// an internet connection.
class VoiceListener {
  VoiceListener([SpeechToText? stt]) : _stt = stt ?? SpeechToText();
  final SpeechToText _stt;
  bool _ready = false;
  String? lastError;

  Future<bool> _init() async {
    if (_ready) return true;
    _ready = await _stt.initialize(onError: (e) => lastError = e.errorMsg);
    return _ready;
  }

  Future<String?> _englishLocale() async {
    try {
      final locales = await _stt.locales();
      for (final id in ['en_IN', 'en-IN']) {
        if (locales.any((l) => l.localeId == id)) return id;
      }
      final en = locales.where((l) => l.localeId.toLowerCase().startsWith('en'));
      return en.isEmpty ? null : en.first.localeId;
    } catch (_) {
      return null;
    }
  }

  bool get isListening => _stt.isListening;

  /// Returns the recognised words, or null if nothing was heard / not allowed.
  Future<String?> listenOnce({Duration timeout = const Duration(seconds: 8)}) async {
    lastError = null;
    if (!await _init()) return null;
    final locale = await _englishLocale();
    var words = '';
    await _stt.listen(
      onResult: (r) => words = r.recognizedWords,
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
      localeId: locale,
    );
    final end = DateTime.now().add(timeout + const Duration(seconds: 2));
    while (_stt.isListening && DateTime.now().isBefore(end)) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    await _stt.stop();
    final t = words.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> cancel() => _stt.cancel();
}
