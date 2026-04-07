import 'package:chess/chess.dart' as ch;

import 'hint_diagram.dart';
import 'learning_hint.dart';
import 'learning_level.dart';
import 'teaching_move_eval.dart';
import 'teaching_openings.dart';
import 'teaching_tactics.dart';
import 'teaching_threats.dart';

/// Kural tabanlı gerçek zamanlı öğretim; seviye ve hamle değerlendirmesi modüler.
class TeachingEngine {
  TeachingEngine._();

  static const int _maxOpeningPlies = 8;

  static LearningHint? analyze({
    required ch.Chess game,
    required List<String> uciHistory,
    required ch.Move? lastMove,
    LearningLevel level = LearningLevel.beginner,
  }) {
    if (game.in_checkmate || game.in_stalemate) {
      return null;
    }

    final postEval = TeachingMoveEval.feedback(game, lastMove);

    LearningHint? primary;

    if (lastMove != null) {
      final hanging = TeachingThreats.undefendedLandingHint(game, lastMove);
      if (hanging != null) primary = hanging;
    }

    primary ??= TeachingTactics.hintForLastMove(game: game, last: lastMove);

    if (primary == null && lastMove != null) {
      final cap = TeachingThreats.captureHint(lastMove);
      if (cap != null) primary = cap;
    }

    if (primary == null &&
        uciHistory.length >= 2 &&
        uciHistory.length <= _maxOpeningPlies) {
      final opening = TeachingOpenings.bestMatch(uciHistory);
      if (opening != null) {
        final exact = uciHistory.length == opening.pattern.length;
        primary = LearningHint(
          headline: opening.name,
          sentence1: exact
              ? 'Bilinen bir açılış hattına uyuyorsunuz.'
              : 'Hamleniz yaygın açılış teorisine uygun.',
          sentence2: _openingPurpose(opening.name, level),
          sentence3: level == LearningLevel.beginner
              ? 'Açılışta amaç: güvenli şah, hafif taşları oyuna sokmak ve merkeze nüfuz.'
              : null,
          category: HintCategory.opening,
          evalFeedback: MoveEvalFeedback.instructive,
        );
      }
    }

    if (primary == null) {
      primary = TeachingMoveEval.hintIfStandalone(postEval);
    } else {
      primary = _mergeEval(primary, postEval);
    }

    if (primary == null) return null;
    primary = _enrichDiagram(primary, game, lastMove);
    return _applyLevel(primary, level);
  }

  static String? _openingPurpose(String name, LearningLevel level) {
    if (level == LearningLevel.advanced) return null;
    if (name.contains('gambit')) {
      return 'Gambitte geçici piyon fedası ile gelişim veya merkez karşılığı alınır.';
    }
    if (name.contains('savunma') || name.contains('Savunma')) {
      return 'Siyah yapısı sağlam kalır; beyaz merkezi sorgular.';
    }
    return 'Tipik gelişim hatlarından biri; merkez ve şah güvenliğini gözetin.';
  }

  static bool _wantsMiniBoard(LearningHint h, ch.Chess game, ch.Move? last) {
    if (h.category == HintCategory.opening) return true;
    if (h.tacticKind == TacticKind.fork) return true;
    if (h.category == HintCategory.threat) return true;
    if (h.category == HintCategory.capture) return true;
    if (h.category == HintCategory.development) return true;
    if (h.category == HintCategory.special) return true;
    if (h.category == HintCategory.tactic &&
        h.tacticKind == TacticKind.none &&
        last != null &&
        game.in_check &&
        !game.in_checkmate) {
      return true;
    }
    if (h.category == HintCategory.general &&
        last != null &&
        (h.evalFeedback == MoveEvalFeedback.excellent ||
            h.evalFeedback == MoveEvalFeedback.good)) {
      return true;
    }
    return false;
  }

  static String? _kingSquare(ch.Chess g, ch.Color color) {
    for (var file = 0; file < 8; file++) {
      for (var rank = 1; rank <= 8; rank++) {
        final sq = '${'abcdefgh'[file]}$rank';
        final p = g.get(sq);
        if (p != null &&
            p.type == ch.PieceType.KING &&
            p.color == color) {
          return sq;
        }
      }
    }
    return null;
  }

