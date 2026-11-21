import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routing/app_router.dart';
import '../../medicine/data/medicine_providers.dart';
import '../domain/dose_models.dart';
import 'dose_repository.dart';
import 'notification_gateway.dart';
import 'reminder_service.dart';

final notificationGatewayProvider =
    Provider<NotificationGateway>((ref) => LocalNotificationGateway());

final doseRepositoryProvider =
    Provider<DoseRepository>((ref) => DoseRepository(ref.watch(appDatabaseProvider)));

final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService(
      doses: ref.watch(doseRepositoryProvider),
      gateway: ref.watch(notificationGatewayProvider),
    ));

/// Starts the reminder engine once. Returns the dose id if the app was
/// launched by tapping a reminder notification.
final reminderBootProvider = FutureProvider<String?>((ref) async {
  final service = ref.read(reminderServiceProvider);
  service.onOpenDose = (id) => ref.read(routerProvider).push('/reminder/$id');
  await service.start();
  return service.launchDoseId();
});

class ReminderPermissions {
  const ReminderPermissions({required this.notifications, required this.exactAlarms});
  final bool notifications, exactAlarms;
  bool get allGood => notifications && exactAlarms;
}

final reminderPermissionProvider = FutureProvider.autoDispose<ReminderPermissions>((ref) async {
  final g = ref.watch(notificationGatewayProvider);
  return ReminderPermissions(
    notifications: await g.notificationsEnabled(),
    exactAlarms: await g.canScheduleExact(),
  );
});

final dayDosesProvider =
    StreamProvider.autoDispose.family<List<DoseItem>, DateTime>((ref, day) async* {
  final userId = await ref.watch(activeProfileProvider.future);
  yield* ref
      .watch(doseRepositoryProvider)
      .watchRange(userId, day, DateTime(day.year, day.month, day.day + 1));
});

final doseRangeProvider = StreamProvider.autoDispose
    .family<List<DoseItem>, (DateTime, DateTime)>((ref, range) async* {
  final userId = await ref.watch(activeProfileProvider.future);
  yield* ref.watch(doseRepositoryProvider).watchRange(userId, range.$1, range.$2);
});

final doseItemProvider = StreamProvider.autoDispose.family<DoseItem?, String>(
    (ref, id) => ref.watch(doseRepositoryProvider).watchOne(id));

final medicineDosesProvider = StreamProvider.autoDispose.family<List<DoseItem>, String>(
    (ref, id) => ref.watch(doseRepositoryProvider).watchForMedicine(id));
