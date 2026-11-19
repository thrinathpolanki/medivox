import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/medicine_providers.dart';

class DeleteMedicineConfirmationScreen extends ConsumerStatefulWidget {
  const DeleteMedicineConfirmationScreen({super.key, required this.medicineId});
  final String medicineId;
  @override
  ConsumerState<DeleteMedicineConfirmationScreen> createState() => _State();
}

class _State extends ConsumerState<DeleteMedicineConfirmationScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(medicineRepositoryProvider).deleteMedicine(widget.medicineId);
      messenger.showSnackBar(const SnackBar(content: Text('Medicine deleted')));
      if (mounted) context.go('/medicines');
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not delete. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(medicineDetailProvider(widget.medicineId)).valueOrNull?.medicine.medicineName;
    final err = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Icon(Icons.warning_amber_rounded, size: 72, color: err),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text('Delete ${name ?? 'this medicine'}?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            const Text('This permanently removes the medicine, its photos, its schedule and '
                'its dose history from this device. This cannot be undone.',
                textAlign: TextAlign.center),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: err))],
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: err),
              onPressed: _busy ? null : _delete,
              child: Text(_busy ? 'Deleting…' : 'Delete permanently'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _busy ? null : () => context.pop(), child: const Text('Cancel')),
          ]),
        ),
      ),
    );
  }
}
