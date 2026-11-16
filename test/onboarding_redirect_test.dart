import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/features/onboarding/domain/app_settings.dart';
import 'package:medivox/features/onboarding/domain/legal_documents.dart';
import 'package:medivox/features/onboarding/domain/storage_mode.dart';
import 'package:medivox/routing/app_router.dart';

AppSettings _legalOk() => const AppSettings(
      termsAccepted: true,
      termsVersion: LegalDocuments.termsVersion,
      privacyAcknowledged: true,
      privacyVersion: LegalDocuments.privacyVersion,
    );

void main() {
  test('fresh install is sent to welcome from any app route', () {
    expect(onboardingRedirect(const AppSettings(), '/home'), '/welcome');
  });

  test('cannot skip terms or privacy', () {
    expect(onboardingRedirect(const AppSettings(), '/storage'), '/terms');
    final termsOnly = const AppSettings().copyWith(
        termsAccepted: true, termsVersion: LegalDocuments.termsVersion);
    expect(onboardingRedirect(termsOnly, '/storage'), '/privacy');
  });

  test('language step requires a storage choice', () {
    expect(onboardingRedirect(_legalOk(), '/language'), '/storage');
    expect(
        onboardingRedirect(
            _legalOk().copyWith(storageMode: StorageMode.local), '/language'),
        isNull);
  });

  test('completed users never return to onboarding or storage selection', () {
    final done = _legalOk()
        .copyWith(storageMode: StorageMode.local, onboardingCompleted: true);
    expect(onboardingRedirect(done, '/storage'), '/home');
    expect(onboardingRedirect(done, '/welcome'), '/home');
    expect(onboardingRedirect(done, '/home'), isNull);
  });

  test('outdated legal version forces re-acknowledgement', () {
    const old = AppSettings(
      onboardingCompleted: true,
      storageMode: StorageMode.local,
      termsAccepted: true,
      termsVersion: '0.9',
      privacyAcknowledged: true,
      privacyVersion: LegalDocuments.privacyVersion,
    );
    expect(onboardingRedirect(old, '/home'), '/terms');
    expect(onboardingRedirect(old, '/terms'), isNull);
  });
}
