/// Öğretmen içeriğinin ayrıntı düzeyi (gelistirme.txt — aşamalı öğrenme).
enum LearningLevel {
  /// Taş geliştirme, temel kavramlar, daha uzun açıklamalar.
  beginner,

  /// Taktik + açılış; orta uzunlukta metin.
  intermediate,

  /// Kısa, yoğun ipuçları; ince taktik vurgusu.
  advanced,
}

extension LearningLevelTr on LearningLevel {
  String get label {
    switch (this) {
      case LearningLevel.beginner:
        return 'Başlangıç';
      case LearningLevel.intermediate:
        return 'Orta';
      case LearningLevel.advanced:
        return 'İleri';
    }
  }

  String get subtitle {
    switch (this) {
      case LearningLevel.beginner:
        return 'Temeller ve tahta kontrolü';
      case LearningLevel.intermediate:
        return 'Taktik ve açılış fikirleri';
      case LearningLevel.advanced:
        return 'Strateji ve kısa geri bildirim';
    }
  }
}
