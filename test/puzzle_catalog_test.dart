import 'package:chess/chess.dart' as ch;
import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/game/uci_move_codec.dart';
import 'package:satranc_2d/features/puzzle/puzzles_catalog.dart';

void main() {
  for (final p in kPuzzlesCatalog) {
    test('Bulmaca çözümü yasal: ${p.id}', () {
      final g = ch.Chess.fromFEN(p.fen, check_validity: false);
      expect(g.fen, isNotEmpty);
      for (var i = 0; i < p.solutionUci.length; i++) {
        final uci = p.solutionUci[i];
        final m = moveFromUci(g, uci);
        expect(m, isNotNull, reason: '$uci yasal değil (adım $i, ${p.id})');
        expect(g.move(m!), isTrue, reason: 'Hamle uygulanamadı $uci');
      }
    });
  }
}
