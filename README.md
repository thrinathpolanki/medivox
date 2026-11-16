# MediVox (Milestone 1)

## Setup
This folder holds the Dart source only. Generate the Android shell first:

    cd medivox
    flutter create . --org com.trimitha --project-name medivox --platforms android
    flutter pub get
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
