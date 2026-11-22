# MediVox (Milestone 3)

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

## Milestone 3: Android setup for reminders (REQUIRED)
Reminders need native Android configuration that `flutter create` does not add.

1. `android/app/src/main/AndroidManifest.xml`
   - Inside `<manifest>` (above `<application>`):

         <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
         <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
         <uses-permission android:name="android.permission.VIBRATE"/>
         <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

   - Inside `<application>` (next to the `<activity>`):

         <receiver android:exported="false"
             android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
         <receiver android:exported="false"
             android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
           <intent-filter>
             <action android:name="android.intent.action.BOOT_COMPLETED"/>
             <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
             <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
             <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
           </intent-filter>
         </receiver>
         <receiver android:exported="false"
             android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"/>

2. `android/app/build.gradle.kts` (Java 8 desugaring, needed by the plugin)
   - In the existing `android { ... compileOptions { ... } }` block add:
     `isCoreLibraryDesugaringEnabled = true`
   - Add (or extend) a `dependencies { ... }` block at the bottom:
     `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`

3. Then: `flutter pub get`, `dart run build_runner build`, `flutter run`.

`flutter_local_notifications` is pinned to the 19.x API (^19.0.0); `flutter_timezone`
to 4.x. If pub resolves a different major version, compile errors in
`notification_gateway.dart` are the first place to look.

### Testing reminders on the phone
1. Add a medicine with a schedule a few minutes ahead and save it.
2. When asked, press "Allow notifications", then "Allow exact timing"
   (Android opens a settings page for this; switch MediVox on, come back).
3. Reminders > "Send a test reminder in 10 seconds", lock the screen.
4. Lock the phone and wait for the real reminder. Try Taken / Snooze / Skip from
   the notification, then check Today's Schedule.
5. Restart the phone and confirm the next reminder still fires.
