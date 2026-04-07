import 'package:chess/chess.dart' as ch;

import 'learning_hint.dart';

/// Tehdit ve malzeme ile ilgili kısa ipuçları (motor gerekmez).
class TeachingThreats {
  TeachingThreats._();

  static int? _sqInt(String algebraic) {
    final v = ch.Chess.SQUARES[algebraic];
    if (v == null) return null;
    return v as int;
  }

  /// Son hamleyle gidilen karede taş korunmuyor ve rakip o kareye vurabiliyorsa.
  static LearningHint? undefendedLandingHint(
    ch.Chess game,
    ch.Move last,
  ) {
    if (last.piece == ch.PieceType.KING) return null;

    final us = ch.Chess.swap_color(game.turn);
    final them = game.turn;
    final to = last.toAlgebraic;
    final sq = _sqInt(to);
    if (sq == null) return null;

    if (!game.attacked(them, sq)) return null;
    if (game.attacked(us, sq)) return null;

    return const LearningHint(
      sentence1:
          'Bu karede taşınız rakip tarafından tehdit ediliyor ve yeterince korunmuyor.',
      sentence2:
          'Korunmayan taşlar kolayca kaybedilir; güvenli kare ve tuzaklara dikkat edin.',
      category: HintCategory.threat,
      evalFeedback: MoveEvalFeedback.risky,
    );
  }

  static LearningHint? captureHint(ch.Move last) {
    if (last.captured == null) return null;
    final n = _pieceNameTr(last.captured!);
    return LearningHint(
      sentence1:
          'Rakibin $n\'unu aldınız; malzeme çoğu zaman avantajdır.',
      sentence2:
          'Alımın ardından kendi şah güvenliğinizi ve yeni tehditleri kontrol edin.',
      category: HintCategory.capture,
      evalFeedback: MoveEvalFeedback.good,
    );
  }

  static String _pieceNameTr(ch.PieceType t) {
    if (t == ch.PieceType.PAWN) return 'piyon';
    if (t == ch.PieceType.KNIGHT) return 'at';
    if (t == ch.PieceType.BISHOP) return 'fil';
    if (t == ch.PieceType.ROOK) return 'kale';
    if (t == ch.PieceType.QUEEN) return 'vezir';
    if (t == ch.PieceType.KING) return 'şah';
    return 'taş';
  }
}
