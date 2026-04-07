import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';

import '../../core/ambient_particles.dart';
import '../../core/app_breakpoints.dart';
import '../../core/app_style_scope.dart';
import '../board/board_controller.dart';
import '../board/chess_board_view.dart';
import '../board/promotion_picker.dart';
import '../game/uci_move_codec.dart';
import 'chess_puzzle.dart' show ChessPuzzle, PuzzleGoal;

/// Tek bulmaca: çözüm satırına göre doğrulama; rakip hamleleri otomatik.
class PuzzlePlayScreen extends StatefulWidget {
  const PuzzlePlayScreen({super.key, required this.puzzle});

  final ChessPuzzle puzzle;

  @override
  State<PuzzlePlayScreen> createState() => _PuzzlePlayScreenState();
}

class _PuzzlePlayScreenState extends State<PuzzlePlayScreen> {
  late final BoardController _board;
  int _applied = 0;
  bool _busy = false;
  bool _solved = false;

  ChessPuzzle get puzzle => widget.puzzle;

  @override
  void initState() {
    super.initState();
    _board = BoardController();
    _board.promotionPicker = (options, side) async {
      if (!mounted) return null;
      return showPromotionPicker(context, options, side);
    };
    _board.onUserMessage = (msg) {
      if (!mounted) return;
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: scheme.inverseSurface,
          content: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: scheme.onInverseSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: TextStyle(color: scheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      );
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrap();
    });
  }

  void _bootstrap() {
    _board.loadFen(puzzle.fen);
    _applied = 0;
    _solved = false;
    _advanceOpponent();
    setState(() {});
  }

  void _replayPrefix(int count) {
    _board.loadFen(puzzle.fen);
    for (var i = 0; i < count; i++) {
      final m = moveFromUci(_board.game, puzzle.solutionUci[i]);
      if (m != null) _board.applyEngineMove(m);
    }
  }

  void _advanceOpponent() {
    while (_applied < puzzle.solutionUci.length &&
        _board.turn != puzzle.playerSide) {
      final m = moveFromUci(_board.game, puzzle.solutionUci[_applied]);
      if (m == null) break;
      _board.applyEngineMove(m);
      _applied++;
    }
    if (_applied >= puzzle.solutionUci.length) {
      _finishIfDone();
    }
  }

  void _finishIfDone() {
    if (!mounted || _solved) return;
    if (_applied < puzzle.solutionUci.length) return;
    setState(() => _solved = true);
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bulmaca tamam',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Çözümü doğru sırayla oynadınız.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Listeye dön'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSquareTap(String square) async {
    if (_busy || _solved) return;
    if (_board.turn != puzzle.playerSide) return;

    final histBefore = _board.uciHistory.length;
    await _board.onSquareTapped(square);
    if (!mounted) return;
    if (_board.uciHistory.length <= histBefore) return;

    final played = _board.uciHistory.last;
    if (_applied >= puzzle.solutionUci.length) return;

    if (played != puzzle.solutionUci[_applied]) {
      _busy = true;
      if (mounted) {
        final sm = ScaffoldMessenger.of(context);
        sm.clearMaterialBanners();
        final scheme = Theme.of(context).colorScheme;
        sm.showMaterialBanner(
          MaterialBanner(
            backgroundColor: scheme.errorContainer,
            content: Text(
              'Bu hamle çözümde yok. Tahta, doğru aşamaya sıfırlandı.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
            leading: Icon(
              Icons.highlight_off_rounded,
              color: scheme.onErrorContainer,
            ),
            actions: [
              TextButton(
                onPressed: () => sm.hideCurrentMaterialBanner(),
                child: Text(
                  'Tamam',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        );
      }
      _replayPrefix(_applied);
      _advanceOpponent();
      _busy = false;
      setState(() {});
      return;
    }

    _applied++;
    _advanceOpponent();
    setState(() {});
    _finishIfDone();
  }

  String _statusLine() {
    if (_solved) return 'Tamamlandı.';
    if (_board.inCheckmate) return 'Mat.';
    if (_board.inStalemate) return 'Pat.';
    if (_board.turn == puzzle.playerSide) {
      return puzzle.playerSide == ch.Color.WHITE
          ? 'Siz beyazı oynuyorsunuz.'
          : 'Siz siyahı oynuyorsunuz.';
    }
    return 'Rakip cevabı uygulanıyor…';
  }

  @override
  void dispose() {
    _board.dispose();
    super.dispose();
  }

  Widget _buildMetaColumn() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          puzzle.description,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          puzzle.goal == PuzzleGoal.mateInOne
              ? 'Hedef: tek hamlede mat.'
              : 'Hedef: şah çekerek kazanç.',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _statusLine(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = AppStyleScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(puzzle.title),
        actions: [
          PopupMenuButton<AppAppearance>(
            tooltip: 'Tema',
            icon: const Icon(Icons.palette_outlined),
            onSelected: style.onAppearanceChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: AppAppearance.classic,
                child: Text('Klasik açık'),
              ),
              PopupMenuItem(
                value: AppAppearance.dark,
                child: Text('Koyu tahta'),
              ),
              PopupMenuItem(
                value: AppAppearance.minimal,
                child: Text('Minimal modern'),
              ),
              PopupMenuItem(
                value: AppAppearance.wood,
                child: Text('Ahşap (sıcak)'),
              ),
              PopupMenuItem(
                value: AppAppearance.neon,
                child: Text('Neon (koyu)'),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Baştan',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _busy
                ? null
                : () {
                    setState(() => _solved = false);
                    _bootstrap();
                  },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final twoCol = AppBreakpoints.useGameTwoColumn(size);
          final maxBoardSide = twoCol ? 600.0 : 560.0;

          Widget boardStack() {
            return Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: AmbientParticlesLayer(),
                  ),
                ),
                AnimatedBuilder(
                  animation: _board,
                  builder: (context, _) {
                    return ChessBoardView(
                      controller: _board,
                      palette: style.boardPalette,
                      materialElevation: style.boardMaterialElevation,
                      maxBoardSide: maxBoardSide,
                      onSquareTapOverride: _onSquareTap,
                    );
                  },
                ),
              ],
            );
          }

          if (!twoCol) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: _buildMetaColumn(),
                ),
                Expanded(child: boardStack()),
                const SizedBox(height: 16),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 58, child: boardStack()),
              Expanded(
                flex: 34,
                child: Material(
                  color: scheme.surfaceContainerLowest.withValues(alpha: 0.45),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color:
                              scheme.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      left: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 20, 20),
                        child: _buildMetaColumn(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
