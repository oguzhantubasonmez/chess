// dart run tool/find_mate.dart
import 'package:chess/chess.dart' as ch;

import 'package:satranc_2d/features/board/board_controller.dart';

void main() {
  const candidates = <String, String>{
    'rook_e_bad': '5k2/8/5K2/8/8/8/8/4R3 w - - 0 1',
    'promo': 'k7/1P6/1K6/8/8/8/8/8 w - - 0 1',
    'nb8': '3k4/8/3N4/4K3/8/8/8/8 w - - 0 1',
    'r_corner': '2k5/8/3K4/8/8/8/8/2R5 w - - 0 1',
    'bf7': '5k2/5ppp/5K2/8/8/8/5B2/8 w - - 0 1',
  };
  for (final e in candidates.entries) {
    final g = ch.Chess.fromFEN(e.value, check_validity: false);
    final mates = <String>[];
    for (final m in g.moves({'asObjects': true, 'legal': true})) {
      final g2 = ch.Chess.fromFEN(e.value, check_validity: false);
      g2.move(m);
      if (g2.in_checkmate) {
        mates.add(BoardController.moveToUci(m));
      }
    }
    // ignore: avoid_print
    print('${e.key}: ${mates.join(", ")}');
  }
}
