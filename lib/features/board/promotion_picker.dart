import 'package:chess/chess.dart' as ch;
import 'package:flutter/material.dart';

import 'chess_board_view.dart';

/// Piyon terfisi: V, K, F, A seçimi.
Future<ch.PieceType?> showPromotionPicker(
  BuildContext context,
  List<ch.PieceType> options,
  ch.Color sideToMove,
) {
  return showModalBottomSheet<ch.PieceType>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Terfi — taş seçin',
                style: Theme.of(ctx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final t in options)
                    IconButton.filledTonal(
                      iconSize: 48,
                      onPressed: () => Navigator.pop(ctx, t),
                      icon: Text(
                        ChessBoardView.unicodeFor(t, sideToMove),
                        style: const TextStyle(fontSize: 40, height: 1),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
