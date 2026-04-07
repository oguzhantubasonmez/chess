import 'package:chess/chess.dart' as ch;
import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/game/uci_move_codec.dart';

String uci(ch.Move m) =>
    '${m.fromAlgebraic}${m.toAlgebraic}${m.promotion?.name ?? ''}';

List<String> matesFor(String fen) {
  final g = ch.Chess.fromFEN(fen, check_validity: false);
  final mates = <String>[];
  for (final m in g.moves({'asObjects': true, 'legal': true})) {
    final g2 = ch.Chess.fromFEN(fen, check_validity: false);
    g2.move(m);
    if (g2.in_checkmate) mates.add(uci(m));
  }
  return mates;
}

void main() {
  test('rook b1 back rank unique in position', () {
    const fen = '6k1/5ppp/8/8/8/8/5PPP/1R4K1 w - - 0 1';
    expect(matesFor(fen), ['b1b8']);
  });

  test('rook a1 back rank (catalog twin)', () {
    const fen = '6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1';
    expect(matesFor(fen), ['a1a8']);
  });

  test('queen d1d8 back rank', () {
    const fen = '6k1/5ppp/8/8/8/8/5PPP/3Q2K1 w - - 0 1';
    expect(matesFor(fen), contains('d1d8'));
  });

  test('queen takes queen with check (g4d7)', () {
    const fen = '4k3/3q4/8/8/6Q1/8/8/4K3 w - - 0 1';
    final g = ch.Chess.fromFEN(fen, check_validity: false);
    final m = moveFromUci(g, 'g4d7');
    expect(m, isNotNull);
    expect(g.move(m!), isTrue);
    expect(g.turn, ch.Color.BLACK);
    expect(g.in_check, isTrue);
    expect(_queenCount(g, ch.Color.BLACK), 0);
  });
}

int _queenCount(ch.Chess g, ch.Color c) {
  var n = 0;
  for (var file = 0; file < 8; file++) {
    for (var rank = 1; rank <= 8; rank++) {
      final sq = '${'abcdefgh'[file]}$rank';
      final piece = g.get(sq);
      if (piece != null &&
          piece.type == ch.PieceType.QUEEN &&
          piece.color == c) {
        n++;
      }
    }
  }
  return n;
}
