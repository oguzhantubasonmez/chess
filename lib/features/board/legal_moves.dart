import 'package:chess/chess.dart' as ch;

/// `chess.dart` üzerinden yasal hamle sorguları — tüm kurallar kütüphanede (rok, geçerken alma, terfi, şah).
class LegalMoves {
  LegalMoves._();

  static List<ch.Move> forSquare(ch.Chess game, String square) {
    return List<ch.Move>.from(
      game.moves({
        'square': square,
        'legal': true,
        'asObjects': true,
      }),
    );
  }

  /// Hamlenin o anda yasal olup olmadığını doğrular (pozisyon değişmeden).
  static bool isLegalMove(ch.Chess game, ch.Move move) {
    final legals = List<ch.Move>.from(
      game.moves({'legal': true, 'asObjects': true}),
    );
    for (final mv in legals) {
      if (mv.from == move.from &&
          mv.to == move.to &&
          mv.promotion == move.promotion) {
        return true;
      }
    }
    return false;
  }

  static bool loadFen(ch.Chess game, String fen, {bool checkValidity = true}) {
    return game.load(fen, check_validity: checkValidity);
  }
}
