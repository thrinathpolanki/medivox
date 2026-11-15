import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/auth_gateway.dart';
import '../domain/app_settings.dart';
import '../domain/legal_documents.dart';
import '../domain/storage_mode.dart';
import 'settings_repository.dart';

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final settingsRepositoryProvider = Provider<SettingsRepository>(
    (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)));

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> _set(AppSettings s) async {
    state = s;
    await ref.read(settingsRepositoryProvider).save(s);
  }

  Future<void> markFirstLaunch() =>
      _set(state.copyWith(firstLaunchCompleted: true));

  Future<void> acceptTerms() => _set(state.copyWith(
        termsAccepted: true,
        termsVersion: LegalDocuments.termsVersion,
        termsAcceptedAt: DateTime.now(),
      ));

  Future<void> acknowledgePrivacy() => _set(state.copyWith(
        privacyAcknowledged: true,
        privacyVersion: LegalDocuments.privacyVersion,
        privacyAcknowledgedAt: DateTime.now(),
      ));

  /// Local mode: optional display name, generated profile id, no email/phone.
  Future<void> setLocalProfile(String? displayName) {
    final name = displayName?.trim();
    return _set(state.copyWith(
      storageMode: StorageMode.local,
      localProfileId: state.localProfileId ?? const Uuid().v4(),
      displayName: (name == null || name.isEmpty) ? state.displayName : name,
    ));
  }

  /// Only called after a successful Google sign-in. Local records are never
  /// touched here (migration is an explicit, confirmed workflow later).
  Future<void> setGoogleAccount(AuthResult r) => _set(state.copyWith(
        storageMode: StorageMode.google,
        googleUserId: r.userId,
        displayName: r.displayName ?? state.displayName,
      ));

  Future<void> setLanguage(String code) =>
      _set(state.copyWith(preferredLanguage: code));

  Future<void> updateAccessibility(AccessibilitySettings a) =>
      _set(state.copyWith(accessibility: a));

  Future<void> completeOnboarding() => _set(state.copyWith(
        firstLaunchCompleted: true,
        onboardingCompleted: true,
      ));

  /// Debug helper only.
  Future<void> resetAll() async {
    await ref.read(settingsRepositoryProvider).clear();
    state = const AppSettings();
  }
}
