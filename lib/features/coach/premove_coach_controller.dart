import 'package:flutter/foundation.dart';

import '../board/board_controller.dart';
import '../engine/local_stockfish_engine.dart';
import 'heuristic_premove.dart';
import 'move_quality.dart';
import 'premove_ranking.dart';

/// Seçili taş için Stockfish MultiPV ile hedef kare renklendirme (Step 4).
class PremoveCoachController extends ChangeNotifier {
  Map<String, MoveQuality> qualityByDestination = {};
  int _token = 0;

  void clear() {
    qualityByDestination = {};
    notifyListeners();
  }

  Future<void> refresh({
    required BoardController board,
    required LocalStockfishEngine engine,
  }) async {
    final token = ++_token;
    final sel = board.selectedSquare;

    if (sel == null) {
      qualityByDestination = {};
      if (token == _token) notifyListeners();
      return;
    }

    final legals = board.legalMovesForSelection;
    if (legals.isEmpty) {
      qualityByDestination = {};
      if (token == _token) notifyListeners();
      return;
    }

    if (!engine.isAvailable) {
      qualityByDestination = heuristicDestinationQuality(
        game: board.game,
        fromSquare: sel,
        legalFromPiece: legals,
      );
      if (token == _token) notifyListeners();
      return;
    }

    final fen = board.fen;
    final ucis = legals
        .map(
          (m) => chessMoveToUci(
            fromAlgebraic: m.fromAlgebraic,
            toAlgebraic: m.toAlgebraic,
            promotionLowercase: m.promotion?.name,
          ),
        )
        .toList();

    final rootList = board.game.moves({'legal': true});
    final totalRoots = rootList.length;
    final mpv = totalRoots.clamp(3, 40);

    final lines = await engine.multipvSearch(
      fen,
      multipv: mpv,
      movetimeMs: 420,
    );

    if (token != _token) return;

    qualityByDestination = rankDestinationsFromMultipv(
      fromSquare: sel,
      legalUcisFromPiece: ucis,
      engineLines: lines,
    );
    notifyListeners();
  }
}
