import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../registration_state.dart';

class MedicineInformationScreen extends ConsumerStatefulWidget {
  const MedicineInformationScreen({super.key});

  @override
  ConsumerState<MedicineInformationScreen> createState() =>
      _MedicineInformationScreenState();
}

class _MedicineInformationScreenState
    extends ConsumerState<MedicineInformationScreen> {
  final _nameCtrl = TextEditingController();
  final _genericCtrl = TextEditingController();
  final _strengthCtrl = TextEditingController();
  final _compositionCtrl = TextEditingController();
  final _manufacturerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _type = 'tablet';

  @override
  void initState() {
    super.initState();
    final s = ref.read(registrationControllerProvider);
    _nameCtrl.text = s.medicineName;
    _genericCtrl.text = s.genericName;
    _strengthCtrl.text = s.strength;
    _compositionCtrl.text = s.composition;
    _manufacturerCtrl.text = s.manufacturer;
    _notesCtrl.text = s.notes;
    _type = s.medicineType;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _genericCtrl.dispose();
    _strengthCtrl.dispose();
    _compositionCtrl.dispose();
    _manufacturerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine name is required')),
      );
      return;
    }
    ref.read(registrationControllerProvider.notifier).setMedicineInfo(
          medicineName: _nameCtrl.text.trim(),
          genericName: _genericCtrl.text.trim(),
          strength: _strengthCtrl.text.trim(),
          composition: _compositionCtrl.text.trim(),
          manufacturer: _manufacturerCtrl.text.trim(),
          medicineType: _type,
          notes: _notesCtrl.text.trim(),
        );
    context.push('/add-medicine/schedule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Information')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_nameCtrl, 'Medicine Name *', hint: 'e.g. Paracetamol'),
          _field(_genericCtrl, 'Generic Name', hint: 'e.g. Acetaminophen'),
          _field(_strengthCtrl, 'Strength', hint: 'e.g. 500 mg'),
          _field(_compositionCtrl, 'Composition',
              hint: 'e.g. Paracetamol IP 500 mg'),
          _field(_manufacturerCtrl, 'Manufacturer',
              hint: 'e.g. ABC Pharma Ltd.'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Medicine Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'tablet', child: Text('Tablet')),
              DropdownMenuItem(value: 'capsule', child: Text('Capsule')),
              DropdownMenuItem(value: 'syrup', child: Text('Syrup')),
              DropdownMenuItem(value: 'injection', child: Text('Injection')),
              DropdownMenuItem(value: 'ointment', child: Text('Ointment')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'tablet'),
          ),
          const SizedBox(height: 12),
          _field(_notesCtrl, 'Notes', maxLines: 3),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _next,
            child: const Text('Next: Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
