/// Yapay zekâ oyunu zorluğu (yerel Stockfish veya web yedek davranışı).
enum AiDifficulty {
  easy,
  medium,
  hard,
}

extension AiDifficultyLabels on AiDifficulty {
  String get labelTr => switch (this) {
        AiDifficulty.easy => 'Kolay',
        AiDifficulty.medium => 'Orta',
        AiDifficulty.hard => 'Zor',
      };

  String get subtitleTr => switch (this) {
        AiDifficulty.easy =>
          'Daha zayıf hamleler; kısa düşünme veya çoklu varyasyondan seçim.',
        AiDifficulty.medium => 'Dengeli güç ve süre.',
        AiDifficulty.hard => 'Daha uzun analiz, güçlü hamleler.',
      };
}