  static LearningHint _enrichDiagram(
    LearningHint h,
    ch.Chess game,
    ch.Move? last,
  ) {
    if (!_wantsMiniBoard(h, game, last)) return h;

    final fen = game.fen;
    final arrows = <HintArrow>[];
    final highs = <String>{};

    if (last != null) {
      if (h.tacticKind == TacticKind.fork) {
        highs.add(last.toAlgebraic);
        for (final t in TeachingTactics.forkTargetSquares(game, last)) {
          arrows.add(HintArrow(from: last.toAlgebraic, to: t));
          highs.add(t);
        }
      } else if (h.category == HintCategory.threat) {
        highs.add(last.toAlgebraic);
        arrows.add(HintArrow(
          from: last.fromAlgebraic,
          to: last.toAlgebraic,
          isWarning: true,
        ));
      } else if (h.category == HintCategory.capture &&
          h.tacticKind != TacticKind.fork) {
        arrows.add(HintArrow(from: last.fromAlgebraic, to: last.toAlgebraic));
        highs.add(last.fromAlgebraic);
        highs.add(last.toAlgebraic);
      } else if (h.category == HintCategory.special ||
          h.category == HintCategory.development) {
        arrows.add(HintArrow(from: last.fromAlgebraic, to: last.toAlgebraic));
        highs.add(last.fromAlgebraic);
        highs.add(last.toAlgebraic);
      } else if (h.category == HintCategory.tactic &&
          h.tacticKind == TacticKind.none &&
          game.in_check &&
          !game.in_checkmate) {
        final ksq = _kingSquare(game, game.turn);
        if (ksq != null) {
          arrows.add(HintArrow(from: last.toAlgebraic, to: ksq));
          highs.add(last.toAlgebraic);
          highs.add(ksq);
        }
      } else if (h.category == HintCategory.opening) {
        arrows.add(HintArrow(from: last.fromAlgebraic, to: last.toAlgebraic));
        highs.add(last.fromAlgebraic);
        highs.add(last.toAlgebraic);
      } else if (h.category == HintCategory.general &&
          (h.evalFeedback == MoveEvalFeedback.excellent ||
              h.evalFeedback == MoveEvalFeedback.good)) {
        arrows.add(HintArrow(from: last.fromAlgebraic, to: last.toAlgebraic));
        highs.add(last.fromAlgebraic);
        highs.add(last.toAlgebraic);
      }
    }

    return _hintWithDiagram(h, fen, arrows, highs);
  }

  static LearningHint _hintWithDiagram(
    LearningHint h,
    String fen,
    List<HintArrow> arrows,
    Set<String> highs,
  ) {
    final sorted = highs.toList()..sort();
    return LearningHint(
      sentence1: h.sentence1,
      sentence2: h.sentence2,
      sentence3: h.sentence3,
      headline: h.headline,
      category: h.category,
      tacticKind: h.tacticKind,
      evalFeedback: h.evalFeedback,
      diagramFen: fen,
      diagramArrows: List<HintArrow>.from(arrows),
      diagramHighlights: sorted,
    );
  }

  static LearningHint _mergeEval(LearningHint base, MoveEvalFeedback ev) {
    if (ev == MoveEvalFeedback.none) return base;
    if (base.evalFeedback == MoveEvalFeedback.risky ||
        base.evalFeedback == MoveEvalFeedback.excellent) {
      return base;
    }
    return LearningHint(
      sentence1: base.sentence1,
      sentence2: base.sentence2,
      sentence3: base.sentence3,
      headline: base.headline,
      category: base.category,
      tacticKind: base.tacticKind,
      evalFeedback: _stronger(base.evalFeedback, ev),
      diagramFen: base.diagramFen,
      diagramArrows: base.diagramArrows,
      diagramHighlights: base.diagramHighlights,
    );
  }

  static int _evalRank(MoveEvalFeedback e) {
    switch (e) {
      case MoveEvalFeedback.none:
        return 0;
      case MoveEvalFeedback.instructive:
        return 1;
      case MoveEvalFeedback.good:
        return 2;
      case MoveEvalFeedback.excellent:
        return 3;
      case MoveEvalFeedback.risky:
        return 4;
    }
  }

  static MoveEvalFeedback _stronger(MoveEvalFeedback a, MoveEvalFeedback b) {
    if (a == MoveEvalFeedback.risky || b == MoveEvalFeedback.risky) {
      return MoveEvalFeedback.risky;
    }
    return _evalRank(b) > _evalRank(a) ? b : a;
  }

  static LearningHint _applyLevel(LearningHint h, LearningLevel level) {
    switch (level) {
      case LearningLevel.beginner:
        return h;
      case LearningLevel.intermediate:
        return LearningHint(
          sentence1: h.sentence1,
          sentence2: h.sentence2,
          sentence3: null,
          headline: h.headline,
          category: h.category,
          tacticKind: h.tacticKind,
          evalFeedback: h.evalFeedback,
          diagramFen: h.diagramFen,
          diagramArrows: h.diagramArrows,
          diagramHighlights: h.diagramHighlights,
        );
      case LearningLevel.advanced:
        return LearningHint(
          sentence1: h.headline != null
              ? '${h.headline}: ${h.sentence1}'
              : h.sentence1,
          sentence2: null,
          sentence3: null,
          headline: null,
          category: h.category,
          tacticKind: h.tacticKind,
          evalFeedback: h.evalFeedback,
          diagramFen: h.diagramFen,
          diagramArrows: h.diagramArrows,
          diagramHighlights: h.diagramHighlights,
        );
    }
  }
}
