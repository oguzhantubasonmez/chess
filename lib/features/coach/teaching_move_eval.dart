import 'package:chess/chess.dart' as ch;

import 'learning_hint.dart';
import 'teaching_threats.dart';

/// Hamle sonrası kural tabanlı kısa değerlendirme (motor zorunlu değil).
class TeachingMoveEval {
  TeachingMoveEval._();

  static MoveEvalFeedback feedback(ch.Chess gameAfter, ch.Move? last) {
    if (last == null) return MoveEvalFeedback.none;
    if (gameAfter.in_checkmate) return MoveEvalFeedback.excellent;

    if (TeachingThreats.undefendedLandingHint(gameAfter, last) != null) {
      return MoveEvalFeedback.risky;
    }

    if (last.captured == ch.PieceType.QUEEN) {
      return MoveEvalFeedback.excellent;
    }
    if (last.captured == ch.PieceType.ROOK) {
      return MoveEvalFeedback.good;
    }
    if (last.captured != null) {
      return MoveEvalFeedback.good;
    }
    if (gameAfter.in_check) {
      return MoveEvalFeedback.good;
    }
    return MoveEvalFeedback.none;
  }

  /// Başka ipucu yokken yalnızca değerlendirme metni (kısa).
  static LearningHint? hintIfStandalone(MoveEvalFeedback ev) {
    switch (ev) {
      case MoveEvalFeedback.none:
      case MoveEvalFeedback.instructive:
        return null;
      case MoveEvalFeedback.excellent:
        return const LearningHint(
          sentence1: 'Güçlü bir hamle — ciddi baskı veya malzeme kazancı.',
          category: HintCategory.general,
          evalFeedback: MoveEvalFeedback.excellent,
        );
      case MoveEvalFeedback.good:
        return const LearningHint(
          sentence1: 'Sağlam tempo: alım veya şah ile pozisyonu canlı tuttunuz.',
          category: HintCategory.general,
          evalFeedback: MoveEvalFeedback.good,
        );
      case MoveEvalFeedback.risky:
        return const LearningHint(
          sentence1: 'Dikkat: taşınız zayıf bir karede veya kolay hedef olabilir.',
          sentence2: 'Rakibin tehditlerini bir sonraki hamlede kontrol edin.',
          category: HintCategory.threat,
          evalFeedback: MoveEvalFeedback.risky,
        );
    }
  }
}
