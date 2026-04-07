import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/engine/uci_eval_parser.dart';

void main() {
  test('cp ve mate özetleri', () {
    expect(
      uciInfoEvalSummary(
        'info depth 10 seldepth 15 score cp 25 nodes 12345',
      ),
      '+0.25 pb',
    );
    expect(
      uciInfoEvalSummary('info depth 5 score mate -3'),
      'Mat -3',
    );
    expect(uciInfoEvalSummary('bestmove e2e4 ponder e7e5'), isNull);
  });
}
