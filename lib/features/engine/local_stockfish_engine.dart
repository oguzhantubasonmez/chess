import 'uci_multipv_parser.dart';

/// Yerel Stockfish / UCI oturumu (platforma göre fabrika).
abstract class LocalStockfishEngine {
  bool get isAvailable;

  Future<void> start();

  /// `position fen` + `go depth [depth]`. Satırları [onRawLine] ile verir; `bestmove` gelince biter.
  Future<void> analyzeFen(
    String fen, {
    int depth = 12,
    void Function(String line)? onRawLine,
  });

  /// Kök pozisyonda MultiPV araması; `bestmove` sonrası son `info` satırlarından üretilir.
  Future<List<UciMultipvLine>> multipvSearch(
    String fen, {
    required int multipv,
    int movetimeMs = 450,
  });

  /// Tek en iyi hamle UCI (örn. `e2e4`). Motor yoksa veya hata olursa `null`.
  Future<String?> bestMoveUci(String fen, {int movetimeMs = 400});

  void dispose();
}
