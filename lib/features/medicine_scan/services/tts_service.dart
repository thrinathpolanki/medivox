import 'package:flutter_tts/flutter_tts.dart';
import '../../localization/tts_language_mapper.dart';

class TtsService {
  static FlutterTts? _tts;

  static FlutterTts _getTts() {
    _tts ??= FlutterTts();
    return _tts!;
  }

  /// Speaks the given text in the user's chosen language.
  /// [appLanguageCode] is the 2 or 3 letter code (e.g., 'hi', 'te').
  static Future<void> speak(String text,
      {String appLanguageCode = 'en'}) async {
    final tts = _getTts();
    final ttsCode = TtsLanguageMapper.getTtsCode(appLanguageCode);

    // 1. Check if the device actually has this language installed
    final isLanguageAvailable = await tts.isLanguageAvailable(ttsCode);

    if (isLanguageAvailable) {
      await tts.setLanguage(ttsCode);
    } else {
      // Fallback: Speak in English and warn the user
      await tts.setLanguage('en-IN');
      final langName = TtsLanguageMapper.getLanguageName(appLanguageCode);
      text =
          "The $langName voice pack is not installed on this device. Speaking in English. $text";
    }

    // 2. Configure voice properties
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);

    // 3. Stop any current speech and speak the new text
    await tts.stop();
    await tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts?.stop();
  }

  static Future<void> dispose() async {
    await _tts?.stop();
    _tts = null;
  }
}
