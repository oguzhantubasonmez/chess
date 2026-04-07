class OpeningMatch {
  const OpeningMatch(this.name, this.pattern);
  final String name;
  final List<String> pattern;
}

/// UCI hamle dizisi ile kaba açılış tanıma (kural tabanlı).
class TeachingOpenings {
  TeachingOpenings._();

  static final List<OpeningMatch> _entries = [
    const OpeningMatch('Vezir gambiti', ['d2d4', 'd7d5', 'c2c4']),
    const OpeningMatch('İtalyan oyunu', ['e2e4', 'e7e5', 'g1f3', 'b8c6', 'f1c4']),
    const OpeningMatch('İspanyol açılışı', ['e2e4', 'e7e5', 'g1f3', 'b8c6', 'f1b5']),
    const OpeningMatch('Sicilya savunması', ['e2e4', 'c7c5']),
    const OpeningMatch('Fransız savunması', ['e2e4', 'e7e6']),
    const OpeningMatch('Karaşah savunması', ['e2e4', 'c7c6']),
    const OpeningMatch('Kralın Hinti savunması', ['d2d4', 'g8f6', 'c2c4', 'g7g6']),
    const OpeningMatch('İngiliz başlangıcı', ['c2c4']),
    const OpeningMatch('İskoç oyunu', ['e2e4', 'e7e5', 'g1f3', 'b8c6', 'd2d4']),
    const OpeningMatch('Londra sistemi', ['d2d4', 'd7d5', 'c1f4']),
    const OpeningMatch('Piyon oyunu (d4)', ['d2d4', 'd7d5', 'e2e3']),
    const OpeningMatch('Modern savunma', ['e2e4', 'g7g6']),
  ];

  static bool _historyMatchesPattern(List<String> h, List<String> pattern) {
    if (h.length <= pattern.length) {
      for (var i = 0; i < h.length; i++) {
        if (h[i] != pattern[i]) return false;
      }
      return true;
    }
    for (var i = 0; i < pattern.length; i++) {
      if (h[i] != pattern[i]) return false;
    }
    return true;
  }

  /// En uzun eşleşen açılış; yoksa null.
  static OpeningMatch? bestMatch(List<String> uciHistory) {
    if (uciHistory.isEmpty) return null;
    OpeningMatch? best;
    for (final e in _entries) {
      if (!_historyMatchesPattern(uciHistory, e.pattern)) continue;
      if (best == null || e.pattern.length > best.pattern.length) {
        best = e;
      }
    }
    return best;
  }
}
