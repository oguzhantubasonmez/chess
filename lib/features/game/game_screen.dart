import 'dart:async';

import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';

import '../../core/ambient_particles.dart';
import '../../core/app_breakpoints.dart';
import '../../core/app_motion.dart';
import '../../core/app_style_scope.dart';
import '../board/board_controller.dart';
import '../board/chess_board_view.dart';
import '../board/promotion_picker.dart';
import '../coach/coach_context_strip.dart';
import '../coach/learning_level.dart';
import '../coach/premove_coach_controller.dart';
import '../coach/teaching_feedback_panel.dart';
import '../coach/teaching_hint_controller.dart';
import '../engine/engine.dart';
import 'ai_difficulty.dart';
import 'ai_player.dart';
import 'game_mode.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.mode,
    this.aiDifficulty = AiDifficulty.medium,
  });

  final GameMode mode;
  /// Yalnızca [GameMode.vsAi] için kullanılır.
  final AiDifficulty aiDifficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BoardController _board;
  late final LocalStockfishEngine _engine;
  late final PremoveCoachController _coach;
  late final TeachingHintController _teaching;
  Timer? _evalDebounce;
  Timer? _premoveDebounce;
  Timer? _aiDebounce;
  String _lastFenForAnim = '';
  double _boardScale = 1.0;
  bool _aiBusy = false;
  bool _hintPanelDismissed = false;

  @override
  void initState() {
    super.initState();
    _board = BoardController();
    _lastFenForAnim = _board.fen;
    _coach = PremoveCoachController();
    _teaching = TeachingHintController();
    _engine = createStockfishEngine();
    _board.promotionPicker = (options, side) async {
      if (!mounted) return null;
      return showPromotionPicker(context, options, side);
    };
    _board.onUserMessage = (msg) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    };
    _board.onFenChanged = _onFenChanged;
    _board.addListener(_onBoardUpdated);
    unawaited(
      _engine.start().then((_) {
        if (mounted) _scheduleStockfishEval();
      }),
    );
  }

  void _onBoardUpdated() {
    if (_board.fen != _lastFenForAnim) {
      _lastFenForAnim = _board.fen;
      _pulseBoard();
    }
    _schedulePremoveCoach();
  }

  void _pulseBoard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _boardScale = 1.012);
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _boardScale = 1.0);
      });
    });
  }

  void _onFenChanged() {
    _hintPanelDismissed = false;
    _scheduleStockfishEval();
    _teaching.refresh(_board);
    _scheduleAiTurn();
  }

  void _schedulePremoveCoach() {
    _premoveDebounce?.cancel();
    _premoveDebounce = Timer(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      unawaited(_coach.refresh(board: _board, engine: _engine));
    });
  }

  void _scheduleStockfishEval() {
    _evalDebounce?.cancel();
    _evalDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      unawaited(_engine.analyzeFen(_board.fen));
    });
  }

  void _scheduleAiTurn() {
    if (widget.mode != GameMode.vsAi) return;
    if (_board.game.game_over) return;
    if (_board.turn != ch.Color.BLACK) return;
    if (_aiBusy) return;

    _aiDebounce?.cancel();
    _aiDebounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      unawaited(_runAiMove());
    });
  }

  Future<void> _runAiMove() async {
    if (widget.mode != GameMode.vsAi) return;
    if (_board.game.game_over) return;
    if (_board.turn != ch.Color.BLACK) return;
    if (_aiBusy) return;

    _aiBusy = true;
    if (mounted) setState(() {});

    final fenBefore = _board.fen;
    try {
      final m = await AiPlayer.pickMove(
        _board.game,
        _engine,
        difficulty: widget.aiDifficulty,
      );
      if (!mounted || _board.fen != fenBefore || m == null) return;
      _board.applyEngineMove(m);
    } finally {
      _aiBusy = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _onSquareTap(String square) async {
    if (widget.mode == GameMode.vsAi &&
        !_board.game.game_over &&
        _board.turn == ch.Color.BLACK) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şu an sıra yapay zekâda.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _board.onSquareTapped(square);
  }

  String _modeTitle() {
    switch (widget.mode) {
      case GameMode.localTwoPlayer:
        return 'Yerel 2 oyuncu';
      case GameMode.learning:
        return 'Öğrenme modu';
      case GameMode.vsAi:
        return 'YZ · ${widget.aiDifficulty.labelTr}';
    }
  }

  String _helpSubtitle() {
    switch (widget.mode) {
      case GameMode.localTwoPlayer:
        return 'Taş seçtiğinizde tahtanın üstünde koç şeridi açılır; hamle sonrası kart ipucu güncellenir. Renkler: mobilde Stockfish, web’de sezgisel kural.';
      case GameMode.learning:
        return 'Hamle sonrası kart + mini tahta; taş seçerken tahtanın üstünde koç şeridi. Menüden öğretmen seviyesi. Uzun basış: yasal hamleler. Renkler: Stockfish (mobil) veya web’de sezgisel kural.';
      case GameMode.vsAi:
        return 'Beyaz sırasında taş seçince koç şeridi ve hedef renkleri görünür; hamle sonrası üstte öğretmen kartı. '
            'Siyah: ${widget.aiDifficulty.labelTr.toLowerCase()}. ${widget.aiDifficulty.subtitleTr}';
    }
  }

  @override
  void dispose() {
    _evalDebounce?.cancel();
    _premoveDebounce?.cancel();
    _aiDebounce?.cancel();
    _board.removeListener(_onBoardUpdated);
    _board.onFenChanged = null;
    _engine.dispose();
    _board.dispose();
    super.dispose();
  }

  Widget _buildMetaColumn() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        AnimatedSwitcher(
          duration: AppMotion.coachStripSwitch,
          switchInCurve: AppMotion.panelCurveIn,
          switchOutCurve: AppMotion.panelCurveOut,
          child: Text(
            _statusLine(),
            key: ValueKey<String>(_statusLine()),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _helpSubtitle(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.outline,
              ),
          textAlign: TextAlign.center,
        ),
        AnimatedBuilder(
          animation: _teaching,
          builder: (context, _) {
            return TeachingFeedbackPanel(
              hint: _hintPanelDismissed ? null : _teaching.latest,
              palette: AppStyleScope.of(context).boardPalette,
              onDismiss: () => setState(() => _hintPanelDismissed = true),
            );
          },
        ),
      ],
    );
  }

  String _statusLine() {
    if (_board.inCheckmate) {
      return _board.turn == ch.Color.WHITE
          ? 'Siyah kazandı (şah mat).'
          : 'Beyaz kazandı (şah mat).';
    }
    if (_board.inStalemate) return 'Pat — beraberlik.';
    if (_board.inDraw) return 'Beraberlik.';
    if (_board.inCheck) return 'Şah!';
    if (widget.mode == GameMode.vsAi && _board.turn == ch.Color.BLACK) {
      if (_aiBusy) return 'Yapay zekâ düşünüyor…';
      return 'Siyah (yapay zekâ) oynar.';
    }
    return _board.turn == ch.Color.WHITE ? 'Beyaz oynar.' : 'Siyah oynar.';
  }

  @override
  Widget build(BuildContext context) {
    final style = AppStyleScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final interceptAi =
        widget.mode == GameMode.vsAi ? _onSquareTap : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeTitle()),
        actions: [
          PopupMenuButton<LearningLevel>(
            tooltip: 'Öğretmen seviyesi',
            icon: const Icon(Icons.school_outlined),
            onSelected: (lv) {
              setState(() {
                _hintPanelDismissed = false;
                _teaching.learningLevel = lv;
              });
              _teaching.refresh(_board);
            },
            itemBuilder: (context) => [
              for (final lv in LearningLevel.values)
                PopupMenuItem<LearningLevel>(
                  value: lv,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: _teaching.learningLevel == lv
                            ? Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const SizedBox.shrink(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(lv.label),
                            Text(
                              lv.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Yeni oyun',
            onPressed: _board.newGame,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final twoCol = AppBreakpoints.useGameTwoColumn(size);
          final maxBoardSide = twoCol ? 600.0 : 560.0;

          Widget boardArea() {
            return Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: AmbientParticlesLayer(),
                  ),
                ),
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([_board, _coach]),
                      builder: (context, _) {
                        return CoachContextStrip(
                          board: _board,
                          coach: _coach,
                          engineAvailable: _engine.isAvailable,
                          mode: widget.mode,
                        );
                      },
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_board, _coach]),
                        builder: (context, _) {
                          return AnimatedScale(
                            scale: _boardScale,
                            duration: AppMotion.boardScale,
                            curve: AppMotion.boardCurve,
                            child: ChessBoardView(
                              controller: _board,
                              coachByTo: _coach.qualityByDestination,
                              palette: style.boardPalette,
                              materialElevation: style.boardMaterialElevation,
                              maxBoardSide: maxBoardSide,
                              onSquareTapOverride: interceptAi,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                Expanded(child: boardArea()),
                const SizedBox(height: 24),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 58, child: boardArea()),
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
