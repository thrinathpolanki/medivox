import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../registration_state.dart';
import '../services/image_quality_validator.dart';

class MedicinePhotoCaptureScreen extends ConsumerWidget {
  const MedicinePhotoCaptureScreen({super.key});

  static const _slots = [
    ('stripFront1', 'Strip Front (1)', Icons.photo_camera_front),
    ('stripFront2', 'Strip Front (2)', Icons.photo_camera_front),
    ('stripBack1', 'Strip Back (1)', Icons.photo_camera_back),
    ('stripBack2', 'Strip Back (2)', Icons.photo_camera_back),
    ('tablet1', 'Tablet (1)', Icons.medication),
    ('tablet2', 'Tablet (2)', Icons.medication),
  ];

  Future<void> _pickImage(
      BuildContext context, WidgetRef ref, String slot) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final file = File(picked.path);
    final quality = await ImageQualityValidator.validate(file);

    if (!quality.isAcceptable) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(quality.reason ?? 'Invalid image')),
      );
      return;
    }

    ref.read(registrationControllerProvider.notifier).setPhoto(slot, file);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Photos')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Capture clear photos of the medicine. Strip Front (1) and Strip Back (1) are required.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: const EdgeInsets.all(16),
              children: _slots.map((slot) {
                final (key, label, icon) = slot;
                final file = _getFile(state, key);
                return _buildSlot(context, ref, key, label, icon, file);
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: state.hasMinimumPhotos
                  ? () => context.push('/add-medicine/info')
                  : null,
              child: Text(
                state.hasMinimumPhotos
                    ? 'Next: Medicine Info'
                    : 'Capture Front & Back of Strip',
              ),
            ),
          ),
        ],
      ),
    );
  }

  File? _getFile(RegistrationState s, String key) {
    switch (key) {
      case 'stripFront1':
        return s.stripFront1;
      case 'stripFront2':
        return s.stripFront2;
      case 'stripBack1':
        return s.stripBack1;
      case 'stripBack2':
        return s.stripBack2;
      case 'tablet1':
        return s.tablet1;
      case 'tablet2':
        return s.tablet2;
    }
    return null;
  }

  Widget _buildSlot(BuildContext context, WidgetRef ref, String key,
      String label, IconData icon, File? file) {
    return InkWell(
      onTap: () => _pickImage(context, ref, key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  Text(label, textAlign: TextAlign.center),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                        onPressed: () {
                          ref
                              .read(registrationControllerProvider.notifier)
                              .removePhoto(key);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black54,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
