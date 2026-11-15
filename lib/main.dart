import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/onboarding/data/settings_controller.dart';

/// NOTE: Firebase is intentionally NOT imported or initialised here.
/// It will only be initialised after the user explicitly selects Google mode.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MediVoxApp(),
    ),
  );
}
