import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/medicine_providers.dart';
import '../domain/medicine_models.dart';
import 'widgets/medicine_thumbnail.dart';

class MedicinePhotoCaptureScreen extends ConsumerWidget {
  const MedicinePhotoCaptureScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref, ImageSlot slot, ImageSource src) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final x = await ImagePicker().pickImage(source: src, imageQuality: 92, maxWidth: 2400);
      if (x == null) return;
      final storage = ref.read(imageStorageProvider);
      final staged = await storage.stage(x.path);
      if (staged.path == null) {
        messenger.showSnackBar(SnackBar(content: Text(staged.problem ?? 'Photo rejected.')));
        return;
      }
      final old = ref.read(medicineDraftProvider).images[slot];
      ref.read(medicineDraftProvider.notifier).update(
          (d) => d.copyWith(images: {...d.images, slot: staged.path!}));
      if (old != null) await storage.discard([old]);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not get the photo. Check camera or photo access and try again.')));
    }
  }

  void _sheet(BuildContext context, WidgetRef ref, ImageSlot slot, bool hasImage) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(hasImage ? 'Retake with camera' : 'Take photo'),
            onTap: () {
              Navigator.pop(ctx);
              _pick(context, ref, slot, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _pick(context, ref, slot, ImageSource.gallery);
            },
          ),
          if (hasImage)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = ref.read(medicineDraftProvider).images[slot];
                ref.read(medicineDraftProvider.notifier).update(
                    (d) => d.copyWith(images: {...d.images}..remove(slot)));
                if (path != null) await ref.read(imageStorageProvider).discard([path]);
              },
            ),
        ]),
      ),
    );
  }

  Widget _slot(BuildContext context, WidgetRef ref, MedicineDraft d, ImageSlot slot) {
    final path = d.images[slot];
    return Expanded(
      child: Semantics(
        button: true,
        label: path == null ? '${slot.label}, empty. Add photo.' : '${slot.label}, added. Change photo.',
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _sheet(context, ref, slot, path != null),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
                child: path == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_a_photo, size: 32, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 4),
                        Text(slot.label, textAlign: TextAlign.center),
                      ])
                    : LayoutBuilder(
                        builder: (_, c) => MedicineThumbnail(path: path, size: c.maxWidth, label: slot.label)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(medicineDraftProvider);
    Widget group(String title, ImageSlot a, ImageSlot b) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Row(children: [
              _slot(context, ref, d, a),
              const SizedBox(width: 12),
              _slot(context, ref, d, b),
            ]),
          ]),
        );

    return OnboardingScaffold(
      title: 'Medicine photos',
      subtitle: '${d.images.length} of ${MedicineConfig.maxImages} added. '
          'At least ${MedicineConfig.minImages} needed.',
      step: 1,
      totalSteps: 4,
      primaryLabel: 'Next',
      onPrimary: d.hasEnoughImages ? () => context.push('/medicines/add/info') : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tips: use good light, hold the phone steady, fill the frame, '
            'and keep text sharp and free of glare.'),
        const SizedBox(height: 16),
        group('Strip front', ImageSlot.stripFront1, ImageSlot.stripFront2),
        group('Strip back', ImageSlot.stripBack1, ImageSlot.stripBack2),
        group('Tablet', ImageSlot.tablet1, ImageSlot.tablet2),
      ]),
    );
  }
}
