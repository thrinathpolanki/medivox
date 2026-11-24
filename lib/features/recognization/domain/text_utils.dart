import 'dart:math' as math;

class TextUtils {
  static final _punct = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _spaces = RegExp(r'\s+');

  static String normalize(String s) =>
      s.toLowerCase().replaceAll(_punct, ' ').replaceAll(_spaces, ' ').trim();

  static List<String> tokens(String s) {
    final n = normalize(s);
    return n.isEmpty ? <String>[] : n.split(' ');
  }

  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var cur = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      cur[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        cur[j] = math.min(math.min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      final t = prev;
      prev = cur;
      cur = t;
    }
    return prev[b.length];
  }

  /// 1.0 = identical, 0.0 = nothing in common (after normalising).
  static double similarity(String a, String b) {
    final x = normalize(a).replaceAll(' ', ''), y = normalize(b).replaceAll(' ', '');
    if (x.isEmpty || y.isEmpty) return 0;
    return 1 - levenshtein(x, y) / math.max(x.length, y.length);
  }

  /// Best similarity between [needle] and any run of consecutive OCR tokens.
  /// Tolerates OCR splitting a word ("Para cetamol") and small misreads.
  /// Very short needles (under 4 letters) must match exactly.
  /// Collapses letters/digits that OCR commonly confuses (0/o, 1/l/i, 5/s, 8/b, rn/m, vv/w)
  /// so a misread character costs nothing.
  static String fold(String s) => s
      .replaceAll('rn', 'm')
      .replaceAll('vv', 'w')
      .replaceAll('0', 'o')
      .replaceAll('1', 'l')
      .replaceAll('i', 'l')
      .replaceAll('5', 's')
      .replaceAll('8', 'b');

  static const _weak = {
    'forte', 'plus', 'strong', 'max', 'ds', 'xl', 'sr', 'cr', 'er', 'mr', 'od', 'sf', 'new',
    'advance', 'active', 'gold', 'extra', 'ultra', 'junior',
  };

  /// Weighted share of the name's words found anywhere in the text (order-free),
  /// tolerant of OCR confusions. Variant words like "Forte" count half. Returns 0
  /// unless the main (longest non-variant) word is clearly present.
  static double tokenCoverage(String needle, List<String> hay) {
    final nt = tokens(needle);
    if (nt.isEmpty || hay.isEmpty) return 0;
    final h = [for (final t in hay) fold(t)];
    var total = 0.0, weight = 0.0, longestSim = 0.0;
    var longestLen = 0;
    for (final t in nt) {
      final ft = fold(t);
      var best = 0.0;
      for (final x in h) {
        final s = ft.length < 3 ? (ft == x ? 1.0 : 0.0) : 1 - levenshtein(ft, x) / math.max(ft.length, x.length);
        if (s > best) best = s;
      }
      final w = (_weak.contains(t) ? 0.5 : 1.0) * math.max(t.length, 2);
      total += w * best;
      weight += w;
      if (!_weak.contains(t) && t.length > longestLen) {
        longestLen = t.length;
        longestSim = best;
      }
    }
    return longestSim < 0.85 ? 0 : total / weight;
  }

  static double partialSimilarity(String needle, List<String> hay, {bool fold = false}) {
    if (fold) {
      return partialSimilarity(TextUtils.fold(normalize(needle)), [for (final h in hay) TextUtils.fold(h)]);
    }
    final nt = tokens(needle);
    if (nt.isEmpty || hay.isEmpty) return 0;
    final target = nt.join();
    final hayJoined = hay.join();
    if (target.length < 4) return hay.contains(target) ? 1.0 : 0.0;
    if (hayJoined.contains(target)) return 1.0;
    var best = 0.0;
    for (var size = 1; size <= nt.length + 1; size++) {
      for (var i = 0; i + size <= hay.length; i++) {
        final s = 1 - levenshtein(target, hay.sublist(i, i + size).join()) /
            math.max(target.length, hay.sublist(i, i + size).join().length);
        if (s > best) best = s;
      }
    }
    return best;
  }

  static const _formWords = {
    'tablet', 'tablets', 'tab', 'tabs', 'capsule', 'capsules', 'cap', 'caps', 'syrup', 'suspension',
    'injection', 'ip', 'bp', 'usp', 'film', 'coated', 'uncoated', 'mg', 'mcg', 'ml', 'gm', 'iu',
  };

  /// The distinctive part of a medicine name: without strength and dosage-form
  /// words ("Paracetamol 500mg Tablets" -> "paracetamol"; "Dolo 650" -> "dolo").
  static String nameCore(String name) {
    final toks = tokens(name)
        .where((t) => !_formWords.contains(t) && !RegExp(r'^\d+(mg|mcg|ml|g|iu)?$').hasMatch(t))
        .toList();
    return toks.join(' ');
  }

  /// Numbers inside a name, e.g. "Dolo 650" -> ["650"].
  static List<String> nameNumbers(String name) => [
        for (final t in tokens(name))
          if (RegExp(r'^(\d{2,4})(mg|mcg|ml|g|iu)?$').firstMatch(t) != null)
            RegExp(r'^(\d{2,4})').firstMatch(t)!.group(1)!,
      ];

