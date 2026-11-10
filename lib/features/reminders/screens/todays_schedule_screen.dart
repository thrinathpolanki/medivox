import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../database/app_database.dart';
import '../../../database/daos/medicine_dao_provider.dart';
import '../../../database/database_provider.dart';

class ScheduleEntry {
  final Medicine medicine;
  final MedicationSchedule schedule;
  final DoseHistory? dose;
  final DateTime scheduledAt;
  ScheduleEntry({
    required this.medicine,
    required this.schedule,
    required this.dose,
    required this.scheduledAt,
  });
}

final todaysScheduleProvider = FutureProvider<List<ScheduleEntry>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(AppConstants.prefUserId) ?? 'local-user';
  final db = ref.watch(databaseProvider);
  final dao = ref.watch(medicineDaoProvider);

  final medicines = await dao.getAllMedicines(userId);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  final entries = <ScheduleEntry>[];

  for (final medicine in medicines) {
    final schedules = await dao.getSchedulesForMedicine(medicine.medicineId);
    for (final schedule in schedules) {
      if (!schedule.enabled) continue;
      final timeParts = schedule.time.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final scheduledAt =
          DateTime(today.year, today.month, today.day, hour, minute);

      // Find matching dose history entry for today
      final dose = await (db.select(db.doseHistory)
            ..where((t) => t.scheduleId.equals(schedule.scheduleId))
            ..where((t) =>
                t.scheduledAt.isBiggerOrEqualValue(today) &
                t.scheduledAt.isSmallerThanValue(tomorrow)))
          .getSingleOrNull();

      entries.add(ScheduleEntry(
        medicine: medicine,
        schedule: schedule,
        dose: dose,
        scheduledAt: scheduledAt,
      ));
    }
  }

  entries.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return entries;
});

class TodaysScheduleScreen extends ConsumerWidget {
  const TodaysScheduleScreen({super.key});

  Future<void> _mark(WidgetRef ref, ScheduleEntry entry, String status) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    if (entry.dose == null) {
      // Create dose history record on-the-fly
      await db.into(db.doseHistory).insert(
            DoseHistoryCompanion.insert(
              doseId: 'manual-${entry.schedule.scheduleId}-${now.millisecondsSinceEpoch}',
              scheduleId: entry.schedule.scheduleId,
              scheduledAt: entry.scheduledAt,
              status: status,
              actionAt: Value(now),
            ),
          );
    } else {
      await (db.update(db.doseHistory)
            ..where((t) => t.doseId.equals(entry.dose!.doseId)))
          .write(DoseHistoryCompanion(
        status: Value(status),
        actionAt: Value(now),
      ));
    }

    ref.invalidate(todaysScheduleProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todaysScheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Schedule")),
      body: async.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Text('No schedules for today.\nAdd a medicine first.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(todaysScheduleProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final status = e.dose?.status ?? 'pending';
                final color = _statusColor(status);
                final timeStr = TimeOfDay.fromDateTime(e.scheduledAt)
                    .format(context);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.alarm, color: color),
                            const SizedBox(width: 8),
                            Text(timeStr,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(e.medicine.medicineName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        Text('${e.schedule.dosage} • ${e.schedule.foodInstruction}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _mark(ref, e, 'skipped'),
                              child: const Text('Skip',
                                  style: TextStyle(color: Colors.orange)),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _mark(ref, e, 'snoozed'),
                              child: const Text('Snooze'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _mark(ref, e, 'taken'),
                              child: const Text('Taken'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'skipped':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      case 'snoozed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
