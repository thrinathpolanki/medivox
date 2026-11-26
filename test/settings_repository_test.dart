import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/features/onboarding/data/settings_repository.dart';
import 'package:medivox/features/onboarding/domain/app_settings.dart';
import 'package:medivox/features/onboarding/domain/storage_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('settings round-trip through SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SettingsRepository(await SharedPreferences.getInstance());
    expect(repo.load().storageMode, StorageMode.none);
    final when = DateTime.utc(2026, 1, 15, 8);
    await repo.save(AppSettings(
      termsAccepted: true,
      termsVersion: '1.0.0',
      termsAcceptedAt: when,
      storageMode: StorageMode.local,
      localProfileId: 'abc',
      preferredLanguage: 'hi',
      onboardingCompleted: true,
      accessibility:
          const AccessibilitySettings(highContrast: true, fontScale: 1.4),
    ));

    final s = repo.load();
    expect(s.termsAcceptedAt, when);
    expect(s.storageMode, StorageMode.local);
    expect(s.localProfileId, 'abc');
    expect(s.preferredLanguage, 'hi');
    expect(s.onboardingCompleted, isTrue);
    expect(s.accessibility.highContrast, isTrue);
    expect(s.accessibility.fontScale, 1.4);
  });
}
