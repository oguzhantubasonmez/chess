import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';

import '../board/chess_board_view.dart';

/// Ana menüde kullanılan küçük dekoratif tahta (başlangıç konumu).
class MiniBoardPreview extends StatelessWidget {
  const MiniBoardPreview({super.key, this.size = 76});

  final double size;

  static const _fen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  @override
  Widget build(BuildContext context) {
    final game = ch.Chess.fromFEN(_fen, check_validity: false);
    final cell = size / 8;
    const light = Color(0xFFF0D9B5);
    const darkSq = Color(0xFFB58863);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          children: List.generate(8, (row) {
            return Expanded(
              child: Row(
                children: List.generate(8, (file) {
                  final sq =
                      '${String.fromCharCode(97 + file)}${8 - row}';
                  final isLight = (file + row) % 2 == 0;
                  final piece = game.get(sq);
                  return Expanded(
                    child: ColoredBox(
                      color: isLight ? light : darkSq,
                      child: Center(
                        child: piece == null
                            ? const SizedBox.shrink()
                            : Text(
                                ChessBoardView.unicodeFor(
                                  piece.type,
                                  piece.color,
                                ),
                                style: TextStyle(
                                  fontSize: cell * 0.62,
                                  height: 1,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
