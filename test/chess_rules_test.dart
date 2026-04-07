import 'package:chess/chess.dart' as ch;
import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/board/legal_moves.dart';

void main() {
  group('Yasal hamleler (chess.dart)', () {
    test('beyaz kısa rok', () {
      final g = ch.Chess.fromFEN(
        'r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1',
      );
      expect(
        g.move(<String, String>{'from': 'e1', 'to': 'g1'}),
        isTrue,
      );
      expect(g.get('g1')?.type, ch.PieceType.KING);
      expect(g.get('f1')?.type, ch.PieceType.ROOK);
    });

    test('geçerken alma', () {
      final g = ch.Chess();
      expect(g.move('e4'), isTrue);
      expect(g.move('d5'), isTrue);
      expect(g.move('e5'), isTrue);
      expect(g.move('f5'), isTrue);
      expect(g.move('exf6'), isTrue);
      expect(g.get('f5'), isNull);
    });

    test('piyon terfisi (vezir)', () {
      final g = ch.Chess.fromFEN('8/4P3/8/8/8/8/8/4K2k w - - 0 1');
      expect(
        g.move(<String, String>{
          'from': 'e7',
          'to': 'e8',
          'promotion': 'q',
        }),
        isTrue,
      );
      expect(g.get('e8')?.type, ch.PieceType.QUEEN);
    });

    test('şah mat (paket test FEN)', () {
      final g = ch.Chess.fromFEN('8/5r2/4K1q1/4p3/3k4/8/8/8 w - - 0 7');
      expect(g.in_checkmate, isTrue);
    });

    test('pat (paket test FEN)', () {
      final g = ch.Chess.fromFEN('1R6/8/8/8/8/8/7R/k6K b - - 0 1');
      expect(g.in_stalemate, isTrue);
    });

    test('LegalMoves.isLegalMove tutarlı', () {
      final g = ch.Chess();
      final e2Moves = LegalMoves.forSquare(g, 'e2');
      final e4 = e2Moves.firstWhere((m) => m.toAlgebraic == 'e4');
      expect(LegalMoves.isLegalMove(g, e4), isTrue);
    });

    test('Geçersiz FEN yüklenemez', () {
      final g = ch.Chess();
      expect(LegalMoves.loadFen(g, 'not-a-fen'), isFalse);
    });
  });
}
