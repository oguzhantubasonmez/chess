import 'dart:math' as math;

import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_motion.dart';
import '../coach/move_quality.dart';
import 'board_controller.dart';
import 'board_palette.dart';

/// Satranç tahtası: gradyan kareler, premove nabız/sallanma, son hamle iniş animasyonu.
class ChessBoardView extends StatefulWidget {
  const ChessBoardView({
    super.key,
    required this.controller,
    this.coachByTo = const {},
    this.palette = BoardPalette.classic,
    this.onSquareTapOverride,
    this.onSquareLongPressOverride,
    this.materialElevation = 10,
    this.maxBoardSide = 560,
  });

  final BoardController controller;
  final Map<String, MoveQuality> coachByTo;
  final BoardPalette palette;

  final Future<void> Function(String square)? onSquareTapOverride;

  final void Function(String square)? onSquareLongPressOverride;

  /// [Material] gölge derinliği (tema ile uyum).
  final double materialElevation;

  /// Tahta kare kenarı üst sınırı (geniş ekranda biraz büyütülebilir).
  final double maxBoardSide;

  static String unicodeFor(ch.PieceType type, ch.Color color) =>
      _unicodePieces[(type, color)]!;

  static final _unicodePieces = <(ch.PieceType, ch.Color), String>{
    (ch.PieceType.PAWN, ch.Color.WHITE): '\u2659',
    (ch.PieceType.KNIGHT, ch.Color.WHITE): '\u2658',
    (ch.PieceType.BISHOP, ch.Color.WHITE): '\u2657',
    (ch.PieceType.ROOK, ch.Color.WHITE): '\u2656',
    (ch.PieceType.QUEEN, ch.Color.WHITE): '\u2655',
    (ch.PieceType.KING, ch.Color.WHITE): '\u2654',
    (ch.PieceType.PAWN, ch.Color.BLACK): '\u265F',
    (ch.PieceType.KNIGHT, ch.Color.BLACK): '\u265E',
    (ch.PieceType.BISHOP, ch.Color.BLACK): '\u265D',
    (ch.PieceType.ROOK, ch.Color.BLACK): '\u265C',
    (ch.PieceType.QUEEN, ch.Color.BLACK): '\u265B',
    (ch.PieceType.KING, ch.Color.BLACK): '\u265A',
  };

  @override
  State<ChessBoardView> createState() => _ChessBoardViewState();
}

