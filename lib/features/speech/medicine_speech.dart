import '../../core/utils/format.dart';
import '../medicine/domain/medicine_models.dart';
import '../recognition/domain/recognition_models.dart';

/// Builds the sentences read aloud. Medicine names, strengths and composition are
/// read exactly as saved (never translated or altered).
class MedicineSpeech {
  static List<String> describe(MedicineDetail d) {
    final m = d.medicine;
    final out = <String>['Medicine: ${m.medicineName}.'];
    void add(String label, String? v) {
      if (v != null && v.trim().isNotEmpty) out.add('$label: ${v.trim()}.');
    }

    add('Strength', m.strength);
    add('Generic name', m.genericName);
    add('Composition', m.composition);
    add('Manufacturer', m.manufacturer);
    add('Type', m.medicineType);
    add('Prescribed dosage', m.dosage);
    add('Notes', m.notes);
    final sch = d.sortedSchedules;
    if (sch.isEmpty) {
      out.add('No schedule is set.');
    } else {
      for (final s in sch) {
        final x = ScheduleDraft.fromRow(s);
        out.add('${x.period.label} at ${x.timeText}: ${x.dosage}, ${x.food.label}. ${x.repeatText}.'
            '${x.enabled ? '' : ' Reminder is off.'}');
      }
    }
    return out;
  }

  static List<String> packaging(PackagingEdit e) {
    final out = <String>[];
    void add(String label, String v) {
      if (v.trim().isNotEmpty) out.add('$label: ${v.trim()}.');
    }

    add('Medicine name', e.name);
    add('Strength', e.strength);
    add('Composition', e.composition);
    add('Manufacturer', e.manufacturer);
    add('Batch number', e.batch);
    add('Manufacturing date', e.mfgDate);
    add('Expiry date', e.expiryDate);
    if (out.isEmpty) return ['No details were read. Please retake the photo.'];
    out.add('These details were read automatically and may contain mistakes. '
        'Please check them against the package.');
    return out;
  }

  static List<String> field(String label, String value) =>
      value.trim().isEmpty ? ['$label is empty.'] : ['$label: ${value.trim()}.'];

  static String doseAnnouncement({
    required String title,
    required String dosage,
    required String food,
    required DateTime at,
  }) =>
      'It is time to take your medicine. $title. '
      '${dosage.isEmpty ? '' : 'Dosage: $dosage. '}$food. Scheduled for ${formatTime(at.hour, at.minute)}.';
}
