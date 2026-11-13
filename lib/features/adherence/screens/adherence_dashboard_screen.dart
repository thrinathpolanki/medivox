import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../localization/tts_language_mapper.dart';
import '../../medicine_scan/services/tts_service.dart';
import '../adherence_providers.dart';
import '../services/adherence_calculator.dart';

class AdherenceDashboardScreen extends ConsumerStatefulWidget {
  const AdherenceDashboardScreen({super.key});

  @override
  ConsumerState<AdherenceDashboardScreen> createState() =>
      _AdherenceDashboardScreenState();
}

class _AdherenceDashboardScreenState
    extends ConsumerState<AdherenceDashboardScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final async = _days == 7
        ? ref.watch(weeklyAdherenceProvider)
        : ref.watch(monthlyAdherenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Speak Report',
            onPressed: () => _speakReport(async.valueOrNull),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(weeklyAdherenceProvider);
              ref.invalidate(monthlyAdherenceProvider);
            },
          ),
        ],
      ),
      body: async.when(
        data: (data) => _buildContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _speakReport(OverallAdherence? data) async {
    if (data == null) return;
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.prefLanguage) ?? 'en';
    final pct = (data.adherencePercent * 100).toStringAsFixed(0);
    final report = "Here is your adherence report for the last $_days days. "
        "You took ${data.totalTaken} doses. "
        "You missed ${data.totalMissed} doses. "
        "You skipped ${data.totalSkipped} doses. "
        "Your adherence rate is $pct percent.";

    await TtsService.speak(report, appLanguageCode: lang);
  }

  Widget _buildContent(BuildContext context, OverallAdherence data) {
    final pct = (data.adherencePercent * 100).toStringAsFixed(0);
    final color = _percentColor(data.adherencePercent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toggle 7 / 30
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 7, label: Text('7 Days')),
              ButtonSegment(value: 30, label: Text('30 Days')),
            ],
            selected: {_days},
            onSelectionChanged: (s) => setState(() => _days = s.first),
          ),
          const SizedBox(height: 16),

          // Big percentage
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Text('Adherence Rate',
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(
                    _encouragement(data.adherencePercent),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _statCard('Taken', data.totalTaken, Colors.green),
              const SizedBox(width: 8),
              _statCard('Missed', data.totalMissed, Colors.red),
              const SizedBox(width: 8),
              _statCard('Skipped', data.totalSkipped, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Daily Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Bar chart
          Container(
            height: 200,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.daily.map((d) => _bar(d)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: data.daily.map((d) => Expanded(
                  child: Text(
                    '${d.date.day}/${d.date.month}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                )).toList(),
          ),

          const SizedBox(height: 24),
          const Text(
            'Note: The adherence rate excludes "pending" doses so it does not '
            'fluctuate before you have a chance to take them.',
            style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(DailyAdherence d) {
    final total = d.total;
    if (total == 0) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    final takenH = (d.taken / total) * 160;
    final missedH = (d.missed / total) * 160;
    final skippedH = (d.skipped / total) * 160;
    final pendingH = (d.pending / total) * 160;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (missedH > 0)
              Container(height: missedH, color: Colors.red.shade400),
            if (skippedH > 0)
              Container(height: skippedH, color: Colors.orange.shade300),
            if (takenH > 0)
              Container(height: takenH, color: Colors.green.shade500),
            if (pendingH > 0)
              Container(height: pendingH, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Color _percentColor(double pct) {
    if (pct >= 0.9) return Colors.green;
    if (pct >= 0.7) return Colors.orange;
    return Colors.red;
  }

  String _encouragement(double pct) {
    if (pct >= 0.9) return 'Excellent! Keep it up. 🎉';
    if (pct >= 0.7) return 'Good job. Small improvements add up.';
    if (pct > 0) return 'Let\'s try to be more consistent this week.';
    return 'No doses recorded yet. Start tracking today!';
  }
}
