import 'package:flutter/material.dart';

/// Step 6: Ekran genişliği eşikleri — responsive düzen ve ileride çoklu pencere / web.
abstract final class AppBreakpoints {
  /// Dar telefon / dikey.
  static const double compact = 600;

  /// Tablet / küçük masaüstü.
  static const double medium = 900;

  /// Oyun ekranında tahta + yan panel (durum / ipucu kartı).
  static const double gameTwoColumnMinWidth = 920;

  /// İki sütun için yeterli yükseklik (üst bar sonrası gövde).
  static const double gameTwoColumnMinHeight = 480;

  /// Liste / menü gövdelerinin üst sınırı (ultra geniş ekranda okunabilirlik).
  static const double contentMaxWidth = 640;

  /// Ana ekran kart sütunu (Oyna / tavsiyeler).
  static const double homeDashboardMaxWidth = 520;

  /// Bulmaca listesi gibi daha geniş kartlar.
  static const double listContentMaxWidth = 720;

  static bool isCompactWidth(double width) => width < compact;

  static bool useGameTwoColumn(Size size) =>
      size.width >= gameTwoColumnMinWidth &&
      size.height >= gameTwoColumnMinHeight;
}

/// Geniş ekranda yatayda ortalanmış, [maxWidth] ile sınırlı içerik.
class ResponsiveContentWidth extends StatelessWidget {
  const ResponsiveContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
