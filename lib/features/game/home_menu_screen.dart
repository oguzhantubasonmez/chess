import 'package:flutter/material.dart';

import '../../core/app_breakpoints.dart';
import '../../core/app_style_scope.dart';
import 'ai_difficulty.dart';
import 'game_mode.dart';
import 'game_screen.dart';
import 'mini_board_preview.dart';
import '../puzzle/puzzle_hub_screen.dart';

/// Chess.com tarzı hiyerarşiden ilham: karşılama, tavsiyeler, belirgin «Oyna», alt gezinme.
/// Marka ve içerik kopyası değildir — yerel «Satranç 2D» deneyimi.
class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  int _navIndex = 0;

  /// Ana «Oyna» için belirgin aksan (temadan bağımsız, iyi kontrast).
  static const Color _ctaGreen = Color(0xFF2E9F5C);

  void _openGame(
    BuildContext context,
    GameMode mode, {
    AiDifficulty aiDifficulty = AiDifficulty.medium,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
          mode: mode,
          aiDifficulty: aiDifficulty,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 240),
      ),
    );
  }

  Future<void> _pickAiDifficultyThenPlay(BuildContext outerContext) async {
    final scheme = Theme.of(outerContext).colorScheme;
    final chosen = await showModalBottomSheet<AiDifficulty>(
      context: outerContext,
      showDragHandle: true,
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Yapay zekâ zorluğu',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Siz beyaz, motor siyah. Seviye düşükçe daha zayıf kök hamleler seçilir.',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final d in AiDifficulty.values)
                    ListTile(
                      leading: Icon(
                        switch (d) {
                          AiDifficulty.easy => Icons.sentiment_satisfied_rounded,
                          AiDifficulty.medium => Icons.balance_rounded,
                          AiDifficulty.hard => Icons.local_fire_department_rounded,
                        },
                        color: scheme.primary,
                      ),
                      title: Text(d.labelTr),
                      subtitle: Text(
                        d.subtitleTr,
                        maxLines: 3,
                      ),
                      onTap: () => Navigator.pop(ctx, d),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (!outerContext.mounted || chosen == null) return;
    _openGame(outerContext, GameMode.vsAi, aiDifficulty: chosen);
  }

  void _handleHomeModeTap(BuildContext context, GameMode mode) {
    if (mode == GameMode.vsAi) {
      _pickAiDifficultyThenPlay(context);
    } else {
      _openGame(context, mode);
    }
  }

  void _showPlaySheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'Nasıl oynamak istersiniz?',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.groups_2_rounded, color: scheme.primary),
                    title: const Text('Yerel 2 oyuncu'),
                    subtitle: const Text('Aynı cihazda sırayla'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGame(context, GameMode.localTwoPlayer);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.menu_book_rounded, color: scheme.primary),
                    title: const Text('Öğrenme modu'),
                    subtitle: const Text('İpuçları ve hedef renkleri'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGame(context, GameMode.learning);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.psychology_rounded, color: scheme.primary),
                    title: const Text('Yapay zekâya karşı'),
                    subtitle: const Text('Önce kolay / orta / zor seçin'),
                    onTap: () {
                      Navigator.pop(ctx);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          _pickAiDifficultyThenPlay(context);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeDashboard(
            ctaGreen: _ctaGreen,
            onPlay: () => _showPlaySheet(context),
            onSelectMode: _handleHomeModeTap,
          ),
          const _PuzzlesTab(),
          _LearnTab(onStart: () => _openGame(context, GameMode.learning)),
          const _ExploreTab(),
          _MoreTab(
            onOpenGame: _openGame,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            selectedIcon: Icon(Icons.extension_rounded),
            label: 'Bulmacalar',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Öğren',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'Daha fazla',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.ctaGreen,
    required this.onPlay,
    required this.onSelectMode,
  });

  final Color ctaGreen;
  final VoidCallback onPlay;
  final void Function(BuildContext context, GameMode mode) onSelectMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPad = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(scheme.surface, scheme.primary, 0.06) ??
                scheme.surface,
            scheme.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                scheme.primaryContainer.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.grid_3x3_rounded,
                            color: scheme.onPrimaryContainer,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Satranç 2D',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Çevrimdışı · öğretici odaklı',
                                style: textTheme.labelMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppBreakpoints.homeDashboardMaxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CoachGreetingCard(
                              scheme: scheme,
                              textTheme: textTheme,
                            ),
                            const SizedBox(height: 28),
                            _SectionCaption(
                              text: 'Tavsiyeler',
                              scheme: scheme,
                              textTheme: textTheme,
                            ),
                            const SizedBox(height: 12),
                            _RecoRow(
                              key: const ValueKey<String>('menu_local_2p'),
                              preview: const MiniBoardPreview(size: 72),
                              accentIcon: Icons.people_rounded,
                              title: 'İki oyuncu',
                              subtitle: 'Aynı cihazda sırayla paylaş',
                              scheme: scheme,
                              textTheme: textTheme,
                              onTap: () =>
                                  onSelectMode(context, GameMode.localTwoPlayer),
                            ),
                            const SizedBox(height: 10),
                            _RecoRow(
                              key: const ValueKey<String>('menu_learning'),
                              preview: const MiniBoardPreview(size: 72),
                              accentIcon: Icons.school_rounded,
                              title: 'Öğren',
                              subtitle: 'Açılış ve taktik ipuçlarıyla oyna',
                              scheme: scheme,
                              textTheme: textTheme,
                              onTap: () =>
                                  onSelectMode(context, GameMode.learning),
                            ),
                            const SizedBox(height: 10),
                            _RecoRow(
                              key: const ValueKey<String>('menu_vs_ai'),
                              preview: const MiniBoardPreview(size: 72),
                              accentIcon: Icons.psychology_rounded,
                              title: 'Motorla pratik',
                              subtitle:
                                  'Yapay zekâya karşı (yerel Stockfish)',
                              scheme: scheme,
                              textTheme: textTheme,
                              onTap: () => onSelectMode(context, GameMode.vsAi),
                            ),
                            const SizedBox(height: 10),
                            _RecoRow(
                              preview: const MiniBoardPreview(size: 72),
                              accentIcon: Icons.extension_rounded,
                              title: 'Bulmacalar',
                              subtitle:
                                  'Mat ve taktik görevleri — çevrimdışı',
                              scheme: scheme,
                              textTheme: textTheme,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const PuzzleHubScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ctaGreen,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: ctaGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onPlay,
                  child: Text(
                    'Oyna',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachGreetingCard extends StatelessWidget {
  const _CoachGreetingCard({
    required this.scheme,
    required this.textTheme,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: scheme.tertiaryContainer,
              child: Icon(
                Icons.emoji_objects_rounded,
                color: scheme.onTertiaryContainer,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tekrar hoş geldiniz. Bugün tahtada küçük bir adım atalım — '
                    'isterseniz hemen Oyna’ya dokunun.',
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCaption extends StatelessWidget {
  const _SectionCaption({
    required this.text,
    required this.scheme,
    required this.textTheme,
  });

  final String text;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
    );
  }
}

class _RecoRow extends StatelessWidget {
  const _RecoRow({
    super.key,
    required this.preview,
    required this.accentIcon,
    required this.title,
    required this.subtitle,
    required this.scheme,
    required this.textTheme,
    required this.onTap,
  });

  final Widget preview;
  final IconData accentIcon;
  final String title;
  final String subtitle;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainer.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              preview,
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  accentIcon,
                  size: 22,
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PuzzlesTab extends StatelessWidget {
  const _PuzzlesTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.extension_rounded, size: 64, color: scheme.primary),
              const SizedBox(height: 20),
              Text(
                'Bulmacalar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yerleşik mat ve vezir görevleri. Doğru hamle dizisini bulun; '
                'gerekirse rakip cevapları otomatik oynanır.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PuzzleHubScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Bulmacalara git'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnTab extends StatelessWidget {
  const _LearnTab({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, size: 64, color: scheme.primary),
              const SizedBox(height: 20),
              Text(
                'Öğrenme modu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hamle sonrası ipuçları ve taş seçince renkli hedef önerileri açık kalır.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Oyuna başla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_rounded, size: 64, color: scheme.primary),
              const SizedBox(height: 20),
              Text(
                'Keşfet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'İçerik ve topluluk özellikleri için mimari hazır; henüz bu sekmede bir şey yok.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab({required this.onOpenGame});

  final void Function(BuildContext context, GameMode mode) onOpenGame;

  @override
  Widget build(BuildContext context) {
    final style = AppStyleScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Daha fazla',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Görünüm'),
            subtitle: const Text('Klasik, koyu, minimal, ahşap ve neon'),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Klasik açık'),
                        onTap: () {
                          style.onAppearanceChanged(AppAppearance.classic);
                          Navigator.pop(ctx);
                        },
                      ),
                      ListTile(
                        title: const Text('Koyu tahta'),
                        onTap: () {
                          style.onAppearanceChanged(AppAppearance.dark);
                          Navigator.pop(ctx);
                        },
                      ),
                      ListTile(
                        title: const Text('Minimal modern'),
                        onTap: () {
                          style.onAppearanceChanged(AppAppearance.minimal);
                          Navigator.pop(ctx);
                        },
                      ),
                      ListTile(
                        title: const Text('Ahşap (sıcak)'),
                        onTap: () {
                          style.onAppearanceChanged(AppAppearance.wood);
                          Navigator.pop(ctx);
                        },
                      ),
                      ListTile(
                        title: const Text('Neon (koyu)'),
                        onTap: () {
                          style.onAppearanceChanged(AppAppearance.neon);
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups_2_outlined),
            title: const Text('Yerel 2 oyuncu'),
            onTap: () => onOpenGame(context, GameMode.localTwoPlayer),
          ),
          ListTile(
            key: const ValueKey<String>('menu_online_soon'),
            leading: Icon(Icons.cloud_outlined, color: scheme.primary),
            title: const Text('İnternette oyna'),
            subtitle: const Text('Yakında'),
            trailing: const Icon(Icons.schedule),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Çevrimiçi oyun yakında eklenecek.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
