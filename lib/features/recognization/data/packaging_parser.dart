import 'dart:math' as math;

import '../domain/recognition_models.dart';
import '../domain/text_utils.dart';

class ParsedDate {
  const ParsedDate(this.month, this.year, {this.day, this.ambiguous = false});
  final int month, year;
  final int? day;
  final bool ambiguous;
  String get display => '${month.toString().padLeft(2, '0')}/$year';

  /// Last day of the printed month: a medicine printed "EXP 03/2026" is usable
  /// through the end of March 2026.
  DateTime get lastDay => day != null ? DateTime(year, month, day!) : DateTime(year, month + 1, 0);
}

enum ExpiryState { unknown, expired, expiringSoon, valid }

/// Rule-based reader for text found on Indian medicine packaging.
/// Every field is a *suggestion* with a confidence; none is verified.
class PackagingParser {
  static const _datePat =
      r"(\d{1,2}\s*[/\-.]\s*\d{1,2}\s*[/\-.]\s*\d{2,4}|\d{1,2}\s*[/\-.]\s*\d{2,4}|[A-Za-z]{3,9}\.?\s*[\-']?\s*\d{2,4})";
  static final _expRe = RegExp(
      r'(?:exp(?:iry|ires)?|use\s+before|best\s+before)\.?\s*(?:date)?\s*[:\-]?\s*' + _datePat,
      caseSensitive: false);
  static final _mfgRe = RegExp(
      r'(?:mfg|mfd|manufactur(?:ing|ed)?)\.?\s*(?:date)?\s*[:\-]?\s*' + _datePat,
      caseSensitive: false);
  static final _batchRe = RegExp(
      r'(?:b\.?\s*no\.?|batch\s*(?:no\.?|number)?|lot\s*(?:no\.?)?)\s*[:\-]?\s*([A-Z0-9][A-Z0-9\-/]{2,})',
      caseSensitive: false);
  static final _mfrByRe = RegExp(
      r'(?:manufactured|marketed|mfd\.?|mktd\.?)\s*by\s*[:\-]?\s*(.*)',
      caseSensitive: false);
  static final _companyRe = RegExp(
      r'\b(ltd|limited|pvt|pharma\w*|laboratories|labs?|healthcare|lifesciences?|industries)\b',
      caseSensitive: false);
  static final _compStartRe = RegExp(
      r'(each|per)\b.*\b(tablet|capsule|ml|5\s*ml)\b.*\bcontains?\b|^composition|^contains?\s*:',
      caseSensitive: false);
  static final _stopLineRe = RegExp(
      r'\b(mfg|mfd|manufactured|marketed|batch|b\.?\s*no|exp|expiry|price|mrp|store|keep|warning|schedule)\b',
      caseSensitive: false);
  static final _noiseRe = RegExp(
      r'^(rx|tablets?|capsules?|ip|bp|usp|strips?|each|composition|store|keep|warning|schedule|mfg|mfd|exp|batch|price|mrp|for|use|only|made in india)\b',
      caseSensitive: false);
  static final _formWords = RegExp(
      r'\b(tablets?|capsules?|syrup|suspension|injection|ip|bp|usp|film\s*coated|uncoated)\b',
      caseSensitive: false);
  static const _months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'];

  static int _fixYear(int y) => y < 100 ? 2000 + y : y;

  static ParsedDate? parseDate(String raw) {
    final s = raw.trim();
    final dmy = RegExp(r'^(\d{1,2})\s*[/\-.]\s*(\d{1,2})\s*[/\-.]\s*(\d{2,4})$').firstMatch(s);
    int? month, year, day;
    var ambiguous = false;
    if (dmy != null) {
      day = int.parse(dmy.group(1)!);
      month = int.parse(dmy.group(2)!);
      year = _fixYear(int.parse(dmy.group(3)!));
    } else {
      final my = RegExp(r'^(\d{1,2})\s*[/\-.]\s*(\d{2,4})$').firstMatch(s);
      if (my != null) {
        month = int.parse(my.group(1)!);
        final y = my.group(2)!;
        year = _fixYear(int.parse(y));
        ambiguous = y.length == 2 && int.parse(y) <= 12;
      } else {
        final nm = RegExp(r"^([A-Za-z]{3,9})\.?\s*[\-']?\s*(\d{2,4})$").firstMatch(s);
        if (nm != null) {
          final idx = _months.indexOf(nm.group(1)!.substring(0, 3).toLowerCase());
          if (idx >= 0) {
            month = idx + 1;
            year = _fixYear(int.parse(nm.group(2)!));
          }
        }
      }
    }
    if (month == null || year == null) return null;
    if (month < 1 || month > 12 || year < 2000 || year > 2100) return null;
    if (day != null && (day < 1 || day > 31)) return null;
    return ParsedDate(month, year, day: day, ambiguous: ambiguous);
  }

  static ExpiryState expiryState(String? text, DateTime now) {
    if (text == null || text.trim().isEmpty) return ExpiryState.unknown;
    final d = parseDate(text.trim());
    if (d == null) return ExpiryState.unknown;
    final today = DateTime(now.year, now.month, now.day);
    if (d.lastDay.isBefore(today)) return ExpiryState.expired;
    if (d.lastDay.difference(today).inDays <= 30) return ExpiryState.expiringSoon;
    return ExpiryState.valid;
  }

