import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format.dart';
import '../../medicine/domain/medicine_models.dart';
import '../data/reminder_providers.dart';
import '../domain/dose_models.dart';
import 'dose_action_buttons.dart';
import 'reminder_permission_card.dart';
import 'status_chip.dart';

class TodaysScheduleScreen extends ConsumerStatefulWidget {
  const TodaysScheduleScreen({super.key});
  @override
  ConsumerState<TodaysScheduleScreen> createState() => _State();
}

class _State extends ConsumerState<TodaysScheduleScreen> {
  DateTime _day = dateOnly(DateTime.now());

  void _shift(int days) =>
      setState(() => _day = DateTime(_day.year, _day.month, _day.day + days));

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dayDosesProvider(_day));
    final isToday = _day == dateOnly(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text(isToday ? "Today's Schedule" : 'Schedule'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(
              tooltip: 'Previous day', icon: const Icon(Icons.chevron_left), onPressed: () => _shift(-1)),
          Semantics(
            liveRegion: true,
            child: Text(formatDayHeading(_day),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          IconButton(
              tooltip: 'Next day', icon: const Icon(Icons.chevron_right), onPressed: () => _shift(1)),
        ]),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Could not load the schedule.')),
            data: (items) {
              final sorted = [...items]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
              return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
                const ReminderPermissionCard(),
                if (sorted.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No doses scheduled for this day. Add a medicine with a '
                        'schedule to see it here.', textAlign: TextAlign.center),
                  ),
                for (final p in SchedulePeriod.values)
                  ..._section(p, sorted.where((i) => i.period == p).toList()),
              ]);
            },
          ),
        ),
      ]),
    );
  }

  List<Widget> _section(SchedulePeriod p, List<DoseItem> items) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Semantics(
          header: true,
          child: Text(p.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
      ),
      for (final i in items) _DoseTile(item: i),
    ];
  }
}

class _DoseTile extends StatelessWidget {
  const _DoseTile({required this.item});
  final DoseItem item;

  @override
  Widget build(BuildContext context) {
    final t = item.scheduledAt;
    final time = formatTime(t.hour, t.minute);
    final detail = [if (item.dosageText.isNotEmpty) item.dosageText, item.food.label].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          container: true,
          label: '$time. ${item.title}. $detail. ${item.status.label}.',
          child: ExcludeSemantics(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  Text(detail),
                ]),
              ),
              StatusChip(item.status),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        DoseActionButtons(item: item),
      ]),
    );
  }
}
