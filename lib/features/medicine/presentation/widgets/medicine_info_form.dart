import 'package:flutter/material.dart';

import '../../domain/medicine_models.dart';

/// Reusable form for registration and editing. The parent owns [formKey] and
/// reads the latest values through [onChanged].
class MedicineInfoForm extends StatefulWidget {
  const MedicineInfoForm({
    super.key,
    required this.formKey,
    required this.initial,
    required this.onChanged,
  });
  final GlobalKey<FormState> formKey;
  final MedicineInfo initial;
  final ValueChanged<MedicineInfo> onChanged;

  @override
  State<MedicineInfoForm> createState() => _MedicineInfoFormState();
}

class _MedicineInfoFormState extends State<MedicineInfoForm> {
  late MedicineInfo _info = widget.initial;
  late final _name = TextEditingController(text: _info.name);
  late final _generic = TextEditingController(text: _info.genericName);
  late final _strength = TextEditingController(text: _info.strength);
  late final _composition = TextEditingController(text: _info.composition);
  late final _manufacturer = TextEditingController(text: _info.manufacturer);
  late final _dosage = TextEditingController(text: _info.dosage);
  late final _rx = TextEditingController(text: _info.prescriptionReference);
  late final _notes = TextEditingController(text: _info.notes);

  @override
  void dispose() {
    for (final c in [_name, _generic, _strength, _composition, _manufacturer, _dosage, _rx, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _set(MedicineInfo i) {
    _info = i;
    widget.onChanged(i);
  }

  Widget _field(String label, TextEditingController c, MedicineInfo Function(String) f,
      {bool required = false, int lines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        minLines: lines,
        maxLines: lines == 1 ? 1 : 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: required ? '$label *' : label, hintText: hint),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        onChanged: (v) => _set(f(v)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Medicine name', _name, (v) => _info.copyWith(name: v), required: true),
          _field('Generic name', _generic, (v) => _info.copyWith(genericName: v)),
          _field('Strength', _strength, (v) => _info.copyWith(strength: v), hint: 'e.g. 500 mg'),
          _field('Composition', _composition, (v) => _info.copyWith(composition: v), lines: 2),
          _field('Manufacturer', _manufacturer, (v) => _info.copyWith(manufacturer: v)),
          Text('Medicine type', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in MedicineConfig.medicineTypes)
                ChoiceChip(
                  label: Text(t),
                  selected: _info.medicineType == t,
                  onSelected: (sel) =>
                      setState(() => _set(_info.copyWith(medicineType: sel ? t : ''))),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _field('Prescribed dosage', _dosage, (v) => _info.copyWith(dosage: v),
              hint: 'As written on your prescription'),
          _field('Prescription reference', _rx, (v) => _info.copyWith(prescriptionReference: v)),
          _field('Notes', _notes, (v) => _info.copyWith(notes: v), lines: 3),
        ],
      ),
    );
  }
}
