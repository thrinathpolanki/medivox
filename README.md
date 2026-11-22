# MediVox (Milestone 4)

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

## Milestone 4: scanning, speech and voice (Android setup REQUIRED)

1. `AndroidManifest.xml`
   - Add above `<application>`:

         <uses-permission android:name="android.permission.RECORD_AUDIO"/>
         <queries>
           <intent><action android:name="android.intent.action.TTS_SERVICE"/></intent>
           <intent><action android:name="android.speech.RecognitionService"/></intent>
         </queries>

     (If a `<queries>` block already exists, add the two `<intent>` lines inside it.)
2. `android/app/build.gradle.kts`: use the updated file (adds the ML Kit Devanagari
   text model so Hindi/Marathi/Nepali etc. packaging can be read):

         dependencies {
             coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
             implementation("com.google.mlkit:text-recognition-devanagari:16.0.0")
         }

3. `flutter pub get`, `dart run build_runner build`, `flutter analyze`, `flutter test`, `flutter run`.

The first run needs an internet connection so Gradle can fetch the ML Kit libraries.
No permission is needed for the camera: photos are taken with the system camera app.

### How the AI pipeline works (all on the phone)
photo -> quality check (sharpness, brightness, size) -> Google ML Kit text recognition
-> split into packages by position -> rule-based reader (name, strength, composition,
manufacturer, batch, dates) -> fuzzy match against YOUR registered medicines.
Nothing is uploaded. Results show their evidence and always ask you to verify.

### What it cannot do (by design / current limits)
- It never names a medicine that is not in your registered list: there is no offline
  medicine catalogue yet, so unknown medicines show only the text that was read.
- Tablet colour/shape/size is never used to identify anything.
- Text recognition covers Latin and Devanagari scripts only (ML Kit). Tamil, Telugu,
  Bengali, Urdu etc. packaging text is not readable by this engine.
- Image similarity is an experimental, weak colour/shape-hash signal (5% weight). The
  TensorFlow Lite embedding model from the spec is not bundled.
- Quality, match and clustering thresholds are uncalibrated defaults.

### Accuracy validation (you must do this before relying on it)
Collect 100+ photos of real packaging (different lighting, angles, blurred, multi-package),
note the true name/strength/expiry for each, run them through Scan and Read Packaging, and
count: correct reads, wrong reads, false "likely" matches (must be ~0), missed matches.
Tune `QualityConfig` (image_analysis.dart) and `MatchConfig` (medicine_matcher.dart).
Do not describe the app as clinically accurate without this evidence.

### Matching update (scan could not find a saved medicine)
Matching now (1) ignores strength/"Tablets" words in the name you typed, (2) reads and
remembers the printed text of your saved photos and matches the package against it, even
if your typed name differs, (3) keeps a lone big brand name with its package instead of
discarding it, (4) retries with a contrast-enhanced reading if nothing matched, and
(5) if separate parts matched nothing, tries the whole photo as one package. The scan
result has a "How this was checked" section showing how each saved medicine scored.
The first scan after updating may take longer while saved photos are read once; this is
cached afterwards. Medicines you add from now on are read in the background after saving.

## In-app camera (new) - Android setup REQUIRED
Scan Medicine, Read Packaging and the registration photo slots now open a live camera
inside MediVox (preview, guide frame, torch, tap to focus, gallery button, 3-second timer).
Add to `AndroidManifest.xml` above `<application>`:

    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>

Android asks for camera permission the first time the camera opens. If it was denied,
turn it on in Settings > Apps > MediVox > Permissions. Then `flutter pub get` and run.
Photo sharpness vs speed: `kScanResolution` in `lib/features/camera/live_camera_view.dart`
(ultraHigh by default; use veryHigh if the preview is slow).

## Accuracy levels (what the result words mean)
- **Matched** (green tick): the name AND at least two more independent signals agree (strength,
  ingredients, manufacturer, or the printed text of your saved photos), no conflict, and the
  photo was clear. Spoken plainly, e.g. "This matches your saved medicine Beplex Forte 500 mg."
- **Likely**: name (and usually strength) agree but not enough independent evidence. It says to check.
- **Possible / conflict / ambiguous / not registered**: always say how unsure it is.
- "Double-check with another photo" scans again; if both photos agree the result becomes Matched.
No automatic reading can be 100% correct, so even a Matched result shows a short on-screen note.
The camera no longer speaks when it opens and has no frame: it is a full-screen preview.

## What a scan says now
For a Matched or Likely result the voice speaks ONLY the medicine name, when to take it and
how much, from your saved data, e.g. "Beplex Forte. Morning at 8 AM: 1 tablet, after food."
(If no schedule is saved it reads the saved prescribed dosage; if the saved course has ended
it says so.) A Possible / conflict / ambiguous / unreadable / unknown result says how unsure it
is and gives NO dosage. The same plan is shown on screen under "Your saved plan".
The same medicine saved twice (same name and strength) is treated as one medicine; the
review screen warns before you save a duplicate.
