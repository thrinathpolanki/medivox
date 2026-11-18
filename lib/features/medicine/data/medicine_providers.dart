import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/app_database.dart';
import '../../onboarding/data/settings_controller.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../onboarding/domain/storage_mode.dart';
import '../domain/medicine_models.dart';
import 'image_storage.dart';
import 'medicine_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final imageStorageProvider = Provider<ImageStorage>((ref) => FileImageStorage());

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) => MedicineRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(imageStorageProvider),
      onChanged: () => ref.read(reminderServiceProvider).resync(),
    ));

/// Resolves the active profile id (local profile or Google uid) and makes sure
/// its row exists. Local mode never touches Firebase.
final activeProfileProvider = FutureProvider<String>((ref) async {
  final (mode, localId, googleId, name, lang) = ref.watch(settingsProvider.select(
      (s) => (s.storageMode, s.localProfileId, s.googleUserId, s.displayName, s.preferredLanguage)));
  final userId = mode == StorageMode.google ? googleId : localId;
  if (userId == null) throw StateError('No active profile. Complete setup first.');
  await ref.watch(medicineRepositoryProvider).ensureProfile(
        userId: userId,
        displayName: name,
        storageMode: mode.name,
        language: lang,
      );
  return userId;
});

final medicineListProvider =
    StreamProvider.autoDispose.family<List<MedicineDetail>, String>((ref, query) async* {
  final userId = await ref.watch(activeProfileProvider.future);
  yield* ref.watch(medicineRepositoryProvider).watchAll(userId, query: query);
});

final medicineDetailProvider =
    StreamProvider.autoDispose.family<MedicineDetail?, String>((ref, id) {
  return ref.watch(medicineRepositoryProvider).watchOne(id);
});

class MedicineDraftController extends Notifier<MedicineDraft> {
  @override
  MedicineDraft build() => const MedicineDraft();

  void update(MedicineDraft Function(MedicineDraft) f) => state = f(state);

  /// Clears the draft. Staged photo files are discarded unless [keepFiles].
  Future<void> reset({bool keepFiles = false}) async {
    final paths = state.images.values.toList();
    state = const MedicineDraft();
    if (!keepFiles) await ref.read(imageStorageProvider).discard(paths);
  }
}

final medicineDraftProvider =
    NotifierProvider<MedicineDraftController, MedicineDraft>(MedicineDraftController.new);
