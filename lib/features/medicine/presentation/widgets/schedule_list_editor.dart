import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/format.dart';
import '../../domain/medicine_models.dart';

/// Edits a list of schedule entries. Dosage is always typed by the user.
class ScheduleListEditor extends StatelessWidget {
  const ScheduleListEditor({super.key, required this.schedules, required this.onChanged});
  final List<ScheduleDraft> schedules;
  final ValueChanged<List<ScheduleDraft>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (schedules.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No reminder times yet. You can add times now, or save the '
                'medicine without a schedule and add one later.'),
          ),
        for (var i = 0; i < schedules.length; i++)
          _ScheduleCard(
            key: ValueKey(schedules[i].id),
            index: i,
            schedule: schedules[i],
            onChanged: (s) => onChanged([...schedules]..[i] = s),
            onDelete: () => onChanged([...schedules]..removeAt(i)),
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_alarm),
          label: const Text('Add a time'),
          onPressed: () => onChanged(
              [...schedules, ScheduleDraft.create(const Uuid().v4(), SchedulePeriod.morning)]),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatefulWidget {
  const _ScheduleCard({
    super.key,
    required this.index,
    required this.schedule,
    required this.onChanged,
    required this.onDelete,
  });
  final int index;
  final ScheduleDraft schedule;
  final ValueChanged<ScheduleDraft> onChanged;
  final VoidCallback onDelete;

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  late final _dosage = TextEditingController(text: widget.schedule.dosage);
  bool _touched = false;

  @override
  void dispose() {
    _dosage.dispose();
    super.dispose();
  }

  ScheduleDraft get s => widget.schedule;

  Future<void> _pickTime() async {
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: s.hour, minute: s.minute));
    if (t != null) widget.onChanged(s.copyWith(hour: t.hour, minute: t.minute));
  }

  Future<void> _pickStart() async {
    final d = await showDatePicker(
        context: context,
        initialDate: s.startDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (d != null) widget.onChanged(s.copyWith(startDate: d));
  }

  Future<void> _pickEnd() async {
    final d = await showDatePicker(
        context: context,
        initialDate: s.endDate ?? s.startDate,
        firstDate: s.startDate,
        lastDate: DateTime(2100));
    if (d != null) widget.onChanged(s.copyWith(endDate: d));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final err = _touched || s.dosage.isNotEmpty ? s.error : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('Time ${widget.index + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            IconButton(
              tooltip: 'Remove time ${widget.index + 1}',
              icon: const Icon(Icons.delete_outline),
              onPressed: widget.onDelete,
            ),
          ]),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in SchedulePeriod.values)
              ChoiceChip(
                label: Text(p.label),
                selected: s.period == p,
                onSelected: (_) => widget.onChanged(p == SchedulePeriod.custom
                    ? s.copyWith(period: p)
                    : s.copyWith(period: p, hour: p.defaultHour, minute: p.defaultMinute)),
              ),
          ]),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.access_time),
            label: Text('Reminder time: ${s.timeText}'),
            onPressed: _pickTime,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dosage,
            onChanged: (v) {
              _touched = true;
              widget.onChanged(s.copyWith(dosage: v));
            },
            decoration: InputDecoration(
              labelText: 'Dosage *',
              hintText: 'As prescribed, e.g. 1 tablet',
              errorText: err == 'Enter the dosage exactly as prescribed.' ? err : null,
            ),
          ),
          const SizedBox(height: 12),
          Text('Food instruction', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final f in FoodInstruction.values)
              ChoiceChip(
                label: Text(f.label),
                selected: s.food == f,
                onSelected: (_) => widget.onChanged(s.copyWith(food: f)),
              ),
          ]),
          const SizedBox(height: 12),
          Text('Repeat on', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (var i = 0; i < 7; i++)
              FilterChip(
                label: Text(weekdayShort[i]),
                selected: s.repeatDays[i],
                onSelected: (v) =>
                    widget.onChanged(s.copyWith(repeatDays: [...s.repeatDays]..[i] = v)),
              ),
          ]),
          if (err == 'Choose at least one day.')
            Text(err!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: _pickStart,
                  child: FittedBox(fit: BoxFit.scaleDown, child: Text('Start: ${formatDate(s.startDate)}'))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _pickEnd,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(s.endDate == null ? 'End: none' : 'End: ${formatDate(s.endDate!)}')),
              ),
            ),
          ]),
          if (s.endDate != null)
            TextButton(
              onPressed: () => widget.onChanged(s.copyWith(clearEndDate: true)),
              child: const Text('Clear end date'),
            ),
          if (err == 'End date is before the start date.')
            Text(err!, style: TextStyle(color: theme.colorScheme.error)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder enabled'),
            value: s.enabled,
            onChanged: (v) => widget.onChanged(s.copyWith(enabled: v)),
          ),
        ],
      ),
    );
  }
}
