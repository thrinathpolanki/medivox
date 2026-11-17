# MediVox (Milestone 2)

## Setup
This folder holds the Dart source only. Generate the Android shell first:

    cd medivox
    flutter create . --org com.trimitha --project-name medivox --platforms android
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    dart format .
    flutter analyze
    flutter test
    flutter run

`flutter create .` keeps existing `lib/`, `test/` and `pubspec.yaml`.
If it overwrites `lib/main.dart` or `test/widget_test.dart`, restore main.dart
from this project and delete the generated `test/widget_test.dart`.

Package versions are caret ranges and have not been resolved yet. If pub
reports conflicts, run `flutter pub upgrade --major-versions` and fix any API
changes (most likely `go_router`).

## Rules enforced so far
- Firebase is not a dependency and is never initialised (Local mode safe).
- Storage mode is saved only after a local profile is created or Google sign-in succeeds.
- Onboarding is never shown again once completed; connectivity is never checked.
- No Android permissions are requested during onboarding.

## Milestone 2 notes
- The Drift code generator must run once (command above) and again whenever
  `lib/database/tables/tables.dart` changes.
- Updating from Milestone 1: copy `lib/`, `test/`, `pubspec.yaml`, `README.md`,
  `PROGRESS.md` over your project (do NOT copy over `android/`), then run
  `flutter pub get` and the build_runner command.
- Database tests use an in-memory SQLite database; if `flutter test` cannot
  find a SQLite library on your PC, run those tests on a device/emulator instead.
- Camera: image_picker opens the system camera app, so no CAMERA permission is
  declared. Do not add one unless a feature needs it.
