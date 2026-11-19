import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/medicine_providers.dart';
import '../domain/medicine_models.dart';
import 'widgets/medicine_info_form.dart';
import 'widgets/schedule_list_editor.dart';

class EditMedicineScreen extends ConsumerWidget {
  const EditMedicineScreen({super.key, required this.medicineId});
  final String medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(medicineDetailProvider(medicineId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit medicine'),
        leading: IconButton(
            tooltip: 'Cancel', icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load this medicine.')),
        data: (m) => m == null
            ? const Center(child: Text('This medicine no longer exists.'))
            : _EditBody(detail: m),
      ),
    );
  }
}

class _EditBody extends ConsumerStatefulWidget {
  const _EditBody({required this.detail});
  final MedicineDetail detail;
  @override
  ConsumerState<_EditBody> createState() => _EditBodyState();
}

class _EditBodyState extends ConsumerState<_EditBody> {
  final _key = GlobalKey<FormState>();
  late MedicineInfo _info = MedicineInfo.fromMedicine(widget.detail.medicine);
  late List<ScheduleDraft> _schedules =
      widget.detail.sortedSchedules.map(ScheduleDraft.fromRow).toList();
  bool _saving = false;
  String? _error;

  bool get _valid => _schedules.every((s) => s.error == null);

  Future<void> _save() async {
    if (!(_key.currentState?.validate() ?? false) || !_valid) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(medicineRepositoryProvider).updateMedicine(
          medicineId: widget.detail.medicine.medicineId, info: _info, schedules: _schedules);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not save changes. Nothing was changed.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            MedicineInfoForm(formKey: _key, initial: _info, onChanged: (i) => _info = i),
            const Divider(height: 32),
            Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ScheduleListEditor(
                schedules: _schedules, onChanged: (l) => setState(() => _schedules = l)),
            const Text('Photos cannot be changed here yet.'),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: (_saving || !_valid) ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save changes'),
          ),
        ),
      ]),
    );
  }
}
