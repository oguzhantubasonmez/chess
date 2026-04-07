/// UCI `info` satırından çoklu varyasyon satırı.
class UciMultipvLine {
  UciMultipvLine({
    required this.multipvIndex,
    required this.scoreCp,
    required this.firstUci,
  });

  final int multipvIndex;
  /// Mat için sentipiyon karşılığı; sıralama için [compareBetterFirst] kullan.
  final int scoreCp;
  final String firstUci;

  static int? parseScoreCp(String line) {
    final mate = RegExp(r'\bscore mate (-?\d+)\b').firstMatch(line);
    if (mate != null) {
      final m = int.parse(mate.group(1)!);
      if (m > 0) {
        return 1000000 - m;
      }
      return -1000000 + m;
    }
    final cp = RegExp(r'\bscore cp (-?\d+)\b').firstMatch(line);
    if (cp != null) {
      return int.parse(cp.group(1)!);
    }
    return null;
  }

  static int? parseMultipvIndex(String line) {
    final m = RegExp(r'\bmultipv (\d+)\b').firstMatch(line);
    if (m == null) return null;
    return int.parse(m.group(1)!);
  }

  /// `pv e2e4 e7e5 ...` ilk hamle.
  static String? parseFirstUci(String line) {
    final i = line.indexOf(' pv ');
    if (i < 0) return null;
    final rest = line.substring(i + 4).trim();
    if (rest.isEmpty) return null;
    return rest.split(RegExp(r'\s+')).first;
  }

  static String? uciFromSquare(String uci) {
    if (uci.length < 4) return null;
    return uci.substring(0, 2);
  }

  static String? uciToSquare(String uci) {
    if (uci.length < 4) return null;
    return uci.substring(2, 4);
  }

  /// Yüksek = oynanacak taraf için daha iyi.
  static int compareBetterFirst(UciMultipvLine a, UciMultipvLine b) =>
      b.scoreCp.compareTo(a.scoreCp);
}
