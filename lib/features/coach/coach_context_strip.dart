import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';

import '../../core/app_motion.dart';
import '../board/board_controller.dart';
import '../game/game_mode.dart';
import 'move_quality.dart';
import 'premove_coach_controller.dart';

/// Step 4: Hamle öncesi seçim bağlamı — tahtadaki koç renkleriyle senkron açıklama.
class CoachContextStrip extends StatelessWidget {
  const CoachContextStrip({
    super.key,
    required this.board,
    required this.coach,
    required this.engineAvailable,
    required this.mode,
  });

  final BoardController board;
  final PremoveCoachController coach;
  final bool engineAvailable;
  final GameMode mode;

  bool _shouldShow() {
    if (board.game.game_over) return false;
    final sel = board.selectedSquare;
    if (sel == null) return false;
    final piece = board.game.get(sel);
    if (piece == null || piece.color != board.turn) return false;
    if (mode == GameMode.vsAi && board.turn != ch.Color.WHITE) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow()) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final by = coach.qualityByDestination;
    var good = 0, neutral = 0, bad = 0;
    for (final q in by.values) {
      if (q == MoveQuality.good) {
        good++;
      } else if (q == MoveQuality.neutral) {
        neutral++;
      } else if (q == MoveQuality.bad) {
        bad++;
      }
    }

    final sel = board.selectedSquare!;
    final piece = board.game.get(sel)!;
    final pieceTr = _pieceLabel(piece.type);

    return AnimatedSwitcher(
      duration: AppMotion.coachStripSwitch,
      switchInCurve: AppMotion.panelCurveIn,
      switchOutCurve: AppMotion.panelCurveOut,
      child: Padding(
        key: ValueKey<String>(sel),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      size: 22,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '$sel · $pieceTr',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (mode == GameMode.learning)
                                Chip(
                                  label: const Text('Öğrenme modu'),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  labelStyle: const TextStyle(fontSize: 11),
                                  backgroundColor: scheme.primaryContainer
                                      .withValues(alpha: 0.6),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mode == GameMode.learning
                                ? 'Hamle yapmadan önce hedef kareleri inceleyin. Aşağıdaki renkler, bu taş için öneri yoğunluğunu gösterir.'
                                : 'Seçili taş için hedef karelerdeki renk ve noktalar hamle önerisini gösterir.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const _LegendRow(),
                if (by.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$good iyi · $neutral nötr · $bad riskli hedef',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'Hedef renkleri hesaplanıyor…',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
                if (!engineAvailable)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Bu ortamda Stockfish yok; yeşil/kırmızı tonları sezgisel kurala göre.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.outline,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _pieceLabel(ch.PieceType t) {
    if (t == ch.PieceType.PAWN) return 'Piyon';
    if (t == ch.PieceType.KNIGHT) return 'At';
    if (t == ch.PieceType.BISHOP) return 'Fil';
    if (t == ch.PieceType.ROOK) return 'Kale';
    if (t == ch.PieceType.QUEEN) return 'Vezir';
    if (t == ch.PieceType.KING) return 'Şah';
    return 'Taş';
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _LegendDot(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.85),
          label: 'İyi / önerilen',
        ),
        _LegendDot(
          color: const Color(0xFFC9A227).withValues(alpha: 0.9),
          label: 'Nötr',
        ),
        _LegendDot(
          color: const Color(0xFFB71C1C).withValues(alpha: 0.9),
          label: 'Riskli',
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
