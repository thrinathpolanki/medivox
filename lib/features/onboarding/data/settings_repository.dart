import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import '../domain/storage_mode.dart';

/// Persists [AppSettings]. Healthcare data does NOT live here (that is Drift,
/// added in Milestone 2); this only holds app/onboarding preferences.
/// No tokens or credentials are stored.
class SettingsRepository {
  SettingsRepository(this._p);
  final SharedPreferences _p;

  static const _firstLaunch = 'firstLaunchCompleted';
  static const _termsAccepted = 'termsAccepted';
  static const _termsVersion = 'termsVersion';
  static const _termsAt = 'termsAcceptedAt';
  static const _privacyAck = 'privacyAcknowledged';
  static const _privacyVersion = 'privacyVersion';
  static const _privacyAt = 'privacyAcknowledgedAt';
  static const _storageMode = 'storageMode';
  static const _localProfileId = 'localProfileId';
  static const _displayName = 'displayName';
  static const _googleUserId = 'googleUserId';
  static const _language = 'preferredLanguage';
  static const _onboardingDone = 'onboardingCompleted';
  static const _voiceNav = 'a11y.voiceNavigation';
  static const _screenReader = 'a11y.screenReader';
  static const _largeText = 'a11y.largeText';
  static const _highContrast = 'a11y.highContrast';
  static const _haptic = 'a11y.haptic';
  static const _screenFree = 'a11y.screenFree';
  static const _fontScale = 'a11y.fontScale';
  static const _speechRate = 'a11y.speechRate';
  static const _speechVolume = 'a11y.speechVolume';

  DateTime? _date(String k) {
    final v = _p.getString(k);
    return v == null ? null : DateTime.tryParse(v);
  }

  AppSettings load() {
    const d = AccessibilitySettings();
    return AppSettings(
      firstLaunchCompleted: _p.getBool(_firstLaunch) ?? false,
      termsAccepted: _p.getBool(_termsAccepted) ?? false,
      termsVersion: _p.getString(_termsVersion),
      termsAcceptedAt: _date(_termsAt),
      privacyAcknowledged: _p.getBool(_privacyAck) ?? false,
      privacyVersion: _p.getString(_privacyVersion),
      privacyAcknowledgedAt: _date(_privacyAt),
      storageMode: StorageMode.fromName(_p.getString(_storageMode)),
      localProfileId: _p.getString(_localProfileId),
      displayName: _p.getString(_displayName),
      googleUserId: _p.getString(_googleUserId),
      preferredLanguage: _p.getString(_language),
      onboardingCompleted: _p.getBool(_onboardingDone) ?? false,
      accessibility: AccessibilitySettings(
        voiceNavigation: _p.getBool(_voiceNav) ?? d.voiceNavigation,
        screenReaderSupport: _p.getBool(_screenReader) ?? d.screenReaderSupport,
        largeText: _p.getBool(_largeText) ?? d.largeText,
        highContrast: _p.getBool(_highContrast) ?? d.highContrast,
        hapticFeedback: _p.getBool(_haptic) ?? d.hapticFeedback,
        screenFreeReminders: _p.getBool(_screenFree) ?? d.screenFreeReminders,
        fontScale: _p.getDouble(_fontScale) ?? d.fontScale,
        speechRate: _p.getDouble(_speechRate) ?? d.speechRate,
        speechVolume: _p.getDouble(_speechVolume) ?? d.speechVolume,
      ),
    );
  }

  Future<void> _str(String k, String? v) =>
      v == null ? _p.remove(k) : _p.setString(k, v);

  Future<void> save(AppSettings s) async {
    final a = s.accessibility;
    await Future.wait([
      _p.setBool(_firstLaunch, s.firstLaunchCompleted),
      _p.setBool(_termsAccepted, s.termsAccepted),
      _str(_termsVersion, s.termsVersion),
      _str(_termsAt, s.termsAcceptedAt?.toIso8601String()),
      _p.setBool(_privacyAck, s.privacyAcknowledged),
      _str(_privacyVersion, s.privacyVersion),
      _str(_privacyAt, s.privacyAcknowledgedAt?.toIso8601String()),
      _p.setString(_storageMode, s.storageMode.name),
      _str(_localProfileId, s.localProfileId),
      _str(_displayName, s.displayName),
      _str(_googleUserId, s.googleUserId),
      _str(_language, s.preferredLanguage),
      _p.setBool(_onboardingDone, s.onboardingCompleted),
      _p.setBool(_voiceNav, a.voiceNavigation),
      _p.setBool(_screenReader, a.screenReaderSupport),
      _p.setBool(_largeText, a.largeText),
      _p.setBool(_highContrast, a.highContrast),
      _p.setBool(_haptic, a.hapticFeedback),
      _p.setBool(_screenFree, a.screenFreeReminders),
      _p.setDouble(_fontScale, a.fontScale),
      _p.setDouble(_speechRate, a.speechRate),
      _p.setDouble(_speechVolume, a.speechVolume),
    ]);
  }

  Future<void> clear() => _p.clear();
}
