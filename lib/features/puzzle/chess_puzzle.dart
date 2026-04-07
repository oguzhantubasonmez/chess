import 'package:chess/chess.dart' as ch;

/// Bulmacanın doğrulanma biçimi (testler `goal` ile eşleştirir).
enum PuzzleGoal {
  /// Tek beyaz hamlesi sonrası şah mat.
  mateInOne,

  /// Çözüm sonunda rakip şah çekilir ve hedef taş (ör. vezir) alınmış olur.
  tacticWin,
}

/// Tek satırda çözüm: kullanıcı hamleleri + gerekiyorsa zorunlu cevaplar (motor yok).
class ChessPuzzle {
  const ChessPuzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.fen,
    required this.solutionUci,
    required this.playerSide,
    this.goal = PuzzleGoal.mateInOne,
  });

  final String id;
  final String title;
  final String description;
  final String fen;

  /// UCI dizisi; sıra tahta üzerindeki yasal hamle sırasına uyar.
  final List<String> solutionUci;

  /// Kullanıcının oynadığı taraf.
  final ch.Color playerSide;

  final PuzzleGoal goal;
}