  static ExtractedField? _date(RegExp re, String flat, String evidence) {
    for (final m in re.allMatches(flat)) {
      final d = parseDate(m.group(1)!);
      if (d != null) {
        return ExtractedField(
            d.display, d.ambiguous ? FieldConfidence.low : FieldConfidence.medium, evidence);
      }
    }
    return null;
  }

  static String _cleanName(String s) {
    var t = s.replaceAll(RegExp(r'[0-9OoIl.,]*\s*(mcg|µg|mg|g|ml|iu|%)\b', caseSensitive: false), ' ');
    t = t.replaceAll(_formWords, ' ').replaceAll(RegExp(r'[^\p{L}\p{N}\s\-]', unicode: true), ' ');
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static PackagingFields parse(List<OcrLine> input) {
    final lines = [...input]..removeWhere((l) => l.text.trim().isEmpty);
    lines.sort((a, b) => a.box.top.compareTo(b.box.top));
    final texts = lines.map((l) => l.text.trim()).toList();
    final flat = texts.join(' ');

    // Strengths
    final strengths = [
      for (final s in Strength.findAll(flat))
        ExtractedField(s.display, FieldConfidence.medium, 'number followed by a unit'),
    ];

    // Dates and batch
    final expiry = _date(_expRe, flat, 'after "EXP"');
    final mfg = _date(_mfgRe, flat, 'after "MFG"');
    ExtractedField? batch;
    final bm = _batchRe.firstMatch(flat);
    if (bm != null) {
      final v = bm.group(1)!.toUpperCase();
      batch = ExtractedField(v, RegExp(r'\d').hasMatch(v) ? FieldConfidence.medium : FieldConfidence.low,
          'after "Batch No"');
    }

    // Manufacturer
    ExtractedField? manufacturer;
    for (var i = 0; i < texts.length && manufacturer == null; i++) {
      final m = _mfrByRe.firstMatch(texts[i]);
      if (m == null || RegExp(r'\bdate\b', caseSensitive: false).hasMatch(texts[i])) continue;
      var rest = m.group(1)!.trim();
      if (rest.length < 4 && i + 1 < texts.length) rest = texts[i + 1].trim();
      if (rest.length >= 4) manufacturer = ExtractedField(rest, FieldConfidence.medium, 'after "Manufactured/Marketed by"');
    }
    if (manufacturer == null) {
      for (final t in texts) {
        if (_companyRe.hasMatch(t) && t.length < 80 && !_stopLineRe.hasMatch(t)) {
          manufacturer = ExtractedField(t, FieldConfidence.low, 'line that looks like a company name');
          break;
        }
      }
    }

    // Composition
    ExtractedField? composition;
    for (var i = 0; i < texts.length; i++) {
      if (_compStartRe.hasMatch(texts[i])) {
        final parts = <String>[texts[i]];
        for (var j = i + 1; j < texts.length && parts.length < 4; j++) {
          if (_stopLineRe.hasMatch(texts[j])) break;
          parts.add(texts[j]);
        }
        composition = ExtractedField(parts.join(' '), FieldConfidence.medium, 'after "Each tablet contains" / "Composition"');
        break;
      }
    }
    if (composition == null) {
      final ing = texts.where((t) =>
          RegExp(r'^[A-Za-z][A-Za-z\- ]{3,}\s*(IP|BP|USP)?\s*[0-9OoIl.,]+\s*(mg|mcg|µg|g)\b', caseSensitive: false)
              .hasMatch(t)).toList();
      if (ing.isNotEmpty) {
        composition = ExtractedField(ing.take(3).join('; '), FieldConfidence.low, 'line with an ingredient and strength');
      }
    }

    // Name candidates: largest, cleanest text lines.
    final heights = lines.map((l) => l.height).toList()..sort();
    final median = heights.isEmpty ? 1.0 : heights[heights.length ~/ 2];
    final scored = <(String, double)>[];
    for (final l in lines) {
      final t = l.text.trim();
      if (t.length < 3 || _noiseRe.hasMatch(t) || _stopLineRe.hasMatch(t) || _companyRe.hasMatch(t)) continue;
      final letters = RegExp(r'\p{L}', unicode: true).allMatches(t).length;
      if (letters / t.length < 0.6) continue;
      final cleaned = _cleanName(t);
      if (cleaned.length < 3) continue;
      scored.add((cleaned, l.height / math.max(median, 1)));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    final seen = <String>{};
    final names = <ExtractedField>[];
    for (final s in scored) {
      if (!seen.add(TextUtils.normalize(s.$1))) continue;
      names.add(ExtractedField(
          s.$1,
          s.$2 >= 1.5 ? FieldConfidence.medium : FieldConfidence.low,
          s.$2 >= 1.5 ? 'large printed text' : 'printed text'));
      if (names.length == 4) break;
    }

    final used = {for (final f in [composition, manufacturer, batch, mfg, expiry]) if (f != null) f.value};
    final others = [
      for (final t in texts)
        if (!used.any((u) => u.contains(t) || t.contains(u))) t,
    ].take(20).toList();

    return PackagingFields(
      nameCandidates: names,
      strengths: strengths,
      composition: composition,
      manufacturer: manufacturer,
      batch: batch,
      mfgDate: mfg,
      expiryDate: expiry,
      otherLines: others,
    );
  }
}
