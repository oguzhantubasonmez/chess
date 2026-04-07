import 'package:flutter/material.dart';

import 'app_style_scope.dart';

ThemeData themeForAppearance(AppAppearance a) {
  return switch (a) {
    AppAppearance.classic => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D4E37),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
      ),
    AppAppearance.dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A574),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
      ),
    AppAppearance.minimal => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF546E7A),
          brightness: Brightness.light,
          surface: const Color(0xFFF5F6F8),
        ),
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
      ),
    AppAppearance.wood => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4C41),
          brightness: Brightness.light,
          surface: const Color(0xFFFFF6EB),
        ).copyWith(primary: const Color(0xFF5D4037)),
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
      ),
    AppAppearance.neon => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BCD4),
          brightness: Brightness.dark,
          surface: const Color(0xFF0D1520),
        ).copyWith(
          primary: const Color(0xFF00E5FF),
          secondary: const Color(0xFF69F0AE),
        ),
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
      ),
  };
}
