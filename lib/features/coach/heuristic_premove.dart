import 'package:chess/chess.dart' as ch;

import 'move_quality.dart';

/// Stockfish yokken (ör. web): alım / şah / korunmasız kareye basit renk kodu.
Map<String, MoveQuality> heuristicDestinationQuality({
  required ch.Chess game,
  required String fromSquare,
  required List<ch.Move> legalFromPiece,
}) {
  final byTo = <String, List<MoveQuality>>{};

  for (final m in legalFromPiece) {
    if (m.fromAlgebraic != fromSquare) continue;
    final q = _classifyMove(game, m);
    byTo.putIfAbsent(m.toAlgebraic, () => []).add(q);
  }

  MoveQuality fold(List<MoveQuality> qs) {
    if (qs.any((q) => q == MoveQuality.good)) return MoveQuality.good;
    if (qs.any((q) => q == MoveQuality.bad)) return MoveQuality.bad;
    return MoveQuality.neutral;
  }

  return {for (final e in byTo.entries) e.key: fold(e.value)};
}

MoveQuality _classifyMove(ch.Chess game, ch.Move m) {
  if (m.captured != null) return MoveQuality.good;

  final g2 = ch.Chess.fromFEN(game.fen, check_validity: false);
  if (!g2.move(m)) return MoveQuality.neutral;

  if (g2.in_check) return MoveQuality.good;

  final to = m.toAlgebraic;
  final sq = ch.Chess.SQUARES[to];
  if (sq == null) return MoveQuality.neutral;
  final sqInt = sq as int;

  if (g2.attacked(g2.turn, sqInt)) {
    return MoveQuality.bad;
  }
  return MoveQuality.neutral;
}
