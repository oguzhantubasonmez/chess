import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:stockfish/stockfish.dart';

import 'local_stockfish_engine.dart';
import 'uci_eval_parser.dart';
import 'uci_multipv_parser.dart';

LocalStockfishEngine createLocalStockfishEngine() => _IoEngine();

class _IoEngine implements LocalStockfishEngine {
  Stockfish? _sf;
  bool _started = false;
  bool _supportedPlatform = false;

  Future<void> _chain = Future.value();

  @override
  bool get isAvailable => _supportedPlatform && _sf != null && _started;

  @override
  Future<void> start() async {
    if (_started) return;

    if (!(Platform.isAndroid || Platform.isIOS)) {
      dev.log(
        'Stockfish yalnızca Android/iOS native derlemesinde; bu işletim sisteminde analiz kapalı.',
        name: 'Stockfish',
      );
      _started = true;
      return;
    }

    _supportedPlatform = true;

    try {
      _sf = await stockfishAsync();

      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (_sf!.state.value == StockfishState.starting) {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        if (DateTime.now().isAfter(deadline)) {
          dev.log('Stockfish ready zaman aşımı.', name: 'Stockfish');
          _sf?.dispose();
          _sf = null;
          _started = true;
          return;
        }
        if (_sf!.state.value == StockfishState.error) {
          dev.log('Stockfish başlatılamadı (error).', name: 'Stockfish');
          _sf?.dispose();
          _sf = null;
          _started = true;
          return;
        }
      }

      if (_sf!.state.value != StockfishState.ready) {
        _started = true;
        return;
      }

      _sf!.stdin = 'uci';
      await _sf!.stdout
          .firstWhere((l) => l.trim() == 'uciok')
          .timeout(const Duration(seconds: 10));
      _sf!.stdin = 'isready';
      await _sf!.stdout
          .firstWhere((l) => l.trim() == 'readyok')
          .timeout(const Duration(seconds: 10));

      _started = true;
      dev.log('Stockfish UCI hazır.', name: 'Stockfish');
    } catch (e, st) {
      dev.log('Stockfish başlatma hatası: $e', name: 'Stockfish', stackTrace: st);
      try {
        _sf?.dispose();
      } catch (_) {}
      _sf = null;
      _started = true;
    }
  }

  @override
  Future<void> analyzeFen(
    String fen, {
    int depth = 12,
    void Function(String line)? onRawLine,
  }) async {
    if (_sf == null || !_started || _sf!.state.value != StockfishState.ready) {
      return;
    }

    Future<void> run() async {
      try {
        _sf!.stdin = 'stop';
      } catch (_) {}

      final done = Completer<void>();
      late final StreamSubscription<String> sub;
      sub = _sf!.stdout.listen((line) {
        onRawLine?.call(line);
        dev.log(line, name: 'Stockfish');
        final summary = uciInfoEvalSummary(line);
        if (summary != null) {
          dev.log(summary, name: 'StockfishEval');
        }
        if (line.startsWith('bestmove ') && !done.isCompleted) {
          done.complete();
        }
      });

      try {
        _sf!.stdin = 'setoption name MultiPV value 1';
        _sf!.stdin = 'position fen $fen';
        _sf!.stdin = 'go depth $depth';
        await done.future.timeout(
          const Duration(seconds: 45),
          onTimeout: () {
            try {
              _sf!.stdin = 'stop';
            } catch (_) {}
          },
        );
      } catch (e, st) {
        dev.log('Analiz: $e', name: 'Stockfish', stackTrace: st);
      } finally {
        await sub.cancel();
      }
    }

    _chain = _chain.then((_) => run());
    await _chain;
  }

  @override
  Future<String?> bestMoveUci(String fen, {int movetimeMs = 400}) async {
    if (_sf == null || !_started || _sf!.state.value != StockfishState.ready) {
      return null;
    }

    Future<String?> run() async {
      try {
        _sf!.stdin = 'stop';
      } catch (_) {}

      String? uci;
      final done = Completer<void>();
      late final StreamSubscription<String> sub;
      sub = _sf!.stdout.listen((line) {
        if (line.startsWith('bestmove ')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 2) uci = parts[1];
          if (!done.isCompleted) done.complete();
        }
      });

      try {
        _sf!.stdin = 'setoption name MultiPV value 1';
        _sf!.stdin = 'position fen $fen';
        _sf!.stdin = 'go movetime $movetimeMs';
        await done.future.timeout(
          const Duration(seconds: 25),
          onTimeout: () {
            try {
              _sf!.stdin = 'stop';
            } catch (_) {}
          },
        );
      } catch (e, st) {
        dev.log('bestMoveUci: $e', name: 'Stockfish', stackTrace: st);
      } finally {
        await sub.cancel();
      }

      if (uci == null || uci == '(none)') return null;
      return uci;
    }

    final completer = Completer<String?>();
    _chain = _chain.then((_) async {
      try {
        final r = await run();
        if (!completer.isCompleted) completer.complete(r);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  @override
  Future<List<UciMultipvLine>> multipvSearch(
    String fen, {
    required int multipv,
    int movetimeMs = 450,
  }) async {
    if (_sf == null || !_started || _sf!.state.value != StockfishState.ready) {
      return const [];
    }

    Future<List<UciMultipvLine>> run() async {
      try {
        _sf!.stdin = 'stop';
      } catch (_) {}

      final lastInfo = <int, String>{};
      final done = Completer<void>();
      late final StreamSubscription<String> sub;

      sub = _sf!.stdout.listen((line) {
        dev.log(line, name: 'StockfishMPV');
        if (line.startsWith('info ') &&
            line.contains(' multipv ') &&
            line.contains(' pv ')) {
          final id = UciMultipvLine.parseMultipvIndex(line);
          if (id != null) {
            lastInfo[id] = line;
          }
        }
        if (line.startsWith('bestmove ') && !done.isCompleted) {
          done.complete();
        }
      });

      final n = multipv.clamp(1, 40);
      try {
        _sf!.stdin = 'setoption name MultiPV value $n';
        _sf!.stdin = 'position fen $fen';
        _sf!.stdin = 'go movetime $movetimeMs';
        await done.future.timeout(
          const Duration(seconds: 25),
          onTimeout: () {
            try {
              _sf!.stdin = 'stop';
            } catch (_) {}
          },
        );
      } catch (e, st) {
        dev.log('MultiPV: $e', name: 'Stockfish', stackTrace: st);
      } finally {
        await sub.cancel();
      }

      try {
        _sf!.stdin = 'setoption name MultiPV value 1';
      } catch (_) {}

      final out = <UciMultipvLine>[];
      for (final line in lastInfo.values) {
        final sc = UciMultipvLine.parseScoreCp(line);
        final uci = UciMultipvLine.parseFirstUci(line);
        final idx = UciMultipvLine.parseMultipvIndex(line);
        if (sc == null || uci == null || idx == null) continue;
        out.add(
          UciMultipvLine(
            multipvIndex: idx,
            scoreCp: sc,
            firstUci: uci,
          ),
        );
      }
      return out;
    }

    final completer = Completer<List<UciMultipvLine>>();
    _chain = _chain.then((_) async {
      try {
        final lines = await run();
        if (!completer.isCompleted) completer.complete(lines);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    try {
      _sf?.dispose();
    } catch (_) {}
    _sf = null;
    _started = false;
    _supportedPlatform = false;
  }
}
