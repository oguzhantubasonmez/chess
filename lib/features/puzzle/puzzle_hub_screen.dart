import 'package:flutter/material.dart';

import '../../core/app_breakpoints.dart';
import 'chess_puzzle.dart' show ChessPuzzle, PuzzleGoal;
import 'puzzle_play_screen.dart';
import 'puzzles_catalog.dart';

/// Bulmaca listesi ve oyuna giriş.
class PuzzleHubScreen extends StatelessWidget {
  const PuzzleHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulmacalar'),
      ),
      body: ResponsiveContentWidth(
        maxWidth: AppBreakpoints.listContentMaxWidth,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: kPuzzlesCatalog.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final p = kPuzzlesCatalog[i];
            return _PuzzleTile(
              puzzle: p,
              scheme: scheme,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PuzzlePlayScreen(puzzle: p),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.goal, required this.scheme});

  final PuzzleGoal goal;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (goal) {
      PuzzleGoal.mateInOne => ('Mat • 1 hamle', Icons.flag_rounded),
      PuzzleGoal.tacticWin => ('Taktik', Icons.bolt_rounded),
    };
    return Chip(
      avatar: Icon(icon, size: 18, color: scheme.secondary),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    required this.puzzle,
    required this.scheme,
    required this.onTap,
  });

  final ChessPuzzle puzzle;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.extension_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      puzzle.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      puzzle.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _GoalChip(goal: puzzle.goal, scheme: scheme),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
