import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/daos/medicine_dao_provider.dart';
import '../medicine_list/my_medicines_screen.dart';

final medicineDetailProvider = FutureProvider.family((ref, String id) async {
  final dao = ref.watch(medicineDaoProvider);
  final medicine = await dao.getMedicineById(id);
  final images = await dao.getImagesForMedicine(id);
  final schedules = await dao.getSchedulesForMedicine(id);
  return (medicine: medicine, images: images, schedules: schedules);
});

class MedicineDetailScreen extends ConsumerWidget {
  final String medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(medicineDetailProvider(medicineId));

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Details')),
      body: detailAsync.when(
        data: (data) {
          final m = data.medicine;
          if (m == null) return const Center(child: Text('Not found'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                m.medicineName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _row('Strength', m.strength),
              _row('Composition', m.composition),
              _row('Manufacturer', m.manufacturer),
              _row('Type', m.medicineType),
              _row('Notes', m.notes),
              const SizedBox(height: 16),
              Text(
                'Photos (${data.images.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (data.images.isEmpty)
                const Text('No photos')
              else
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: data.images
                        .map(
                          (img) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.file(
                              File(img.localPath),
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Schedules (${data.schedules.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...data.schedules.map(
                (s) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.alarm),
                    title: Text('${s.period} @ ${s.time}'),
                    subtitle: Text('${s.dosage} • ${s.foodInstruction}'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Medicine?'),
                      content: const Text(
                          'This will remove the medicine and all associated photos and schedules.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref
                        .read(medicineDaoProvider)
                        .deleteMedicine(medicineId);
                    ref.invalidate(myMedicinesProvider);
                    if (context.mounted) context.go('/home');
                  }
                },
                label: const Text('Delete Medicine'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
