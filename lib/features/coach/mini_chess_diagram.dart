import 'dart:math' as math;

import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';

import '../../core/app_motion.dart';
import '../board/board_palette.dart';
import 'hint_diagram.dart';

/// Küçük pozisyon özeti: kareler, taşlar, vurgu ve animasyonlu oklar (Step 3).
class MiniChessDiagram extends StatefulWidget {
  const MiniChessDiagram({
    super.key,
    required this.fen,
    this.arrows = const [],
    this.highlights = const [],
    this.palette = BoardPalette.classic,
    this.size = 120,
  });

  final String fen;
  final List<HintArrow> arrows;
  final List<String> highlights;
  final BoardPalette palette;
  final double size;

  @override
  State<MiniChessDiagram> createState() => _MiniChessDiagramState();
}

class _MiniChessDiagramState extends State<MiniChessDiagram>
    with TickerProviderStateMixin {
  late AnimationController _arrowDraw;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _arrowDraw = AnimationController(
      vsync: this,
      duration: AppMotion.diagramArrowDraw,
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MiniChessDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fen != widget.fen ||
        oldWidget.arrows != widget.arrows ||
        oldWidget.highlights != widget.highlights) {
      _arrowDraw
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _arrowDraw.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_arrowDraw, _pulse]),
        builder: (context, _) {
          return CustomPaint(
            painter: _MiniBoardPainter(
              fen: widget.fen,
              arrows: widget.arrows,
              highlights: widget.highlights,
              palette: widget.palette,
              arrowProgress: Curves.easeOutCubic.transform(_arrowDraw.value),
              highlightPulse: 0.35 + 0.25 * _pulse.value,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

class _MiniBoardPainter extends CustomPainter {
  _MiniBoardPainter({
    required this.fen,
    required this.arrows,
    required this.highlights,
    required this.palette,
    required this.arrowProgress,
    required this.highlightPulse,
  });

  final String fen;
  final List<HintArrow> arrows;
  final List<String> highlights;
  final BoardPalette palette;
  final double arrowProgress;
  final double highlightPulse;

  static final _glyphs = <(ch.PieceType, ch.Color), String>{
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

  Offset _center(String algebraic, Size s) {
    final f = algebraic.codeUnitAt(0) - 97;
    final r = int.parse(algebraic.substring(1)) - 1;
    final rowFromTop = 7 - r;
    final cell = s.width / 8;
    return Offset((f + 0.5) * cell, (rowFromTop + 0.5) * cell);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final game = ch.Chess.fromFEN(fen, check_validity: false);

    final cell = size.width / 8;
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(cell * 0.12),
    );
    canvas.clipRRect(r);

    for (var row = 0; row < 8; row++) {
      for (var file = 0; file < 8; file++) {
        final sq = '${'abcdefgh'[file]}${8 - row}';
        final isLight = (file + row) % 2 == 0;
        final rect = Rect.fromLTWH(file * cell, row * cell, cell, cell);
        final bg = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? [
                    palette.lightSquare,
                    Color.lerp(
                          palette.lightSquare,
                          palette.darkSquare,
                          0.15,
                        ) ??
                        palette.lightSquare,
                  ]
                : [
                    palette.darkSquare,
                    Color.lerp(palette.darkSquare, Colors.black, 0.12) ??
                        palette.darkSquare,
                  ],
          ).createShader(rect);
        canvas.drawRect(rect, bg);

        if (highlights.contains(sq)) {
          final pulse = highlightPulse;
          final ring = Paint()
            ..color = palette.selectedSquare.withValues(alpha: pulse)
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.1;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect.deflate(cell * 0.08),
              Radius.circular(cell * 0.1),
            ),
            ring,
          );
        }

        final piece = game.get(sq);
        if (piece != null) {
          final tp = TextPainter(
            text: TextSpan(
              text: _glyphs[(piece.type, piece.color)],
              style: TextStyle(
                fontSize: cell * 0.58,
                color: piece.color == ch.Color.WHITE
                    ? palette.whitePiece
                    : palette.blackPiece,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 1.5,
                  ),
                ],
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(
              file * cell + (cell - tp.width) / 2,
              row * cell + (cell - tp.height) / 2,
            ),
          );
        }
      }
    }

    for (final a in arrows) {
      _drawArrow(canvas, size, a);
    }
  }

  void _drawArrow(Canvas canvas, Size size, HintArrow a) {
    final from = _center(a.from, size);
    final to = _center(a.to, size);
    final mid = Offset(
      (from.dx + to.dx) / 2 + (to.dy - from.dy) * 0.12,
      (from.dy + to.dy) / 2 - (to.dx - from.dx) * 0.12,
    );

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);

    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final len = metric.length * arrowProgress;
    if (len <= 1) return;

    final trim = metric.extractPath(0, len);
    final color = a.isWarning ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(trim, paint);

    if (arrowProgress > 0.55) {
      final tangent = metric.getTangentForOffset(len);
      if (tangent != null) {
        final dir = math.atan2(tangent.vector.dy, tangent.vector.dx);
        final headLen = size.width * 0.055;
        final tip = tangent.position;
        final left = tip.translate(
          -headLen * math.cos(dir - 0.45),
          -headLen * math.sin(dir - 0.45),
        );
        final right = tip.translate(
          -headLen * math.cos(dir + 0.45),
          -headLen * math.sin(dir + 0.45),
        );
        final head = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(left.dx, left.dy)
          ..lineTo(right.dx, right.dy)
          ..close();
        canvas.drawPath(
          head,
          Paint()
            ..color = color.withValues(alpha: 0.9)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBoardPainter oldDelegate) {
    return oldDelegate.fen != fen ||
        oldDelegate.arrowProgress != arrowProgress ||
        oldDelegate.highlightPulse != highlightPulse ||
        oldDelegate.arrows != arrows ||
        oldDelegate.highlights != highlights;
  }
}
