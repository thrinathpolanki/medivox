import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../database/daos/medicine_dao_provider.dart';
import '../services/matching_engine.dart';
import '../services/similar_medicine_detector.dart';
import '../services/tts_service.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final MatchingResult result;

  const ScanResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  bool _speaking = false;

  Future<void> _speakAll() async {
    setState(() => _speaking = true);

    // 1. Get the user's chosen language
    final prefs = await SharedPreferences.getInstance();
    final userLang = prefs.getString(AppConstants.prefLanguage) ?? 'en';

    final buffer = StringBuffer();
    final best = widget.result.best;

    if (best == null) {
      buffer.writeln('No matching medicine was found.');
      buffer.writeln('Here is the text I read from the packaging:');
      buffer.writeln(widget.result.extractedText);
    } else {
      buffer.writeln('Possible match found.');
      buffer.writeln('Medicine name: ${best.medicine.medicineName}');
      if (best.medicine.strength != null) {
        buffer.writeln('Strength: ${best.medicine.strength}');
      }
      buffer.writeln('Please verify this against the physical package.');
    }

    // 2. Pass the language to the service
    await TtsService.speak(buffer.toString(), appLanguageCode: userLang);

    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _stopSpeaking() async {
    await TtsService.stop();
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final best = widget.result.best;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(widget.imageFile, height: 200, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(_speaking ? Icons.stop : Icons.volume_up),
            label: Text(_speaking ? 'Stop Speaking' : 'Speak Result'),
            onPressed: _speaking
                ? _stopSpeaking
                : _speakAll, // Updated to call _stopSpeaking
          ),
          const SizedBox(height: 16),
          if (best == null) _noMatchCard() else _matchCard(best),
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text('Extracted Text'),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.result.extractedText.isEmpty
                      ? '(No text detected)'
                      : widget.result.extractedText,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (best != null) _similarMedicinesSection(best),
        ],
      ),
    );
  }

  Widget _noMatchCard() {
    return Card(
      color: Colors.amber.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Text('No Match Found',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'MediVox could not match this packaging against your registered medicines.',
            ),
            const SizedBox(height: 12),
            const Text('The camera read the following text:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.result.extractedText.isEmpty
                    ? '⚠️ NO TEXT DETECTED. Please ensure the medicine name is clear and visible.'
                    : widget.result.extractedText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/add-medicine'),
              child: const Text('Register This Medicine'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchCard(MatchCandidate candidate) {
    final isStrongMatch = candidate.confidence >= 0.6;
    final color = isStrongMatch ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: color, size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    candidate.medicine.medicineName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isStrongMatch ? 'Strong Match' : 'Possible Match',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Evidence:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...candidate.evidence.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '⚠️ Always verify the physical package before taking the medicine.',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _similarMedicinesSection(MatchCandidate best) {
    return FutureBuilder(
      future: _computeSimilar(best),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final warnings = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Similar Medicines Detected',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...warnings.map(
              (w) => Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading:
                      const Icon(Icons.warning_amber, color: Colors.orange),
                  title: Text(w.similar.first.medicineName),
                  subtitle: Text(w.reason),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<SimilarMedicineWarning>> _computeSimilar(
      MatchCandidate best) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.prefUserId) ?? 'local-user';
    final dao = ref.read(medicineDaoProvider);
    final all = await dao.getAllMedicines(userId);
    return SimilarMedicineDetector.findSimilar(
      target: best.medicine,
      allMedicines: all,
    );
  }
}
