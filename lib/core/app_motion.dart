import 'package:flutter/material.dart';

/// Step 5: Tahta, ipucu kartı ve şeritlerde ortak süre ve eğriler.
abstract final class AppMotion {
  static const Duration boardScale = Duration(milliseconds: 200);
  static const Duration panelSwitch = Duration(milliseconds: 280);
  static const Duration coachStripSwitch = Duration(milliseconds: 220);
  static const Duration squareColor = Duration(milliseconds: 220);
  static const Duration pieceScale = Duration(milliseconds: 180);
  static const Duration landPop = Duration(milliseconds: 320);
  static const Duration ambientCycle = Duration(seconds: 22);
  static const Duration diagramArrowDraw = Duration(milliseconds: 900);

  static const Curve boardCurve = Curves.easeOutCubic;
  static const Curve panelCurveIn = Curves.easeOutCubic;
  static const Curve panelCurveOut = Curves.easeInCubic;
}
