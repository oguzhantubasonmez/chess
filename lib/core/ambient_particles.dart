import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_motion.dart';
import 'app_style_scope.dart';

double _particleHash01(int i, int salt) {
  final x = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
  return x - x.floorToDouble();
}

/// Çok hafif yüzen noktalar — arka planda atmosfer (Step 5).
class AmbientParticlesLayer extends StatefulWidget {
  const AmbientParticlesLayer({super.key});

  @override
  State<AmbientParticlesLayer> createState() => _AmbientParticlesLayerState();
}

class _AmbientParticlesLayerState extends State<AmbientParticlesLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppMotion.ambientCycle)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppStyleScope.maybeOf(context);
    final n = scope?.ambientParticleCount ?? 0;
    if (n <= 0) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final tint = Color.lerp(scheme.primary, scheme.tertiary, 0.25) ??
        scheme.primary;

    return LayoutBuilder(
      builder: (context, bc) {
        final size = Size(bc.maxWidth, bc.maxHeight);
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _AmbientPainter(
                  t: _ctrl.value,
                  count: n,
                  tint: tint,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({
    required this.t,
    required this.count,
    required this.tint,
  });

  final double t;
  final int count;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (var i = 0; i < count; i++) {
      final u1 = _particleHash01(i, 1);
      final u2 = _particleHash01(i, 2);
      final u3 = _particleHash01(i, 3);
      final px = u1 * size.width;
      final py = u2 * size.height;
      final baseR = 1.1 + u3 * 2.4;
      final ph = t * 2 * math.pi + i * 0.71;
      final ox = px + math.sin(ph) * 5.5 + math.cos(ph * 0.63) * 3.5;
      final oy = py + math.cos(ph * 1.07) * 4.5;
      final pulse = 0.5 + 0.5 * math.sin(ph * 1.3 + i);
      final a = 0.045 + 0.07 * pulse;
      canvas.drawCircle(
        Offset(ox, oy),
        baseR,
        Paint()..color = tint.withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.count != count ||
        oldDelegate.tint != tint;
  }
}
