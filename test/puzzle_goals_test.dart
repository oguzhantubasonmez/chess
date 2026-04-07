import 'package:chess/chess.dart' as ch;
import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/game/uci_move_codec.dart';
import 'package:satranc_2d/features/puzzle/chess_puzzle.dart' show PuzzleGoal;
import 'package:satranc_2d/features/puzzle/puzzles_catalog.dart';

void main() {
  group('Mat 1 bulmacaları gerçekten mat', () {
    for (final p in kPuzzlesCatalog) {
      if (p.goal != PuzzleGoal.mateInOne) continue;
      test(p.id, () {
        expect(p.solutionUci, hasLength(1));
        final g = ch.Chess.fromFEN(p.fen, check_validity: false);
        final m = moveFromUci(g, p.solutionUci.single);
        expect(m, isNotNull, reason: p.id);
        expect(g.move(m!), isTrue);
        expect(
          g.in_checkmate,
          isTrue,
          reason: '${p.id}: ${p.solutionUci.single} sonrası mat olmalı',
        );
      });
    }
  });

  group('Taktik / malzeme hedefi', () {
    for (final p in kPuzzlesCatalog) {
      if (p.goal != PuzzleGoal.tacticWin) continue;
      test('${p.id} çözüm yasal ve hedef taş gider', () {
        final g0 = ch.Chess.fromFEN(p.fen, check_validity: false);
        final qBlackBefore = _countType(g0, ch.PieceType.QUEEN, ch.Color.BLACK);
        final m = moveFromUci(g0, p.solutionUci.single);
        expect(m, isNotNull);
        expect(g0.move(m!), isTrue);
        expect(g0.in_check, isTrue);
        final qBlackAfter = _countType(g0, ch.PieceType.QUEEN, ch.Color.BLACK);
        expect(qBlackAfter, qBlackBefore - 1);
      });
    }
  });
}

int _countType(ch.Chess g, ch.PieceType t, ch.Color c) {
  var n = 0;
  for (var file = 0; file < 8; file++) {
    for (var rank = 1; rank <= 8; rank++) {
      final sq = '${'abcdefgh'[file]}$rank';
      final piece = g.get(sq);
      if (piece != null && piece.type == t && piece.color == c) n++;
    }
  }
  return n;
}
