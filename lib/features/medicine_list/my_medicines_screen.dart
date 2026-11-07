import '../../database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../database/daos/medicine_dao_provider.dart';
// Note: app_database.dart import removed because it is unused here.

final myMedicinesProvider = FutureProvider<List<Medicine>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(AppConstants.prefUserId) ?? 'local-user';
  return ref.watch(medicineDaoProvider).getAllMedicines(userId);
});

class MyMedicinesScreen extends ConsumerWidget {
  const MyMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(myMedicinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(myMedicinesProvider),
          ),
        ],
      ),
      body: medsAsync.when(
        data: (meds) {
          if (meds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medication_outlined,
                      size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No medicines added yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: () => context.push('/add-medicine'),
                    label: const Text('Add Your First Medicine'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final m = meds[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication, size: 32),
                  title: Text(m.medicineName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text([
                    if (m.strength != null && m.strength!.isNotEmpty)
                      m.strength!,
                    if (m.manufacturer != null && m.manufacturer!.isNotEmpty)
                      m.manufacturer!,
                  ].join(' • ')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/medicines/${m.medicineId}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-medicine'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
