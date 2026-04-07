/// UCI `info` satırlarından özet (Stockfish açısından hamle tarafı).
String? uciInfoEvalSummary(String line) {
  if (!line.startsWith('info ')) return null;
  final mate = RegExp(r'\bscore mate (-?\d+)\b').firstMatch(line);
  if (mate != null) {
    return 'Mat ${mate.group(1)}';
  }
  final cp = RegExp(r'\bscore cp (-?\d+)\b').firstMatch(line);
  if (cp != null) {
    final c = int.parse(cp.group(1)!);
    final pawns = c / 100.0;
    final sign = pawns > 0 ? '+' : '';
    return '$sign${pawns.toStringAsFixed(2)} pb';
  }
  return null;
}
