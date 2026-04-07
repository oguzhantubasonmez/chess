import 'local_stockfish_engine.dart';
import 'local_stockfish_engine_stub.dart'
    if (dart.library.io) 'local_stockfish_engine_io.dart' as binding;

export 'local_stockfish_engine.dart';
export 'uci_eval_parser.dart';

/// Web: stub. VM/desktop: IO sarmalayıcı; motor yalnızca Android/iOS’ta başlar.
LocalStockfishEngine createStockfishEngine() => binding.createLocalStockfishEngine();
