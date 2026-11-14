import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'features/reminders/services/notification_service.dart';
import 'database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storageMode = prefs.getString(AppConstants.prefStorageMode);

  if (storageMode == 'google') {
    await Firebase.initializeApp();
  }

  await NotificationService.init();

  // Ensure a default user profile record exists so Caregiver Mode
  // always shows at least the "Me" profile.
  final db = AppDatabase();
  try {
    final userId = prefs.getString(AppConstants.prefUserId) ?? 'local-user';
    final existing = await (db.select(db.userProfiles)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
    
    if (existing == null) {
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              displayName: const Value('Me'),
              storageMode: storageMode ?? 'local',
              createdAt: DateTime.now(),
            ),
          );
    }
  } finally {
    await db.close();
  }

  runApp(const ProviderScope(child: MediVoxApp()));
}
