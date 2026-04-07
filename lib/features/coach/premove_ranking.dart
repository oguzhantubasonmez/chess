import 'move_quality.dart';
import '../engine/uci_multipv_parser.dart';

/// MultiPV sonuçlarından seçili kareye göre hedef kalitesi (en fazla 3 yeşil).
///
/// Yeşil: motor skorunda en iyiye [goodCpWithinBest] sentipiyon içinde, sırayla en çok 3 hamle.
/// Kırmızı: yeşil olmayan ve en az [badCpBelowBest] sentipiyon geride kalanlar.
Map<String, MoveQuality> rankDestinationsFromMultipv({
  required String fromSquare,
  required List<String> legalUcisFromPiece,
  required List<UciMultipvLine> engineLines,
  int badCpBelowBest = 90,
  int goodCpWithinBest = 55,
  int maxGoodMoves = 3,
}) {
  if (legalUcisFromPiece.isEmpty) return {};

  final legalSet = legalUcisFromPiece.toSet();
  final ours = <String, int>{};
  for (final line in engineLines) {
    final from = UciMultipvLine.uciFromSquare(line.firstUci);
    if (from != fromSquare) continue;
    if (!legalSet.contains(line.firstUci)) continue;
    final prev = ours[line.firstUci];
    if (prev == null || line.scoreCp > prev) {
      ours[line.firstUci] = line.scoreCp;
    }
  }

  if (ours.isEmpty) {
    final m = <String, MoveQuality>{};
    for (final u in legalUcisFromPiece) {
      final to = UciMultipvLine.uciToSquare(u);
      if (to != null) m[to] = MoveQuality.neutral;
    }
    return m;
  }

  final best = ours.values.reduce((a, b) => a > b ? a : b);
  final sortedUci = ours.keys.toList()
    ..sort((a, b) => ours[b]!.compareTo(ours[a]!));

  final goodUcis = <String>{};
  for (final u in sortedUci) {
    if (goodUcis.length >= maxGoodMoves) break;
    final s = ours[u]!;
    if (s < best - goodCpWithinBest) break;
    goodUcis.add(u);
  }

  final uciQuality = <String, MoveQuality>{};
  for (final u in legalUcisFromPiece) {
    final s = ours[u];
    if (goodUcis.contains(u)) {
      uciQuality[u] = MoveQuality.good;
    } else if (s != null && s <= best - badCpBelowBest) {
      uciQuality[u] = MoveQuality.bad;
    } else {
      uciQuality[u] = MoveQuality.neutral;
    }
  }

  final byTo = <String, List<MoveQuality>>{};
  for (final u in legalUcisFromPiece) {
    final to = UciMultipvLine.uciToSquare(u);
    if (to == null) continue;
    byTo.putIfAbsent(to, () => []).add(uciQuality[u]!);
  }

  MoveQuality fold(List<MoveQuality> qs) {
    if (qs.any((q) => q == MoveQuality.good)) return MoveQuality.good;
    if (qs.any((q) => q == MoveQuality.bad)) return MoveQuality.bad;
    return MoveQuality.neutral;
  }

  return {for (final e in byTo.entries) e.key: fold(e.value)};
}

String chessMoveToUci({
  required String fromAlgebraic,
  required String toAlgebraic,
  String? promotionLowercase,
}) {
  final b = StringBuffer()
    ..write(fromAlgebraic)
    ..write(toAlgebraic);
  if (promotionLowercase != null && promotionLowercase.isNotEmpty) {
    b.write(promotionLowercase);
  }
  return b.toString();
}
