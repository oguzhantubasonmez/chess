import 'package:chess/chess.dart' as ch;

import '../board/board_controller.dart';

ch.Move? moveFromUci(ch.Chess game, String? uci) {
  if (uci == null || uci.isEmpty || uci == '(none)') return null;
  final moves = game.moves({'asObjects': true, 'legal': true});
  for (final m in moves) {
    if (BoardController.moveToUci(m) == uci) return m;
  }
  return null;
}
