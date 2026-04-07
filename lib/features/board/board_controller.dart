import 'package:chess/chess.dart' as ch;
import 'package:flutter/foundation.dart';

import 'legal_moves.dart';

typedef PromotionPicker = Future<ch.PieceType?> Function(
  List<ch.PieceType> options,
  ch.Color sideToMove,
);

/// Step 2: tam kurallar `chess.dart` ile; terfi seçimi ve yasal olmayan hamle bildirimi.
class BoardController extends ChangeNotifier {
  BoardController() : _game = ch.Chess();

  ch.Chess _game;

  String? _selected;
  List<ch.Move> _legalForSelected = [];
  String? _lastFrom;
  String? _lastTo;
  ch.Move? _lastCommittedMove;
  final List<String> _uciHistory = [];

  /// Piyon terfisinde kullanıcı seçimi (null ise vezir tercih edilir).
  PromotionPicker? promotionPicker;

  /// Yasal olmayan hedef veya geçersiz FEN gibi kısa mesajlar.
  ValueChanged<String>? onUserMessage;

  /// FEN değişti (hamle, yeni oyun, başarılı FEN yükleme) — motor analizi için.
  VoidCallback? onFenChanged;

  /// Motor / UCI ile hamle uygula (terfide vezir).
  bool applyEngineMove(ch.Move m) {
    if (!LegalMoves.isLegalMove(_game, m)) return false;
    if (!_game.move(m)) return false;
    _lastFrom = m.fromAlgebraic;
    _lastTo = m.toAlgebraic;
    _lastCommittedMove = m;
    _uciHistory.add(moveToUci(m));
    _selected = null;
    _legalForSelected = [];
    notifyListeners();
    onFenChanged?.call();
    return true;
  }

  ch.Chess get game => _game;
  String? get selectedSquare => _selected;
  List<ch.Move> get legalMovesForSelection => List.unmodifiable(_legalForSelected);
  String? get lastMoveFrom => _lastFrom;
  String? get lastMoveTo => _lastTo;
  ch.Color get turn => _game.turn;
  String get fen => _game.fen;
  ch.Move? get lastCommittedMove => _lastCommittedMove;
  List<String> get uciHistory => List.unmodifiable(_uciHistory);

  bool get inCheck => _game.in_check;
  bool get inCheckmate => _game.in_checkmate;
  bool get inStalemate => _game.in_stalemate;
  bool get inDraw => _game.in_draw;

  static String squareName(int file, int rankFromBottom) {
    const files = 'abcdefgh';
    return '${files[file]}$rankFromBottom';
  }

  /// UI: üst satır rank 8, alt satır rank 1 (beyaz altta).
  static String squareAt(int fileIndex, int rowFromTop) {
    final rank = 8 - rowFromTop;
    return squareName(fileIndex, rank);
  }

  /// Yeni oyun veya geçerli FEN. Başarısızsa [onUserMessage] ile bildirir.
  bool loadFen(String fen) {
    final ok = LegalMoves.loadFen(_game, fen);
    if (!ok) {
      onUserMessage?.call('Geçersiz FEN.');
      return false;
    }
    _selected = null;
    _legalForSelected = [];
    _lastFrom = null;
    _lastTo = null;
    _lastCommittedMove = null;
    _uciHistory.clear();
    notifyListeners();
    onFenChanged?.call();
    return true;
  }

  Future<void> onSquareTapped(String square) async {
    final piece = _game.get(square);

    if (_selected != null) {
      final moved = await _tryMove(_selected!, square);
      if (moved) {
        _selected = null;
        _legalForSelected = [];
        notifyListeners();
        onFenChanged?.call();
        return;
      }
      if (piece != null && piece.color == _game.turn) {
        _selected = square;
        _legalForSelected = LegalMoves.forSquare(_game, square);
        notifyListeners();
        return;
      }
      onUserMessage?.call('Yasal olmayan hamle.');
      notifyListeners();
      return;
    }

    if (piece != null && piece.color == _game.turn) {
      _selected = square;
      _legalForSelected = LegalMoves.forSquare(_game, square);
      notifyListeners();
      return;
    }

    _selected = null;
    _legalForSelected = [];
    notifyListeners();
  }

  /// Uzun basma: seçili taşı değiştirmeden yasal hamleleri göster.
  void selectSquareForCoach(String square) {
    final piece = _game.get(square);
    if (piece != null && piece.color == _game.turn) {
      _selected = square;
      _legalForSelected = LegalMoves.forSquare(_game, square);
      notifyListeners();
    }
  }

  Future<bool> _tryMove(String from, String to) async {
    final candidates = _legalForSelected
        .where((m) => m.fromAlgebraic == from && m.toAlgebraic == to)
        .toList();
    if (candidates.isEmpty) return false;

    final ch.Move chosen;
    final multiPromotion =
        candidates.length > 1 && candidates.every((m) => m.promotion != null);

    if (multiPromotion) {
      const order = [
        ch.PieceType.QUEEN,
        ch.PieceType.ROOK,
        ch.PieceType.BISHOP,
        ch.PieceType.KNIGHT,
      ];
      final options = candidates.map((m) => m.promotion!).toSet().toList()
        ..sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));
      final side = _game.turn;
      final pick = promotionPicker != null
          ? await promotionPicker!(options, side)
          : ch.PieceType.QUEEN;
      if (pick == null) return false;
      chosen = candidates.firstWhere(
        (m) => m.promotion == pick,
        orElse: () => candidates.first,
      );
    } else {
      chosen = candidates.first;
    }

    if (!LegalMoves.isLegalMove(_game, chosen)) {
      return false;
    }

    final ok = _game.move(chosen);
    if (ok) {
      _lastFrom = from;
      _lastTo = to;
      _lastCommittedMove = chosen;
      _uciHistory.add(moveToUci(chosen));
    }
    return ok;
  }

  void newGame() {
    _game = ch.Chess();
    _selected = null;
    _legalForSelected = [];
    _lastFrom = null;
    _lastTo = null;
    _lastCommittedMove = null;
    _uciHistory.clear();
    notifyListeners();
    onFenChanged?.call();
  }

  static String moveToUci(ch.Move m) {
    final p = m.promotion?.name ?? '';
    return '${m.fromAlgebraic}${m.toAlgebraic}$p';
  }
}
