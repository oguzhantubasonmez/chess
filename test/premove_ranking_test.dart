import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/coach/move_quality.dart';
import 'package:satranc_2d/features/coach/premove_ranking.dart';
import 'package:satranc_2d/features/engine/uci_multipv_parser.dart';

void main() {
  test('e2 kökünde iyi ve zayıf hedefler', () {
    final lines = [
      UciMultipvLine(multipvIndex: 1, scoreCp: 100, firstUci: 'e2e4'),
      UciMultipvLine(multipvIndex: 2, scoreCp: 40, firstUci: 'e2e3'),
      UciMultipvLine(multipvIndex: 3, scoreCp: -50, firstUci: 'e2f1'),
    ];
    final m = rankDestinationsFromMultipv(
      fromSquare: 'e2',
      legalUcisFromPiece: ['e2e4', 'e2e3', 'e2f1'],
      engineLines: lines,
      badCpBelowBest: 90,
      goodCpWithinBest: 60,
      maxGoodMoves: 3,
    );
    expect(m['e4'], MoveQuality.good);
    expect(m['e3'], MoveQuality.good);
    expect(m['f1'], MoveQuality.bad);
  });
}
