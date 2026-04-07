/// rules.txt — oyun modları (Step 7).
enum GameMode {
  /// Aynı cihazda iki insan, sırayla.
  localTwoPlayer,

  /// İpuçları + (varsa) renkli hedef analizi aynı kalır; etiket farklı.
  learning,

  /// İnsan beyaz, yapay zekâ siyah. Web’de zayıf rastgele yasal hamle.
  vsAi,
}
