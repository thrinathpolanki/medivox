import 'package:flutter/material.dart';

import '../domain/recognition_models.dart';

/// Editable view of text read from packaging. Everything here is a suggestion
/// until the user has checked it against the package.
class PackagingEditor extends StatefulWidget {
  const PackagingEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.showReaderFields = false,
    this.onSpeak,
  });
  final PackagingEdit initial;
  final ValueChanged<PackagingEdit> onChanged;
  final bool showReaderFields; // batch / manufacturing / expiry
  final void Function(String label, String value)? onSpeak;

  @override
  State<PackagingEditor> createState() => _State();
}

class _State extends State<PackagingEditor> {
  late PackagingEdit _e = widget.initial;
  late final _c = <String, TextEditingController>{
    'name': TextEditingController(text: _e.name),
    'strength': TextEditingController(text: _e.strength),
    'composition': TextEditingController(text: _e.composition),
    'manufacturer': TextEditingController(text: _e.manufacturer),
    'batch': TextEditingController(text: _e.batch),
    'mfg': TextEditingController(text: _e.mfgDate),
    'exp': TextEditingController(text: _e.expiryDate),
  };

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _f(String key, String label, PackagingEdit Function(String) f, {int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: _c[key],
          minLines: lines,
          maxLines: lines == 1 ? 1 : 5,
          onChanged: (v) {
            _e = f(v);
            widget.onChanged(_e);
          },
          decoration: InputDecoration(
            labelText: label,
            helperText: 'Read automatically. Check it against the package.',
            suffixIcon: widget.onSpeak == null
                ? null
                : IconButton(
                    tooltip: 'Read $label aloud',
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => widget.onSpeak!(label, _c[key]!.text),
                  ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(children: [
        _f('name', 'Medicine name', (v) => _e.copyWith(name: v)),
        _f('strength', 'Strength', (v) => _e.copyWith(strength: v)),
        _f('composition', 'Composition', (v) => _e.copyWith(composition: v), lines: 2),
        _f('manufacturer', 'Manufacturer', (v) => _e.copyWith(manufacturer: v)),
        if (widget.showReaderFields) ...[
          _f('batch', 'Batch number', (v) => _e.copyWith(batch: v)),
          _f('mfg', 'Manufacturing date', (v) => _e.copyWith(mfgDate: v)),
          _f('exp', 'Expiry date', (v) => _e.copyWith(expiryDate: v)),
        ],
      ]);
}
