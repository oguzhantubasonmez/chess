import 'dart:developer' as dev;

import 'local_stockfish_engine.dart';
import 'uci_multipv_parser.dart';

LocalStockfishEngine createLocalStockfishEngine() => _StubEngine();

class _StubEngine implements LocalStockfishEngine {
  @override
  bool get isAvailable => false;

  @override
  Future<void> start() async {
    dev.log(
      'Stockfish bu platformda yok (ör. web). Android/iOS cihazda çalıştırın.',
      name: 'Stockfish',
    );
  }

  @override
  Future<void> analyzeFen(
    String fen, {
    int depth = 12,
    void Function(String line)? onRawLine,
  }) async {
    dev.log('Analiz atlandı (motor yok). FEN: $fen', name: 'Stockfish');
  }

  @override
  Future<List<UciMultipvLine>> multipvSearch(
    String fen, {
    required int multipv,
    int movetimeMs = 450,
  }) async {
    return <UciMultipvLine>[];
  }

  @override
  Future<String?> bestMoveUci(String fen, {int movetimeMs = 400}) async {
    return null;
  }

  @override
  void dispose() {}
}
