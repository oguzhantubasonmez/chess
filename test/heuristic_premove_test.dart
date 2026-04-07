import 'package:chess/chess.dart' as ch;
import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/coach/heuristic_premove.dart';
import 'package:satranc_2d/features/coach/move_quality.dart';

void main() {
  test('Heuristik: piyon alımı yeşil', () {
    final g = ch.Chess();
    expect(g.move({'from': 'e2', 'to': 'e4'}), isTrue);
    expect(g.move({'from': 'd7', 'to': 'd5'}), isTrue);
    final legals = g.moves({'square': 'e4', 'legal': true, 'asObjects': true});
    final m = heuristicDestinationQuality(
      game: g,
      fromSquare: 'e4',
      legalFromPiece: List<ch.Move>.from(legals),
    );
    expect(m['d5'], MoveQuality.good);
  });
}
