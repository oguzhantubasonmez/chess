import 'hint_diagram.dart';

/// İpucu türü — UI rozetleri ve genişletme için.
enum HintCategory {
  general,
  opening,
  tactic,
  threat,
  capture,
  development,
  special,
}

/// Tahta taktik vurgusu (ileride ok/mini diyagram ile eşlenebilir).
enum TacticKind {
  none,
  fork,
  pin,
  discoveredAttack,
}

/// Son hamle için kısa değerlendirme bandı (yeşil/kırmızı çerçeve vb.).
enum MoveEvalFeedback {
  none,
  excellent,
  good,
  instructive,
  risky,
}

/// Öğretim ipucu: en fazla üç kısa cümle; kategori ve değerlendirme ile genişletilebilir.
class LearningHint {
  const LearningHint({
    required this.sentence1,
    this.sentence2,
    this.sentence3,
    this.headline,
    this.category = HintCategory.general,
    this.tacticKind = TacticKind.none,
    this.evalFeedback = MoveEvalFeedback.none,
    this.diagramFen,
    this.diagramArrows = const [],
    this.diagramHighlights = const [],
  });

  final String sentence1;
  final String? sentence2;
  final String? sentence3;
  final String? headline;
  final HintCategory category;
  final TacticKind tacticKind;
  final MoveEvalFeedback evalFeedback;

  /// Mini diyagram için tam FEN (null ise diyagram gösterilmez).
  final String? diagramFen;
  final List<HintArrow> diagramArrows;
  final List<String> diagramHighlights;

  bool get hasDiagram => diagramFen != null && diagramFen!.isNotEmpty;

  /// Metin satırları (UI için); boş olanlar atlanır.
  Iterable<String> get bodyLines sync* {
    yield sentence1;
    if (sentence2 != null && sentence2!.isNotEmpty) yield sentence2!;
    if (sentence3 != null && sentence3!.isNotEmpty) yield sentence3!;
  }
}
