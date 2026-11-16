# MediVox progress

## Milestone 1 - Foundation and onboarding  (WRITTEN, NOT YET COMPILED)
Written: theme, Riverpod settings store (SharedPreferences), GoRouter with
guarded redirects, all 8 onboarding screens (splash, welcome, terms, privacy,
storage, Google/local account, language, accessibility, complete), home
placeholder, language capability registry, auth gateway interface, tests.

Not verified: `flutter pub get/analyze/test`, device behaviour, TalkBack.
Known limits:
- Google sign-in is an interface only (honest "not configured" error). No
  Firebase dependency or initialisation exists yet.
- UI is English only; no gen-l10n/ARB yet (Milestone 4). Language choice is stored.
- Speech speed/volume are stored but not used until TTS exists.
- Legal text is a draft and needs legal review. Logo is a placeholder.
- Android permissions: none requested yet (by design).

## Next: Milestone 2
Drift database (all tables, indexes, FKs, migrations), medicine registration
(4 stages, 6 images as files), My Medicines, Medicine detail, delete w/ confirm.
First step: add drift, drift_flutter, path_provider, build_runner; define tables.
