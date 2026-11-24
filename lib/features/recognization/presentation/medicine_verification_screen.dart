import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../../medicine/data/medicine_providers.dart';
import '../../medicine/domain/medicine_models.dart';
import '../data/image_analysis.dart';
import '../data/recognition_providers.dart';
import '../domain/recognition_models.dart';
import 'packaging_editor.dart';

/// The user checks and corrects the text before it becomes a registration draft.
/// Dosage is never taken from the package: it is entered later from the prescription.
class MedicineVerificationScreen extends ConsumerStatefulWidget {
  const MedicineVerificationScreen({super.key, required this.index});
  final int index;
  @override
  ConsumerState<MedicineVerificationScreen> createState() => _State();
}

class _State extends ConsumerState<MedicineVerificationScreen> {
  PackagingEdit? _edit;
  bool _checked = false;
  bool _busy = false;

  Future<void> _continue(ScanSession s, PackageResult p) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    String? photoPath;
    try {
      photoPath = s.packages.length == 1 ? s.imagePath : await cropRegionToFile(s.imagePath, p.bounds);
    } catch (_) {}
    String? staged;
    if (photoPath != null) {
      final r = await ref.read(imageStorageProvider).stage(photoPath);
      staged = r.path;
      if (staged == null) {
        messenger.showSnackBar(SnackBar(content: Text('${r.problem} You can add photos in the next step.')));
      }
    }
    ref.read(medicineDraftProvider.notifier).update((d) => MedicineDraft(
          info: _edit!.toMedicineInfo(),
          images: staged == null ? const {} : {ImageSlot.stripFront1: staged},
        ));
    if (mounted) {
      setState(() => _busy = false);
      context.push('/medicines/add/photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(scanSessionProvider);
    if (s == null || widget.index >= s.packages.length) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This result is no longer available.')));
    }
    final p = s.packages[widget.index];
    _edit ??= PackagingEdit.fromFields(p.fields);
    final ready = _checked && _edit!.name.trim().isNotEmpty && !_busy;
    return OnboardingScaffold(
      title: 'Check the details',
      subtitle: 'Correct anything that is wrong. Nothing is saved until you finish registering.',
      scrollable: false,
      totalSteps: 4,
      primaryLabel: _busy ? 'Preparing…' : 'Continue to registration',
      onPrimary: ready ? () => _continue(s, p) : null,
      bottom: CheckboxListTile(
        value: _checked,
        onChanged: (v) => setState(() => _checked = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text('I have checked these details against the package'),
      ),
      child: SingleChildScrollView(
        child: PackagingEditor(initial: _edit!, onChanged: (e) => setState(() => _edit = e)),
      ),
    );
  }
}
