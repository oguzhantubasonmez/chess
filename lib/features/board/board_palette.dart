import 'package:flutter/material.dart';

/// Tahta ve taş renkleri — klasik, koyu, minimal, ahşap, neon (Step 5).
class BoardPalette {
  const BoardPalette({
    required this.lightSquare,
    required this.darkSquare,
    required this.selectedSquare,
    required this.legalMoveDot,
    required this.lastMoveHighlight,
    required this.goodMoveOverlay,
    required this.badMoveOverlay,
    required this.neutralMoveOverlay,
    required this.whitePiece,
    required this.blackPiece,
  });

  final Color lightSquare;
  final Color darkSquare;
  final Color selectedSquare;
  final Color legalMoveDot;
  final Color lastMoveHighlight;
  final Color goodMoveOverlay;
  final Color badMoveOverlay;
  final Color neutralMoveOverlay;
  final Color whitePiece;
  final Color blackPiece;

  static const BoardPalette classic = BoardPalette(
    lightSquare: Color(0xFFF0D9B5),
    darkSquare: Color(0xFFB58863),
    selectedSquare: Color(0xFFBACA44),
    legalMoveDot: Color(0x80000000),
    lastMoveHighlight: Color(0x6694C5E8),
    goodMoveOverlay: Color(0x992E7D32),
    badMoveOverlay: Color(0x99B71C1C),
    neutralMoveOverlay: Color(0x99C9A227),
    whitePiece: Color(0xFFFAFAFA),
    blackPiece: Color(0xFF1A1A1A),
  );

  static const BoardPalette dark = BoardPalette(
    lightSquare: Color(0xFF8B7355),
    darkSquare: Color(0xFF4A3C2E),
    selectedSquare: Color(0xFF9AAC3A),
    legalMoveDot: Color(0x99FFFFFF),
    lastMoveHighlight: Color(0x554FC3F7),
    goodMoveOverlay: Color(0x9927AE60),
    badMoveOverlay: Color(0x99E74C3C),
    neutralMoveOverlay: Color(0x99F4D03F),
    whitePiece: Color(0xFFF0F0F0),
    blackPiece: Color(0xFF080808),
  );

  static const BoardPalette minimal = BoardPalette(
    lightSquare: Color(0xFFECEFF1),
    darkSquare: Color(0xFF90A4AE),
    selectedSquare: Color(0x8042A5F5),
    legalMoveDot: Color(0x66000000),
    lastMoveHighlight: Color(0x5542A5F5),
    goodMoveOverlay: Color(0x664CAF50),
    badMoveOverlay: Color(0x66EF5350),
    neutralMoveOverlay: Color(0x66FFCA28),
    whitePiece: Color(0xFFFFFFFF),
    blackPiece: Color(0xFF263238),
  );

  static const BoardPalette wood = BoardPalette(
    lightSquare: Color(0xFFE8D4B8),
    darkSquare: Color(0xFF8B5A2B),
    selectedSquare: Color(0xFFC4A35A),
    legalMoveDot: Color(0x99000000),
    lastMoveHighlight: Color(0x66D4A574),
    goodMoveOverlay: Color(0x992E7D32),
    badMoveOverlay: Color(0x99B71C1C),
    neutralMoveOverlay: Color(0x99A67C00),
    whitePiece: Color(0xFFFFF8F0),
    blackPiece: Color(0xFF1C1008),
  );

  static const BoardPalette neon = BoardPalette(
    lightSquare: Color(0xFF2A3D4A),
    darkSquare: Color(0xFF0D1B2A),
    selectedSquare: Color(0x8800E5FF),
    legalMoveDot: Color(0xAA00BCD4),
    lastMoveHighlight: Color(0x5564FFDA),
    goodMoveOverlay: Color(0x8800E676),
    badMoveOverlay: Color(0x88FF5252),
    neutralMoveOverlay: Color(0x88FFD740),
    whitePiece: Color(0xFFE0F7FA),
    blackPiece: Color(0xFF010508),
  );

  @Deprecated('Use BoardPalette.classic')
  static const BoardPalette standard = classic;
}
