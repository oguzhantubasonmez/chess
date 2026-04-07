import 'package:chess/chess.dart' as ch;

import 'chess_puzzle.dart';

/// Yerleşik bulmacalar (testlerde doğrulanır).
final List<ChessPuzzle> kPuzzlesCatalog = [
  const ChessPuzzle(
    id: 'm1_rook',
    title: 'Kale ile mat 1',
    description: 'Beyaz oynar; siyah şahı mat edin (b kale, arka sıra).',
    fen: '6k1/5ppp/8/8/8/8/5PPP/1R4K1 w - - 0 1',
    solutionUci: ['b1b8'],
    playerSide: ch.Color.WHITE,
    goal: PuzzleGoal.mateInOne,
  ),
  const ChessPuzzle(
    id: 'm1_queen',
    title: 'Vezirle mat 1',
    description: 'Beyaz oynar; arka sırayı kapatıp mat edin.',
    fen: '6k1/5ppp/8/8/8/8/5PPP/3Q2K1 w - - 0 1',
    solutionUci: ['d1d8'],
    playerSide: ch.Color.WHITE,
    goal: PuzzleGoal.mateInOne,
  ),
  const ChessPuzzle(
    id: 'm1_back_rank',
    title: 'Arka sıra matı',
    description: 'Beyaz oynar; a kalesi ile son sırayı vurun.',
    fen: '6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1',
    solutionUci: ['a1a8'],
    playerSide: ch.Color.WHITE,
    goal: PuzzleGoal.mateInOne,
  ),
  const ChessPuzzle(
    id: 'win_queen_check',
    title: 'Vezir: al ve şah çek',
    description: 'Beyaz oynar; siyah vezirini alırken şah çekin.',
    fen: '4k3/3q4/8/8/6Q1/8/8/4K3 w - - 0 1',
    solutionUci: ['g4d7'],
    playerSide: ch.Color.WHITE,
    goal: PuzzleGoal.tacticWin,
  ),
];
