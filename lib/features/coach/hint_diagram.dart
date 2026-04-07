import 'package:flutter/material.dart';

/// Mini diyagramda çizilecek ok (ör. çatal veya alım).
@immutable
class HintArrow {
  const HintArrow({
    required this.from,
    required this.to,
    this.isWarning = false,
  });

  final String from;
  final String to;

  /// Tehdit / zayıf kare — kırmızı ton.
  final bool isWarning;
}
