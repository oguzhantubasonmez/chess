import 'package:flutter/foundation.dart';

import '../board/board_controller.dart';
import 'learning_hint.dart';
import 'learning_level.dart';
import 'teaching_engine.dart';

/// Hamle sonrası kural tabanlı ipuçları; seviye ile ayrıntı ayarlanır.
class TeachingHintController extends ChangeNotifier {
  LearningHint? latest;
  LearningLevel _learningLevel = LearningLevel.beginner;

  LearningLevel get learningLevel => _learningLevel;

  set learningLevel(LearningLevel value) {
    if (_learningLevel == value) return;
    _learningLevel = value;
    notifyListeners();
  }

  void refresh(BoardController board) {
    latest = TeachingEngine.analyze(
      game: board.game,
      uciHistory: board.uciHistory,
      lastMove: board.lastCommittedMove,
      level: _learningLevel,
    );
    notifyListeners();
  }

  void clear() {
    latest = null;
    notifyListeners();
  }
}
