import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/features/onboarding/data/settings_controller.dart';
import 'package:medivox/features/onboarding/presentation/terms_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Continue is disabled until the checkbox is ticked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: TermsScreen()),
    ));

    FilledButton button() => tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button().onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });
}
