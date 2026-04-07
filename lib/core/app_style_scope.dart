import 'package:flutter/material.dart';

import '../features/board/board_palette.dart';

enum AppAppearance {
  classic,
  dark,
  minimal,

  /// Sıcak ahşap tonları (tahta + arayüz).
  wood,

  /// Koyu zemin, vurgulu neon hissi.
  neon,
}

class AppStyleScope extends InheritedWidget {
  const AppStyleScope({
    super.key,
    required this.appearance,
    required this.onAppearanceChanged,
    required super.child,
  });

  final AppAppearance appearance;
  final ValueChanged<AppAppearance> onAppearanceChanged;

  static AppStyleScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStyleScope>();
  }

  static AppStyleScope of(BuildContext context) {
    final s = maybeOf(context);
    assert(s != null, 'AppStyleScope not found');
    return s!;
  }

  BoardPalette get boardPalette => switch (appearance) {
        AppAppearance.classic => BoardPalette.classic,
        AppAppearance.dark => BoardPalette.dark,
        AppAppearance.minimal => BoardPalette.minimal,
        AppAppearance.wood => BoardPalette.wood,
        AppAppearance.neon => BoardPalette.neon,
      };

  /// Tahta [Material] yüksekliği — temaya göre gölge derinliği.
  double get boardMaterialElevation => switch (appearance) {
        AppAppearance.classic => 10,
        AppAppearance.dark => 12,
        AppAppearance.minimal => 8,
        AppAppearance.wood => 14,
        AppAppearance.neon => 15,
      };

  /// Arka plan parçacık sayısı (0 = kapalı).
  int get ambientParticleCount => switch (appearance) {
        AppAppearance.classic => 10,
        AppAppearance.dark => 8,
        AppAppearance.minimal => 6,
        AppAppearance.wood => 12,
        AppAppearance.neon => 16,
      };

  @override
  bool updateShouldNotify(AppStyleScope oldWidget) =>
      appearance != oldWidget.appearance;
}
