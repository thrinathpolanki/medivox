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


## Milestone 2 - Database and medicines  (WRITTEN, NOT YET COMPILED)
Written: Drift schema (user_profiles, medicines, medicine_images,
medication_schedules, dose_history, sync_queue) with FKs, indexes, unique keys,
foreign_keys pragma; repository (register in one transaction, update keeping
schedule ids + revision bump, delete with cascade + photo file removal);
file-based photo storage with size/resolution checks; screens: AddMedicine,
PhotoCapture, Information, ScheduleSetup, Review, Saved, MyMedicines (search +
filter), MedicineDetail, EditMedicine, DeleteConfirmation; tests.

REQUIRED before first run: `dart run build_runner build --delete-conflicting-outputs`
(generates lib/database/app_database.g.dart).

Not done / known gaps:
- Reminders are NOT scheduled yet (M3). Delete does not cancel reminders yet.
- No sync tombstones/queue writes yet (M5). Database is not encrypted yet (M5).
- Photo editing and cropping are not available; blur/darkness checks are not
  implemented (only size and resolution). OCR autofill comes in M4.
- Read Aloud button absent until TTS (M4). Bottom navigation not added yet.
- Caregivers, consent, backup and device-info tables are not created yet;
  they will be added with a schema migration (M5).
- Schedule timezone stores the device zone abbreviation only; proper IANA zone
  handling arrives with the reminder engine.

## Next: Milestone 3
Reminder engine: dose occurrences, local notifications with Taken/Snooze/Skip,
exact-alarm and notification permissions, reboot rescheduling, Today's Schedule,
adherence calculations.


## Milestone 3 - Reminders, schedule, adherence  (WRITTEN, NOT YET COMPILED)
Written: pure planner; DoseRepository (reconcile: missed after 2h, prune stale
pending, insert future doses; never touches taken/skipped history); notification
gateway (flutter_local_notifications 19.x, exact alarms with inexact fallback,
Taken/Snooze/Skip actions handled in a background isolate on the shared Drift
database); ReminderService (resync, one at a time); permission card (asked only
on button press); screens: Today's Schedule, Reminder notification, Reminder
settings (+test reminder), Adherence, Dose history, Reports, Adherence by
medicine; home summary; medicine detail history; tests.

REQUIRED: Android manifest + Gradle desugaring edits (see README).

Not done / known limits:
- Not run on a device: notification actions, reboot, exact-alarm flow, battery
  optimisation all need real-phone testing.
- Time-zone change while the app is closed is only fixed on next app open.
- Doses are generated 14 days ahead; if the app is not opened for longer, days
  beyond that window have no records (not counted as missed).
- Notification text shows the medicine name on the lock screen (private
  visibility is requested, but behaviour depends on the phone's settings).
- Screen-free spoken reminders need TTS (M4). Caregiver missed-dose alerts (M5).
- No separate ReminderHistoryScreen: Dose History covers it. No report export.
- Snoozed time is not stored; a snoozed dose is "missed" 2h after its original time.

## Next: Milestone 4
OCR packaging reader, scan flow, similar-medicine warnings, TTS (incl. Read Aloud
and screen-free reminders), voice assistant, gen-l10n.
