import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../registration_state.dart';

class MedicineScheduleSetupScreen extends ConsumerStatefulWidget {
  const MedicineScheduleSetupScreen({super.key});

  @override
  ConsumerState<MedicineScheduleSetupScreen> createState() =>
      _MedicineScheduleSetupScreenState();
}

class _MedicineScheduleSetupScreenState
    extends ConsumerState<MedicineScheduleSetupScreen> {
  String _period = 'morning';
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  final _dosageCtrl = TextEditingController(text: '1 tablet');
  String _food = 'after_food';
  final Set<int> _days = {1, 2, 3, 4, 5, 6, 7};

  @override
  void dispose() {
    _dosageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _addSchedule() {
    if (_dosageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dosage is required')),
      );
      return;
    }
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }

    final time24 =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

    ref.read(registrationControllerProvider.notifier).addSchedule(
          ScheduleEntry(
            period: _period,
            time: time24,
            dosage: _dosageCtrl.text.trim(),
            foodInstruction: _food,
            repeatDays: _days.toList()..sort(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(registrationControllerProvider).schedules;

    return Scaffold(
      appBar: AppBar(title: const Text('Medication Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _period,
            decoration: const InputDecoration(
              labelText: 'Time of Day',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'morning', child: Text('Morning')),
              DropdownMenuItem(value: 'afternoon', child: Text('Afternoon')),
              DropdownMenuItem(value: 'night', child: Text('Night')),
              DropdownMenuItem(value: 'custom', child: Text('Custom')),
            ],
            onChanged: (v) => setState(() => _period = v ?? 'morning'),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            title: const Text('Time'),
            subtitle: Text(_time.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: _pickTime,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dosageCtrl,
            decoration: const InputDecoration(
              labelText: 'Dosage',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _food,
            decoration: const InputDecoration(
              labelText: 'Food Instruction',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                  value: 'before_food', child: Text('Before Food')),
              DropdownMenuItem(value: 'after_food', child: Text('After Food')),
              DropdownMenuItem(value: 'with_food', child: Text('With Food')),
              DropdownMenuItem(
                  value: 'as_prescribed', child: Text('As Prescribed')),
            ],
            onChanged: (v) => setState(() => _food = v ?? 'after_food'),
          ),
          const SizedBox(height: 12),
          const Text('Repeat Days',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]),
                  selected: _days.contains(d),
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _days.add(d);
                      } else {
                        _days.remove(d);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addSchedule,
            icon: const Icon(Icons.add),
            label: const Text('Add to Schedule'),
          ),
          const SizedBox(height: 24),
          if (schedules.isNotEmpty) ...[
            const Text('Added Schedules',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...schedules.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Card(
                child: ListTile(
                  title: Text('${s.period.toUpperCase()} @ ${s.time}'),
                  subtitle: Text('${s.dosage} — ${s.foodInstruction}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref
                        .read(registrationControllerProvider.notifier)
                        .removeSchedule(i),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: schedules.isEmpty
                ? null
                : () => context.push('/add-medicine/review'),
            child: const Text('Next: Review'),
          ),
        ],
      ),
    );
  }
}
