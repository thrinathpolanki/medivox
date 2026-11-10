import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'features/reminders/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storageMode = prefs.getString(AppConstants.prefStorageMode);

  if (storageMode == 'google') {
    await Firebase.initializeApp();
  }

  await NotificationService.init();

  runApp(const ProviderScope(child: MediVoxApp()));
}
