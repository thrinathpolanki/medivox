import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:medivox/database/app_database.dart';
import 'package:medivox/features/medicine/domain/medicine_models.dart';
import 'package:medivox/features/recognition/data/medicine_matcher.dart';
import 'package:medivox/features/recognition/data/package_clusterer.dart';
import 'package:medivox/features/recognition/data/packaging_parser.dart';
import 'package:medivox/features/recognition/data/similar_medicine_checker.dart';
import 'package:medivox/features/recognition/domain/recognition_models.dart';
import 'package:medivox/features/recognition/domain/text_utils.dart';
import 'package:medivox/features/voice_assistant/voice_intents.dart';

OcrLine _l(String t, double top, {double h = 12, double left = 0}) =>
    OcrLine(t, Rect.fromLTWH(left, top, 300, h));

MedicineDetail _med(String name,
    {String? strength, String? generic, String? composition, String? manufacturer, String id = 'm1'}) {
  final now = DateTime(2026, 1, 1);
  return MedicineDetail(
    Medicine(
      medicineId: id,
      userId: 'u',
      medicineName: name,
      genericName: generic,
      strength: strength,
      composition: composition,
      manufacturer: manufacturer,
      medicineType: null,
      dosage: null,
      prescriptionReference: null,
      notes: null,
      startDate: null,
      endDate: null,
      reminderEnabled: true,
      createdAt: now,
      updatedAt: now,
      revision: 1,
      syncStatus: 'local_only',
    ),
    const [],
    const [],
  );
}

final _paracetamolStrip = [
  _l('Paracetamol Tablets IP 500 mg', 0, h: 40),
  _l('Each film coated tablet contains:', 50),
  _l('Paracetamol IP 500 mg', 64),
  _l('Mfg. Date: 04/2024 Exp. Date: 03/2026', 80),
  _l('B.No.: ABC123', 96),
  _l('Mfd. by: ABC Pharma Ltd.', 112),
];
final _stripText = _paracetamolStrip.map((l) => l.text).join('\n');