class _ChessBoardViewState extends State<ChessBoardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _syncPulse();
  }

  void _syncPulse() {
    final need = widget.coachByTo.isNotEmpty &&
        widget.controller.selectedSquare != null;
    if (need) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void didUpdateWidget(ChessBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coachByTo != widget.coachByTo ||
        oldWidget.controller.selectedSquare != widget.controller.selectedSquare) {
      _syncPulse();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// Telefon / tablet: tahta boyutunu sınırla (gelistirme Step 2 — ölçek).
  static double _boardSide(BoxConstraints c, double maxSide) {
    final raw = c.biggest.shortestSide * 0.92;
    return raw.clamp(240.0, maxSide);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.controller.game;
    final shadow = Theme.of(context).brightness == Brightness.dark
        ? Colors.black54
        : Colors.black26;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _boardSide(constraints, widget.maxBoardSide);
        final cell = side / 8;
        return Center(
          child: Material(
            elevation: widget.materialElevation,
            shadowColor: shadow,
            borderRadius: BorderRadius.circular(12),
            color: widget.palette.darkSquare,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: side,
                height: side,
                child: ColoredBox(
                  color: widget.palette.darkSquare,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      return Column(
                        children: List.generate(8, (row) {
                          return Expanded(
                            child: Row(
                              children: List.generate(8, (file) {
                                final name =
                                    BoardController.squareAt(file, row);
                                final isLight = (file + row) % 2 == 0;
                                final piece = g.get(name);
                                final isSelected =
                                    widget.controller.selectedSquare == name;
                                final isLast = name ==
                                        widget.controller.lastMoveFrom ||
                                    name == widget.controller.lastMoveTo;
                                final isLegalTarget = widget
                                    .controller.legalMovesForSelection
                                    .any((m) => m.toAlgebraic == name);
                                final coachQ = widget.coachByTo[name];

                                return Expanded(
                                  child: _SquareCell(
                                    size: cell,
                                    isLight: isLight,
                                    palette: widget.palette,
                                    isSelected: isSelected,
                                    isLastMove: isLast,
                                    coachQuality: coachQ,
                                    showLegalDot:
                                        isLegalTarget && !isSelected,
                                    hasPiece: piece != null,
                                    pulseT: _pulse.value,
                                    isLastMoveTo:
                                        name == widget.controller.lastMoveTo,
                                    onTap: () {
                                      final o = widget.onSquareTapOverride;
                                      if (o != null) {
                                        o(name);
                                      } else {
                                        widget.controller.onSquareTapped(name);
                                      }
                                    },
                                    onLongPress: () {
                                      final pieceHere = g.get(name);
                                      if (pieceHere == null ||
                                          pieceHere.color != g.turn) {
                                        return;
                                      }
                                      HapticFeedback.lightImpact();
                                      final lo =
                                          widget.onSquareLongPressOverride;
                                      if (lo != null) {
                                        lo(name);
                                      } else {
                                        widget.controller
                                            .selectSquareForCoach(name);
                                      }
                                    },
                                    child: piece == null
                                        ? null
                                        : _PieceGlyph(
                                            piece: piece,
                                            cell: cell,
                                            palette: widget.palette,
                                            isSelected: isSelected,
                                            landPop: name ==
                                                widget.controller.lastMoveTo,
                                            landKey: widget
                                                    .controller.uciHistory
                                                    .isEmpty
                                                ? ''
                                                : widget.controller
                                                    .uciHistory.last,
                                          ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PieceGlyph extends StatelessWidget {
  const _PieceGlyph({
    required this.piece,
    required this.cell,
    required this.palette,
    required this.isSelected,
    required this.landPop,
    required this.landKey,
  });

  final ch.Piece piece;
  final double cell;
  final BoardPalette palette;
  final bool isSelected;
  final bool landPop;
  final String landKey;

  @override
  Widget build(BuildContext context) {
    final glyph = ChessBoardView._unicodePieces[
        (piece.type, piece.color)]!;
    final text = Text(
      glyph,
      style: TextStyle(
        fontSize: cell * 0.62,
        height: 1,
        color: piece.color == ch.Color.WHITE
            ? palette.whitePiece
            : palette.blackPiece,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 2,
          ),
        ],
      ),
    );

    final scaled = AnimatedScale(
      scale: isSelected ? 1.08 : 1.0,
      duration: AppMotion.pieceScale,
      curve: Curves.easeOutBack,
      child: text,
    );

    if (!landPop) return scaled;

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('land-$landKey'),
      tween: Tween(begin: 1.18, end: 1.0),
      duration: AppMotion.landPop,
      curve: AppMotion.boardCurve,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: scaled,
    );
  }
}

class _SquareCell extends StatelessWidget {
  const _SquareCell({
    required this.size,
    required this.isLight,
    required this.palette,
    required this.isSelected,
    required this.isLastMove,
    required this.showLegalDot,
    required this.hasPiece,
    required this.pulseT,
    required this.isLastMoveTo,
    this.coachQuality,
    required this.onTap,
    this.onLongPress,
    this.child,
  });

  final double size;
  final bool isLight;
  final BoardPalette palette;
  final bool isSelected;
  final bool isLastMove;
  final MoveQuality? coachQuality;
  final bool showLegalDot;
  final bool hasPiece;
  final double pulseT;
  final bool isLastMoveTo;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? child;

  LinearGradient _baseGradient() {
    if (isLight) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          palette.lightSquare,
          Color.lerp(palette.lightSquare, palette.darkSquare, 0.18)!,
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        palette.darkSquare,
        Color.lerp(palette.darkSquare, Colors.black, 0.14)!,
      ],
    );
  }

  double _coachPulseAlpha() {
    if (!showLegalDot || coachQuality == null) return 1;
    return 0.72 + 0.28 * (0.5 + 0.5 * math.sin(pulseT * math.pi * 2));
  }

  double _badShakeDx() {
    if (!showLegalDot || coachQuality != MoveQuality.bad) return 0;
    return 2.2 * math.sin(pulseT * math.pi * 4);
  }

  Widget _coachOverlay() {
    if (!showLegalDot || coachQuality == null) {
      return const SizedBox.shrink();
    }
    final a = _coachPulseAlpha();
    Color c;
    switch (coachQuality!) {
      case MoveQuality.good:
        c = palette.goodMoveOverlay.withValues(alpha: palette.goodMoveOverlay.a * a);
        break;
      case MoveQuality.bad:
        c = palette.badMoveOverlay.withValues(alpha: palette.badMoveOverlay.a * a);
        break;
      case MoveQuality.neutral:
        c = palette.neutralMoveOverlay
            .withValues(alpha: palette.neutralMoveOverlay.a * a);
        break;
    }
    return Positioned.fill(
      child: DecoratedBox(decoration: BoxDecoration(color: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_badShakeDx(), 0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: BoxDecoration(gradient: _baseGradient())),
          if (isLastMove)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.lastMoveHighlight
                      .withValues(alpha: isLastMoveTo ? 0.5 : 0.38),
                ),
              ),
            ),
          if (isSelected)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.selectedSquare.withValues(alpha: 0.72),
                ),
              ),
            ),
          _coachOverlay(),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              splashFactory: InkRipple.splashFactory,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (child != null) child!,
                  if (showLegalDot)
                    Container(
                      width: hasPiece ? size * 0.38 : size * 0.22,
                      height: hasPiece ? size * 0.38 : size * 0.22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: hasPiece
                            ? Border.all(
                                color: palette.legalMoveDot,
                                width: size * 0.06,
                              )
                            : null,
                        color: hasPiece ? null : palette.legalMoveDot,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
