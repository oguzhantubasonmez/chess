import 'package:flutter/material.dart';

import '../../core/app_motion.dart';
import '../board/board_palette.dart';
import 'learning_hint.dart';
import 'mini_chess_diagram.dart';

/// Öğretmen ipucu: SnackBar yerine kart tabanlı, kategorize geri bildirim.
class TeachingFeedbackPanel extends StatelessWidget {
  const TeachingFeedbackPanel({
    super.key,
    required this.hint,
    this.onDismiss,
    this.palette,
  });

  final LearningHint? hint;
  final VoidCallback? onDismiss;
  final BoardPalette? palette;

  static IconData _iconFor(LearningHint h) {
    if (h.tacticKind == TacticKind.fork) return Icons.call_split_rounded;
    if (h.tacticKind == TacticKind.pin) return Icons.push_pin_outlined;
    if (h.tacticKind == TacticKind.discoveredAttack) {
      return Icons.visibility_outlined;
    }
    switch (h.category) {
      case HintCategory.opening:
        return Icons.menu_book_rounded;
      case HintCategory.tactic:
        return Icons.bolt_rounded;
      case HintCategory.threat:
        return Icons.warning_amber_rounded;
      case HintCategory.capture:
        return Icons.back_hand_rounded;
      case HintCategory.development:
        return Icons.trending_up_rounded;
      case HintCategory.special:
        return Icons.stars_rounded;
      case HintCategory.general:
        return Icons.lightbulb_outline_rounded;
    }
  }

  static Color _evalTint(ColorScheme scheme, MoveEvalFeedback ev) {
    switch (ev) {
      case MoveEvalFeedback.none:
      case MoveEvalFeedback.instructive:
        return scheme.primary;
      case MoveEvalFeedback.good:
      case MoveEvalFeedback.excellent:
        return scheme.tertiary;
      case MoveEvalFeedback.risky:
        return scheme.error;
    }
  }

  static String _evalLabel(MoveEvalFeedback ev) {
    switch (ev) {
      case MoveEvalFeedback.none:
        return '';
      case MoveEvalFeedback.instructive:
        return 'Bilgi';
      case MoveEvalFeedback.good:
        return 'İyi tempo';
      case MoveEvalFeedback.excellent:
        return 'Güçlü';
      case MoveEvalFeedback.risky:
        return 'Dikkat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final h = hint;

    return AnimatedSwitcher(
      duration: AppMotion.panelSwitch,
      switchInCurve: AppMotion.panelCurveIn,
      switchOutCurve: AppMotion.panelCurveOut,
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: h == null
          ? SizedBox.shrink(key: const ValueKey<String>('no-hint'))
          : Material(
              key: ValueKey<String>(h.sentence1),
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.surfaceContainerHigh.withValues(alpha: 0.95),
                      scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: h.evalFeedback == MoveEvalFeedback.none
                        ? scheme.outlineVariant.withValues(alpha: 0.45)
                        : _evalTint(scheme, h.evalFeedback)
                            .withValues(alpha: 0.55),
                    width: h.evalFeedback == MoveEvalFeedback.none ? 1 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.14),
                      blurRadius: 18,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _evalTint(scheme, h.evalFeedback)
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconFor(h),
                              color: _evalTint(scheme, h.evalFeedback),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if (h.headline != null)
                                      Text(
                                        h.headline!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    _CategoryChip(
                                      category: h.category,
                                      scheme: scheme,
                                    ),
                                    if (h.evalFeedback !=
                                            MoveEvalFeedback.none &&
                                        h.evalFeedback !=
                                            MoveEvalFeedback.instructive)
                                      Chip(
                                        label: Text(
                                          _evalLabel(h.evalFeedback),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: _evalTint(
                                          scheme,
                                          h.evalFeedback,
                                        ).withValues(alpha: 0.2),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (onDismiss != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: scheme.outline,
                              ),
                              onPressed: onDismiss,
                              tooltip: 'Kapat',
                            ),
                        ],
                      ),
                      if (h.hasDiagram) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Column(
                            children: [
                              MiniChessDiagram(
                                fen: h.diagramFen!,
                                arrows: h.diagramArrows,
                                highlights: h.diagramHighlights,
                                palette: palette ?? BoardPalette.classic,
                                size: 126,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Yeşil ok öneri / tehdit; kırmızı dikkat; halkalar vurgulu kareler.',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: scheme.outline,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ...h.bodyLines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            line,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.scheme,
  });

  final HintCategory category;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (category) {
      HintCategory.opening => ('Açılış', Icons.map_rounded),
      HintCategory.tactic => ('Taktik', Icons.bolt_rounded),
      HintCategory.threat => ('Tehdit', Icons.shield_outlined),
      HintCategory.capture => ('Alım', Icons.ads_click),
      HintCategory.development => ('Gelişim', Icons.rocket_launch_outlined),
      HintCategory.special => ('Özel kural', Icons.auto_awesome),
      HintCategory.general => ('İpucu', Icons.tips_and_updates_outlined),
    };
    return Chip(
      avatar: Icon(icon, size: 16, color: scheme.secondary),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      backgroundColor: scheme.surface.withValues(alpha: 0.5),
    );
  }
}
