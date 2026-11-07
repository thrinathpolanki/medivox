import 'dart:convert';
import '../../../core/widgets/saving_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../medicine_scan/services/image_recognition_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../database/daos/medicine_dao_provider.dart';
import '../registration_state.dart';
import '../services/image_storage_service.dart';

class MedicineReviewScreen extends ConsumerStatefulWidget {
  const MedicineReviewScreen({super.key});

  @override
  ConsumerState<MedicineReviewScreen> createState() =>
      _MedicineReviewScreenState();
}

class _MedicineReviewScreenState extends ConsumerState<MedicineReviewScreen> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final state = ref.read(registrationControllerProvider);
      final dao = ref.read(medicineDaoProvider);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConstants.prefUserId) ?? 'local-user';

      // 1. Insert medicine
      final medicineId = await dao.insertMedicine(
        userId: userId,
        name: state.medicineName,
        genericName: state.genericName.isEmpty ? null : state.genericName,
        strength: state.strength.isEmpty ? null : state.strength,
        composition: state.composition.isEmpty ? null : state.composition,
        manufacturer: state.manufacturer.isEmpty ? null : state.manufacturer,
        medicineType: state.medicineType,
        notes: state.notes.isEmpty ? null : state.notes,
      );

      // 2. Persist images & Generate AI embeddings
      final slotMap = {
        'strip_front': [state.stripFront1, state.stripFront2],
        'strip_back': [state.stripBack1, state.stripBack2],
        'tablet': [state.tablet1, state.tablet2],
      };

      for (final entry in slotMap.entries) {
        final type = entry.key;
        final files = entry.value;
        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          if (file == null) continue;

          // Yield to the UI thread so the animation doesn't freeze
          await Future.delayed(Duration.zero);

          // Save the physical image file to the device
          final persisted = await ImageStorageService.persist(
            source: file,
            medicineId: medicineId,
            imageType: type,
            sequence: i + 1,
          );

          // Insert image record into database and get the ID
          final imageId = await dao.insertImage(
            medicineId: medicineId,
            imageType: type,
            imageSequence: i + 1,
            localPath: persisted.localPath,
            checksum: persisted.checksum,
          );

          // NEW: Generate AI embedding and save it
          try {
            final embedding =
                await ImageRecognitionService.generateEmbedding(file);
            await dao.insertEmbedding(
              medicineId: medicineId,
              imageId: imageId,
              vectorJson: jsonEncode(embedding),
            );
          } catch (e) {
            debugPrint(
                'Failed to generate embedding: $e'); // Don't crash the whole save if AI fails
          }
        }
      }

      for (final entry in slotMap.entries) {
        final type = entry.key;
        final files = entry.value;
        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          if (file == null) continue;

          final persisted = await ImageStorageService.persist(
            source: file,
            medicineId: medicineId,
            imageType: type,
            sequence: i + 1,
          );

          await dao.insertImage(
            medicineId: medicineId,
            imageType: type,
            imageSequence: i + 1,
            localPath: persisted.localPath,
            checksum: persisted.checksum,
          );
          for (var i = 0; i < files.length; i++) {
            final file = files[i];
            if (file == null) continue;

            final persisted = await ImageStorageService.persist(
              source: file,
              medicineId: medicineId,
              imageType: type,
              sequence: i + 1,
            );

            final imageId = await dao.insertImage(
              // <-- Change dao to return ID
              medicineId: medicineId,
              imageType: type,
              imageSequence: i + 1,
              localPath: persisted.localPath,
              checksum: persisted.checksum,
            );

            // NEW: Generate AI embedding and save it
            try {
              final embedding =
                  await ImageRecognitionService.generateEmbedding(file);
              await dao.insertEmbedding(
                medicineId: medicineId,
                imageId: imageId,
                vectorJson: jsonEncode(embedding),
              );
            } catch (e) {
              print(
                  'Failed to generate embedding: $e'); // Don't crash the whole save if AI fails
            }
          }
        }
      }

      // 3. Persist schedules
      for (final s in state.schedules) {
        await dao.insertSchedule(
          medicineId: medicineId,
          period: s.period,
          time: s.time,
          dosage: s.dosage,
          foodInstruction: s.foodInstruction,
          repeatDays: s.repeatDays,
          timezone: 'Asia/Kolkata',
          startDate: DateTime.now(),
        );
      }

      // 4. Reset & navigate
      ref.read(registrationControllerProvider.notifier).reset();

      if (!mounted) return;
      context.go('/add-medicine/saved');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);

    return Stack(
      // <-- Wrap with Stack
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Review & Save')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Medicine Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _row('Name', state.medicineName),
              _row('Generic', state.genericName),
              _row('Strength', state.strength),
              _row('Composition', state.composition),
              _row('Manufacturer', state.manufacturer),
              _row('Type', state.medicineType),
              if (state.notes.isNotEmpty) _row('Notes', state.notes),
              const SizedBox(height: 16),
              const Text('Photos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('${state.photoCount} photo(s) captured'),
              const SizedBox(height: 16),
              const Text('Schedules',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...state.schedules.map(
                (s) => Card(
                  child: ListTile(
                    title: Text('${s.period.toUpperCase()} @ ${s.time}'),
                    subtitle: Text(
                        '${s.dosage} • ${s.foodInstruction} • ${s.repeatDays.length} day(s)/week'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Medicine'),
              ),
            ],
          ),
        ),

        // The Awesome Saving Overlay
        if (_saving) const SavingOverlay(),
      ],
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
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