  static const _boiler = {
    'each', 'contains', 'manufactured', 'marketed', 'mfg', 'mfd', 'exp', 'expiry', 'batch', 'date',
    'price', 'mrp', 'inclusive', 'taxes', 'store', 'below', 'protect', 'keep', 'reach', 'children',
    'schedule', 'warning', 'prescription', 'registered', 'medical', 'practitioner', 'only', 'india',
    'made', 'ltd', 'limited', 'pvt', 'pharma', 'pharmaceuticals', 'laboratories', 'labs', 'healthcare',
    'dosage', 'directed', 'physician', 'strip', 'use', 'before', 'the', 'and', 'not', 'per', 'pack',
    'net', 'content', 'sold', 'retail', 'without', 'strips', 'tablets', 'tablet', 'capsules', 'capsule',
    'lifesciences', 'industries', 'unit', 'plot', 'road', 'phase', 'village', 'district', 'state',
  };

  /// Words/numbers that identify a product on its packaging. Batch numbers,
  /// dates and generic boilerplate are left out because they change between
  /// boxes of the very same medicine.
  static Set<String> distinctiveTokens(String text, {Set<String> exclude = const {}}) {
    final out = <String>{};
    for (final t in tokens(text)) {
      if (exclude.contains(t)) continue;
      if (RegExp(r'^\d+$').hasMatch(t)) {
        final n = int.tryParse(t);
        if (t.length >= 2 && t.length <= 4 && !(n != null && n >= 1900 && n <= 2100)) out.add(t);
        continue;
      }
      if (RegExp(r'\d').hasMatch(t)) continue;
      if (t.length >= 3 && !_boiler.contains(t) && !_stop.contains(t) && !_formWords.contains(t)) out.add(t);
    }
    return out;
  }

  static bool _tokenHit(String t, Set<String> others) {
    if (others.contains(t)) return true;
    if (t.length < 5) return false;
    return others.any((o) => o.length >= 5 && similarity(t, o) >= 0.85);
  }

  /// How much of a registered package's printed text appears in the scanned text
  /// (0..1), or null when the registered text is too short to compare.
  static double? printOverlap(String scanned, String registeredPrint, {Set<String> exclude = const {}}) {
    final a = distinctiveTokens(scanned), b = distinctiveTokens(registeredPrint, exclude: exclude);
    if (b.length < 4 || a.isEmpty) return null;
    final recall = b.where((t) => _tokenHit(t, a)).length / b.length;
    final precision = a.where((t) => _tokenHit(t, b)).length / a.length;
    return 0.7 * recall + 0.3 * precision;
  }

  static const _stop = {
    'tablet', 'tablets', 'capsule', 'capsules', 'each', 'contains', 'film', 'coated',
    'uncoated', 'equivalent', 'excipients', 'quantity', 'sufficient', 'colour', 'colours',
    'store', 'below', 'protect', 'light', 'moisture', 'syrup', 'suspension', 'injection',
    'composition', 'ingredients', 'active', 'inactive', 'with', 'from', 'than',
  };

  /// Alphabetic words of 4+ letters that could be ingredient names.
  static Set<String> ingredientTokens(String s) => {
        for (final t in tokens(s))
          if (t.length >= 4 && RegExp(r'^\p{L}+$', unicode: true).hasMatch(t) && !_stop.contains(t)) t,
      };
}

/// A strength such as "500 mg". Mass units are compared in micrograms so
/// 0.5 g == 500 mg. Different unit classes never compare equal.
class Strength {
  const Strength(this.value, this.unitClass, this.display);
  final double value;
  final String unitClass; // mass | ml | iu | pct
  final String display;

  bool sameAs(Strength o) => unitClass == o.unitClass && (value - o.value).abs() < 1e-6;

  static final _re = RegExp(
      r'([0-9][0-9OoIl.,]*|[OoIl]+[0-9][0-9OoIl.,]*)\s*(mcg|µg|μg|ug|mg|g|ml|iu|%)(?![a-zA-Z])',
      caseSensitive: false);

  static List<Strength> findAll(String text) {
    final out = <Strength>[];
    for (final m in _re.allMatches(text)) {
      final numText = m
          .group(1)!
          .replaceAll(RegExp(r'[Oo]'), '0')
          .replaceAll(RegExp(r'[Il]'), '1')
          .replaceAll(',', '');
      final v = double.tryParse(numText);
      if (v == null) continue;
      final u = m.group(2)!.toLowerCase();
      final (cls, base) = switch (u) {
        'mcg' || 'µg' || 'μg' || 'ug' => ('mass', v),
        'mg' => ('mass', v * 1000),
        'g' => ('mass', v * 1000000),
        'ml' => ('ml', v),
        'iu' => ('iu', v),
        _ => ('pct', v),
      };
      final s = Strength(base, cls, '${numText.endsWith('.') ? numText.substring(0, numText.length - 1) : numText} ${u == 'iu' ? 'IU' : u}');
      if (!out.any((e) => e.sameAs(s))) out.add(s);
    }
    return out;
  }
}
