import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database_provider.dart';
import 'reminder_scheduler.dart';

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(ref.watch(databaseProvider));
});
