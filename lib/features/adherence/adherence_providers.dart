import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database_provider.dart';
import 'services/adherence_calculator.dart';
import 'services/missed_dose_engine.dart';

final missedDoseEngineProvider = Provider((ref) {
  return MissedDoseEngine(ref.watch(databaseProvider));
});

final adherenceCalculatorProvider = Provider((ref) {
  return AdherenceCalculator(ref.watch(databaseProvider));
});

/// Overall adherence for the last 7 days (all medicines).
final weeklyAdherenceProvider = FutureProvider<OverallAdherence>((ref) async {
  // Ensure missed doses are caught up
  await ref.read(missedDoseEngineProvider).markMissedDoses();
  return ref.read(adherenceCalculatorProvider).compute(days: 7);
});

/// Overall adherence for the last 30 days (all medicines).
final monthlyAdherenceProvider = FutureProvider<OverallAdherence>((ref) async {
  await ref.read(missedDoseEngineProvider).markMissedDoses();
  return ref.read(adherenceCalculatorProvider).compute(days: 30);
});
