import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'core/app_style_scope.dart';
import 'core/app_themes.dart';
import 'features/game/home_menu_screen.dart';

class SatrancApp extends StatefulWidget {
  const SatrancApp({super.key});

  @override
  State<SatrancApp> createState() => _SatrancAppState();
}

class _SatrancAppState extends State<SatrancApp> {
  AppAppearance _appearance = AppAppearance.classic;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satranç 2D',
      debugShowCheckedModeBanner: false,
      theme: themeForAppearance(_appearance),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const _AppScrollBehavior(),
          child: AppStyleScope(
            appearance: _appearance,
            onAppearanceChanged: (a) => setState(() => _appearance = a),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const HomeMenuScreen(),
    );
  }
}

/// Web / masaüstünde kaydırma çubuğu + sürükleyerek kaydırma.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
