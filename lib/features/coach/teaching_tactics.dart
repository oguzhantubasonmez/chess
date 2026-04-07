import 'package:chess/chess.dart' as ch;

import 'learning_hint.dart';

/// Tahta üzerinde basit taktik / konsept ipuçları.
class TeachingTactics {
  TeachingTactics._();

  static const _centerSquares = {
    'd4',
    'e4',
    'd5',
    'e5',
    'c4',
    'c5',
    'f4',
    'f5',
  };

  static List<ch.Move> _legalMovesFromSquareForColor(
    ch.Chess postMove,
    String square,
    ch.Color pieceOwner,
  ) {
    final parts = postMove.fen.split(RegExp(r'\s+'));
    if (parts.length < 2) return [];
    parts[1] = pieceOwner == ch.Color.WHITE ? 'w' : 'b';
    final fen = parts.join(' ');
    final alt = ch.Chess.fromFEN(fen, check_validity: false);
    final raw = alt.moves({
      'square': square,
      'legal': true,
      'asObjects': true,
    });
    return List<ch.Move>.from(raw);
  }

  static bool _isCastle(ch.Move m) {
    return (m.flags & ch.Chess.BITS_KSIDE_CASTLE) != 0 ||
        (m.flags & ch.Chess.BITS_QSIDE_CASTLE) != 0;
  }

  static LearningHint? hintForLastMove({
    required ch.Chess game,
    required ch.Move? last,
  }) {
    if (last == null) {
      if (game.in_check && !game.in_checkmate) {
        return const LearningHint(
          sentence1: 'Bu pozisyonda sıradaki oyuncu şah altında.',
          sentence2: 'Çıkış yolu bulmak zorundadır; yoksa mat olur.',
          category: HintCategory.general,
        );
      }
      return null;
    }
    final mover = ch.Chess.swap_color(game.turn);

    if (_isCastle(last)) {
      return const LearningHint(
        sentence1: 'Rok, şahınızı köşeye alıp güvenliği artırır.',
        sentence2: 'Hafif taşları geliştirdikten sonra rok genelde iyidir.',
        category: HintCategory.special,
        evalFeedback: MoveEvalFeedback.good,
      );
    }

    if ((last.flags & ch.Chess.BITS_EP_CAPTURE) != 0) {
      return const LearningHint(
        sentence1:
            'Geçerken alma: rakibin çift ilerleyen piyonunu bu özel kural ile aldınız.',
        sentence2:
            'Yalnızca hamleden hemen sonra mümkündür; fırsatı kaçırmamaya dikkat edin.',
        category: HintCategory.special,
        evalFeedback: MoveEvalFeedback.good,
      );
    }

    if ((last.flags & ch.Chess.BITS_PROMOTION) != 0) {
      return const LearningHint(
        sentence1:
            'Piyon son sıraya ulaştı; terfi genelde en güçlü taş olan vezire yapılır.',
        sentence2: 'Bazen at veya fil, mat veya tuzak için daha doğru olabilir.',
        category: HintCategory.special,
      );
    }

    if (game.in_check && !game.in_checkmate) {
      return const LearningHint(
        sentence1: 'Şah çekildi; sıradaki oyuncu yasal bir kaçış bulmalı.',
        sentence2: 'Şah, rakibin düzenini bozmak için sık kullanılır.',
        category: HintCategory.tactic,
        evalFeedback: MoveEvalFeedback.good,
      );
    }

    final moves = _legalMovesFromSquareForColor(game, last.toAlgebraic, mover);
    final captureCount = moves.where((m) => m.captured != null).length;
    if (captureCount >= 2) {
      return const LearningHint(
        sentence1:
            'Çatal: tek taşınızla birden çok rakip taşını aynı anda tehdit ediyorsunuz.',
        sentence2: 'Rakip genelde hepsini birden kurtaramaz.',
        category: HintCategory.tactic,
        tacticKind: TacticKind.fork,
        evalFeedback: MoveEvalFeedback.good,
      );
    }

    if (game.in_checkmate) return null;

    final ply = _approxPly(game);
    if (ply < 10) {
      if (last.piece == ch.PieceType.QUEEN) {
        if (mover == ch.Color.WHITE && last.fromAlgebraic == 'd1') {
          return const LearningHint(
            sentence1:
                'Veziri çok erken çıkarmak bazen şah güvenliğini zayıflatır.',
            sentence2: 'Önce at ve fil geliştirmek genelde daha güvenlidir.',
            category: HintCategory.development,
          );
        }
        if (mover == ch.Color.BLACK && last.fromAlgebraic == 'd8') {
          return const LearningHint(
            sentence1: 'Veziri erken oynamak şah tarafını açık bırakabilir.',
            sentence2: 'Önce hafif taşları oyuna sokmayı düşünün.',
            category: HintCategory.development,
          );
        }
      }
      if (last.piece == ch.PieceType.KNIGHT ||
          last.piece == ch.PieceType.BISHOP) {
        final homeRank = mover == ch.Color.WHITE ? '1' : '8';
        if (last.fromAlgebraic.length == 2 &&
            last.fromAlgebraic[1] == homeRank) {
          return const LearningHint(
            sentence1:
                'Hafif taş geliştirmesi merkezi ve şah güvenliğine yardım eder.',
            sentence2: 'Her iki tarafı da zamanında oynamak iyidir.',
            category: HintCategory.development,
            evalFeedback: MoveEvalFeedback.good,
          );
        }
      }
    }

    if (last.piece == ch.PieceType.PAWN &&
        _centerSquares.contains(last.toAlgebraic)) {
      return const LearningHint(
        sentence1: 'Merkezdeki piyonlar alanı ve hamle seçeneklerini kontrol eder.',
        sentence2: 'Merkez, orta oyunda güç toplamak için önemlidir.',
        category: HintCategory.development,
        evalFeedback: MoveEvalFeedback.instructive,
      );
    }

    return null;
  }

  static int _approxPly(ch.Chess g) {
    return g.history.length;
  }

  /// Çatal diyagramı: taşın bulunduğu kareden tehdit edilen alım kareleri (en fazla 2).
  static List<String> forkTargetSquares(ch.Chess game, ch.Move last) {
    final mover = ch.Chess.swap_color(game.turn);
    final moves = _legalMovesFromSquareForColor(game, last.toAlgebraic, mover);
    return moves
        .where((m) => m.captured != null)
        .map((m) => m.toAlgebraic)
        .toSet()
        .take(2)
        .toList();
  }
}
