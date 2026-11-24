import 'dart:math' as math;
import 'dart:ui' show Rect;

import '../domain/recognition_models.dart';

class PackageCluster {
  const PackageCluster(this.lines, this.bounds);
  final List<OcrLine> lines;
  final Rect bounds;
}

double overlapRatio(Rect a, Rect b) {
  final i = a.intersect(b);
  if (i.isEmpty) return 0;
  final smaller = math.min(a.width * a.height, b.width * b.height);
  return smaller <= 0 ? 0 : (i.width * i.height) / smaller;
}

/// Heuristic: text lines that sit close together belong to the same package.
/// Stray short fragments (for example a lone large brand name) are merged into
/// the nearest real cluster instead of being thrown away. It can still split one
/// large package or merge touching packages, so the UI lets the user merge everything.
class PackageClusterer {
  static Rect _union(Iterable<OcrLine> l) => l.map((x) => x.box).reduce((a, b) => a.expandToInclude(b));

  static bool _substantial(List<OcrLine> l) =>
      l.length >= 4 || (l.length >= 2 && l.fold<int>(0, (n, x) => n + x.text.length) >= 20);

  static List<PackageCluster> cluster(List<OcrLine> lines, {double gapFactor = 2.5}) {
    if (lines.isEmpty) return const [];
    final heights = lines.map((l) => l.height).toList()..sort();
    final spanW = _union(lines).width;
    final pad = math.max(heights[heights.length ~/ 2] * gapFactor, spanW * 0.06);

    final parent = List<int>.generate(lines.length, (i) => i);
    int find(int x) {
      while (parent[x] != x) {
        parent[x] = parent[parent[x]];
        x = parent[x];
      }
      return x;
    }

    for (var i = 0; i < lines.length; i++) {
      final a = lines[i].box.inflate(pad);
      for (var j = i + 1; j < lines.length; j++) {
        if (a.overlaps(lines[j].box.inflate(pad))) parent[find(i)] = find(j);
      }
    }
    final groups = <int, List<OcrLine>>{};
    for (var i = 0; i < lines.length; i++) {
      groups.putIfAbsent(find(i), () => []).add(lines[i]);
    }
    final big = [for (final g in groups.values) if (_substantial(g)) [...g]];
    final small = [for (final g in groups.values) if (!_substantial(g)) g];
    if (big.isEmpty) return [single(lines)];

    for (final frag in small) {
      final c = _union(frag).center;
      var best = 0;
      var bestD = double.infinity;
      for (var i = 0; i < big.length; i++) {
        final d = (_union(big[i]).center - c).distance;
        if (d < bestD) {
          bestD = d;
          best = i;
        }
      }
      big[best].addAll(frag);
    }
    final clusters = [for (final g in big) PackageCluster(g, _union(g))];
    clusters.sort((a, b) {
      final dy = a.bounds.top.compareTo(b.bounds.top);
      return dy != 0 ? dy : a.bounds.left.compareTo(b.bounds.left);
    });
    return clusters;
  }

  static PackageCluster single(List<OcrLine> lines) =>
      PackageCluster(lines, lines.isEmpty ? Rect.zero : _union(lines));
}
