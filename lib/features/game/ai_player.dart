import 'dart:math';

import 'package:chess/chess.dart' as ch;

import '../engine/local_stockfish_engine.dart';
import '../engine/uci_multipv_parser.dart';
import 'ai_difficulty.dart';
import 'uci_move_codec.dart';

/// Yapay zekâ hamlesi: Stockfish varsa zorluğa göre süre / çoklu kök hamle; yoksa seviyeli yedek.
class AiPlayer {
  AiPlayer._();

  static final _random = Random();

  static Future<ch.Move?> pickMove(
    ch.Chess game,
    LocalStockfishEngine engine, {
    AiDifficulty difficulty = AiDifficulty.medium,
  }) async {
    if (game.game_over) return null;
    if (engine.isAvailable) {
      final m = await _pickWithEngine(game, engine, difficulty);
      if (m != null) return m;
    }
    return _fallbackNoEngine(game, difficulty);
  }

  static Future<ch.Move?> _pickWithEngine(
    ch.Chess game,
    LocalStockfishEngine engine,
    AiDifficulty difficulty,
  ) async {
    switch (difficulty) {
      case AiDifficulty.hard:
        return _fromUci(
          game,
          await engine.bestMoveUci(game.fen, movetimeMs: 1000),
          fallback: AiDifficulty.hard,
        );
      case AiDifficulty.medium:
        return _fromUci(
          game,
          await engine.bestMoveUci(game.fen, movetimeMs: 420),
          fallback: AiDifficulty.medium,
        );
      case AiDifficulty.easy:
        final lines = await engine.multipvSearch(
          game.fen,
          multipv: 10,
          movetimeMs: 260,
        );
        if (lines.length >= 3) {
          lines.sort(UciMultipvLine.compareBetterFirst);
          final start = _easySliceStart(lines.length);
          final slice = lines.sublist(start);
          slice.shuffle(_random);
          for (final line in slice) {
            final m = moveFromUci(game, line.firstUci);
            if (m != null) return m;
          }
        }
        return _fromUci(
          game,
          await engine.bestMoveUci(game.fen, movetimeMs: 140),
          fallback: AiDifficulty.easy,
        );
    }
  }

  /// Kolay: en iyi birkaç hamleyi dışarıda bırakıp kalan kök hamlelerden seç.
  static int _easySliceStart(int n) {
    const tail = 5;
    var start = n - tail;
    if (start < 2) start = 2;
    if (start >= n) start = n - 1;
    return start;
  }

  static ch.Move? _fromUci(
    ch.Chess game,
    String? uci, {
    required AiDifficulty fallback,
  }) {
    final m = moveFromUci(game, uci);
    if (m != null) return m;
    return _randomLegal(game, difficulty: fallback);
  }

  static ch.Move? _fallbackNoEngine(
    ch.Chess game,
    AiDifficulty difficulty,
  ) {
    return _randomLegal(game, difficulty: difficulty);
  }

  static ch.Move? _randomLegal(
    ch.Chess game, {
    required AiDifficulty difficulty,
  }) {
    final raw = game.moves({'asObjects': true, 'legal': true});
    final list = List<ch.Move>.from(raw);
    if (list.isEmpty) return null;

    switch (difficulty) {
      case AiDifficulty.easy:
        list.shuffle(_random);
        return list.first;
      case AiDifficulty.medium:
        list.shuffle(_random);
        if (_random.nextDouble() < 0.45) {
          final caps = list.where((m) => m.captured != null).toList();
          if (caps.isNotEmpty) {
            caps.shuffle(_random);
            return caps.first;
          }
        }
        return list.first;
      case AiDifficulty.hard:
        final caps = list.where((m) => m.captured != null).toList();
        if (caps.isNotEmpty) {
          caps.shuffle(_random);
          return caps.first;
        }
        final checks = list.where((m) {
          final g = ch.Chess.fromFEN(game.fen);
          return g.move(m) && g.in_check;
        }).toList();
        if (checks.isNotEmpty) {
          checks.shuffle(_random);
          return checks.first;
        }
        list.shuffle(_random);
        return list.first;
    }
  }
}