void main() {
  group('text utils', () {
    test('partial similarity tolerates split words and one misread letter', () {
      expect(TextUtils.partialSimilarity('Paracetamol', ['para', 'cetamol']), 1.0);
      expect(TextUtils.partialSimilarity('Paracetamol', ['paracetamoi']), greaterThan(0.85));
      expect(TextUtils.partialSimilarity('Paracetamol', ['azithromycin']), lessThan(0.5));
    });

    test('strengths: unit conversion, OCR digit confusion, different units differ', () {
      expect(Strength.findAll('Paracetamol IP 500 mg').single.display, '500 mg');
      expect(Strength.findAll('5OO mg').single.sameAs(Strength.findAll('500 mg').single), isTrue);
      expect(Strength.findAll('0.5 g').single.sameAs(Strength.findAll('500 mg').single), isTrue);
      expect(Strength.findAll('500 mcg').single.sameAs(Strength.findAll('500 mg').single), isFalse);
    });
  });

  group('packaging parser', () {
    final f = PackagingParser.parse(_paracetamolStrip);
    test('reads name, strength, dates, batch, manufacturer, composition', () {
      expect(f.name!.value, 'Paracetamol');
      expect(f.strengths.map((s) => s.value), contains('500 mg'));
      expect(f.expiryDate!.value, '03/2026');
      expect(f.mfgDate!.value, '04/2024');
      expect(f.batch!.value, 'ABC123');
      expect(f.manufacturer!.value, contains('ABC Pharma'));
      expect(f.composition!.value, contains('Paracetamol'));
    });

    test('expiry state', () {
      final now = DateTime(2026, 3, 20);
      expect(PackagingParser.expiryState('03/2026', now), ExpiryState.expiringSoon);
      expect(PackagingParser.expiryState('02/2026', now), ExpiryState.expired);
      expect(PackagingParser.expiryState('03/2028', now), ExpiryState.valid);
      expect(PackagingParser.expiryState('garbage', now), ExpiryState.unknown);
    });

    test('invalid dates are rejected', () {
      expect(PackagingParser.parseDate('13/2026'), isNull);
      expect(PackagingParser.parseDate('Mar 2026')!.display, '03/2026');
    });
  });

  group('matcher', () {
    const matcher = MedicineMatcher();
    final fields = PackagingParser.parse(_paracetamolStrip);

    test('name + strength + ingredients + manufacturer all agreeing is Matched (confirmed)', () async {
      final r = await matcher.match(fields, _stripText,
          [_med('Paracetamol', strength: '500 mg', composition: 'Paracetamol 500 mg', manufacturer: 'ABC Pharma')]);
      expect(r.status, PackageStatus.confirmed);
      expect(r.matches.first.evidence.any((e) => e.label == 'Strength' && !e.conflict), isTrue);
    });

    test('only name + strength agreeing is likely, not confirmed', () async {
      final r = await matcher.match(fields, _stripText, [_med('Paracetamol', strength: '500 mg')]);
      expect(r.status, PackageStatus.likely);
    });

    test('a saved strength that cannot be read on the pack prevents Matched', () async {
      const noStrength = [];
      final lines = [_l('Paracetamol Tablets', 0, h: 40), _l('Each tablet contains Paracetamol', 50), _l('Mfd. by: ABC Pharma Ltd.', 70)];
      final r = await matcher.match(PackagingParser.parse(lines), lines.map((l) => l.text).join('\n'),
          [_med('Paracetamol', strength: '500 mg', composition: 'Paracetamol', manufacturer: 'ABC Pharma')]);
      expect(noStrength, isEmpty);
      expect(r.status, isNot(PackageStatus.confirmed));
    });

    test('OCR confusions (1 for l, 0 for o) do not stop a match', () async {
      expect(TextUtils.partialSimilarity('Dolo', ['do1o'], fold: true), 1.0);
      expect(TextUtils.partialSimilarity('Paracetamol', ['paracetam0l'], fold: true), 1.0);
    });

    test('same name but different strength is a conflict, never a clean match', () async {
      final r = await matcher.match(fields, _stripText, [_med('Paracetamol', strength: '650 mg')]);
      expect(r.status, PackageStatus.conflict);
    });

    test('generic-only evidence never counts as likely (could be another brand)', () async {
      final r = await matcher.match(fields, _stripText, [_med('Crocin', generic: 'Paracetamol')]);
      expect(r.status, PackageStatus.possible);
      expect(r.matches.first.level, isNot(MatchLevel.likely));
    });

    test('unrelated registered medicine is not guessed', () async {
      final r = await matcher.match(fields, _stripText, [_med('Azithromycin', strength: '500 mg')]);
      expect(r.status, PackageStatus.unmatched);
      expect(r.matches, isEmpty);
    });

    test('unreadable text is reported, not guessed', () async {
      final r = await matcher.match(const PackagingFields(), 'a b', [_med('Paracetamol')]);
      expect(r.status, PackageStatus.unreadable);
    });

    test('the same medicine saved twice is ONE medicine, not an ambiguity', () async {
      final r = await matcher.match(fields, _stripText,
          [_med('Paracetamol', strength: '500 mg', id: 'a'), _med('Paracetamol', strength: '500 mg', id: 'b')]);
      expect(r.status, isIn([PackageStatus.likely, PackageStatus.confirmed]));
      expect(r.matches.length, 1);
      expect(r.note, contains('saved more than once'));
    });

    test('two genuinely different medicines that both fit are ambiguous', () async {
      final lines = [_l('Paracetamol Tablets IP', 0, h: 40), _l('Ibuprofen Tablets IP', 60, h: 40), _l('Store below 25 C', 120)];
      final r = await matcher.match(PackagingParser.parse(lines), lines.map((l) => l.text).join('\n'),
          [_med('Paracetamol', id: 'a'), _med('Ibuprofen', id: 'b')]);
      expect(r.status, PackageStatus.ambiguous);
    });

    test('a variant word like Forte that is misread does not sink the match', () async {
      expect(TextUtils.tokenCoverage('Beplex Forte', ['beplex', 'vitamin', 'fort']), greaterThan(0.85));
      expect(TextUtils.tokenCoverage('Beplex Forte', ['vitamin', 'forte']), 0.0); // main word missing
      final lines = [_l('BEPLEX', 0, h: 40), _l('Vitamin B Complex Tablets', 50), _l('Store in a cool dry place', 70)];
      final r = await matcher.match(PackagingParser.parse(lines), lines.map((l) => l.text).join('\n'),
          [_med('Beplex Forte')]);
      expect(r.matches, isNotEmpty);
    });

    test('Matched / Likely speak only the saved plan; weaker results give no dosage', () async {
      final seg = ScanWording.spokenSegments(PackageResult(
        index: 0, bounds: Rect.zero, lines: const [], fields: const PackagingFields(),
        matches: [MedicineMatch(_med('Paracetamol', strength: '500 mg'), 0.9, MatchLevel.likely, const [])],
        status: PackageStatus.likely));
      expect(seg.first, 'Paracetamol 500 mg.');
      expect(seg.join(' '), isNot(contains('verify')));
      final weak = ScanWording.spokenSegments(PackageResult(
        index: 0, bounds: Rect.zero, lines: const [], fields: const PackagingFields(),
        matches: [MedicineMatch(_med('Paracetamol', strength: '500 mg'), 0.7, MatchLevel.possible, const [])],
        status: PackageStatus.possible));
      expect(weak.single, contains('not sure'));
    });
  });

  group('real-world names and saved-photo text', () {
    const matcher = MedicineMatcher();
    final fields = PackagingParser.parse(_paracetamolStrip);

    test('name core ignores strength and dosage-form words', () {
      expect(TextUtils.nameCore('Paracetamol 500mg Tablets IP'), 'paracetamol');
      expect(TextUtils.nameCore('Dolo 650'), 'dolo');
      expect(TextUtils.nameNumbers('Dolo 650'), ['650']);
    });

    test('a saved name that includes strength and "Tablets" still matches the pack', () async {
      final r = await matcher.match(fields, _stripText,
          [_med('Paracetamol 500mg Tablets', strength: '500 mg')]);
      expect(r.status, PackageStatus.likely);
    });

    test('a number in the saved name that is not on the pack is a conflict', () async {
      final text = 'DOLO 500\nParacetamol Tablets IP 500 mg\nStore below 25 C protect from light';
      final r = await matcher.match(PackagingParser.parse([_l('DOLO 500', 0, h: 40), _l('Paracetamol Tablets IP 500 mg', 50), _l('Store below 25 C protect from light', 70)]),
          text, [_med('Dolo 650')]);
      expect(r.matches.single.level, MatchLevel.conflict);
    });

    test('printed text of the saved photos finds the medicine even if the typed name differs', () async {
      const savedPhotoText = 'Paracetamol Tablets IP 500 mg\nEach film coated tablet contains Paracetamol IP 500 mg\nMfd. by ABC Pharma Ltd';
      final r = await matcher.match(fields, _stripText, [_med('My pain tablet', strength: '500 mg', composition: 'Paracetamol 500 mg')],
          printText: (_) async => savedPhotoText);
      expect(r.matches, isNotEmpty);
      expect(r.status, anyOf(PackageStatus.possible, PackageStatus.likely));
      expect(r.matches.first.evidence.any((e) => e.label == 'Saved photos'), isTrue);
    });

    test('saved-photo text of a different medicine does not match', () async {
      const other = 'Azithromycin Tablets IP 500 mg\nAzithral Alembic Pharmaceuticals respiratory infections course';
      final r = await matcher.match(fields, _stripText, [_med('Azithral', strength: '500 mg')],
          printText: (_) async => other);
      expect(r.status, PackageStatus.unmatched);
      expect(r.diagnostics, isNotEmpty);
    });
  });

  group('clusterer', () {
    test('separates distant groups and keeps close lines together', () {
      final lines = [
        _l('Dolo 650', 0, h: 20), _l('Paracetamol Tablets', 25, h: 20),
        _l('Azithral 500', 0, h: 20, left: 900), _l('Azithromycin Tablets', 25, h: 20, left: 900),
      ];
      final c = PackageClusterer.cluster(lines);
      expect(c.length, 2);
      expect(c.every((x) => x.lines.length == 2), isTrue);
    });

    test('a lone large brand name far above the small print stays with its package', () {
      final lines = [
        OcrLine('DOLO', const Rect.fromLTWH(0, 0, 120, 60)),
        _l('Paracetamol Tablets IP 650 mg', 260, h: 14),
        _l('Each tablet contains Paracetamol', 280, h: 14),
        _l('Mfg. Date: 04/2024 Exp. Date: 03/2026', 300, h: 14),
        _l('B.No.: ABC123', 320, h: 14),
      ];
      final c = PackageClusterer.cluster(lines);
      expect(c.length, 1);
      expect(c.single.lines.length, 5);
    });

    test('one package stays one cluster', () {
      expect(PackageClusterer.cluster(_paracetamolStrip).length, 1);
    });
  });

  group('similar medicines', () {
    test('similar names are flagged with the required wording', () {
      final w = SimilarMedicineChecker.check([_med('Cetrizine', id: 'a'), _med('Cetirizine', id: 'b')]);
      expect(w.single.kinds, contains(SimilarityKind.similarName));
      expect(SimilarMedicineChecker.message, contains('appear similar'));
    });

    test('same name with different strengths is flagged', () {
      final w = SimilarMedicineChecker.check(
          [_med('Metformin', strength: '500 mg', id: 'a'), _med('Metformin', strength: '850 mg', id: 'b')]);
      expect(w.single.kinds, contains(SimilarityKind.sameNameDifferentStrength));
    });

    test('shared ingredient across brands is flagged; unrelated medicines are not', () {
      final shared = SimilarMedicineChecker.check([
        _med('Dolo', composition: 'Paracetamol 650 mg', id: 'a'),
        _med('Crocin', composition: 'Paracetamol 500 mg', id: 'b'),
      ]);
      expect(shared.single.kinds, contains(SimilarityKind.sharedIngredient));
      expect(
          SimilarMedicineChecker.check([
            _med('Amlodipine', strength: '5 mg', id: 'a'),
            _med('Azithromycin', strength: '500 mg', id: 'b'),
          ]),
          isEmpty);
    });
  });

  group('voice intents', () {
    test('commands from the spec', () {
      expect(VoiceIntentParser.parse('scan medicine'), VoiceIntent.scanMedicine);
      expect(VoiceIntentParser.parse('what medicine is this'), VoiceIntent.scanMedicine);
      expect(VoiceIntentParser.parse('read the medicine packaging'), VoiceIntent.readPackaging);
      expect(VoiceIntentParser.parse('read my medicines'), VoiceIntent.readMedicines);
      expect(VoiceIntentParser.parse('what medicines should I take today'), VoiceIntent.todayDoses);
      expect(VoiceIntentParser.parse('show my reminders'), VoiceIntent.showReminders);
      expect(VoiceIntentParser.parse('what medicines have I missed'), VoiceIntent.missedDoses);
      expect(VoiceIntentParser.parse('open my reports'), VoiceIntent.openReports);
      expect(VoiceIntentParser.parse('go to settings'), VoiceIntent.openSettings);
      expect(VoiceIntentParser.parse('blah blah'), VoiceIntent.unknown);
    });

    test('yes/no and dose actions need a clear word', () {
      expect(VoiceIntentParser.yesNo('yes please'), isTrue);
      expect(VoiceIntentParser.yesNo('no'), isFalse);
      expect(VoiceIntentParser.yesNo('maybe'), isNull);
      expect(VoiceIntentParser.doseAction('I took it'), 'taken');
      expect(VoiceIntentParser.doseAction('snooze'), 'snooze');
      expect(VoiceIntentParser.doseAction('hmm'), isNull);
    });
  });
}
