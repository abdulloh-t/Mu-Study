import 'dart:math' as math;

import 'package:flutter/material.dart';

class SoftFireflies extends StatefulWidget {
  const SoftFireflies({super.key});

  @override
  State<SoftFireflies> createState() => _SoftFirefliesState();
}

class _SoftFirefliesState extends State<SoftFireflies>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(painter: SoftFirefliesPainter(_c.value)),
    );
  }
}

class SoftFirefliesPainter extends CustomPainter {
  SoftFirefliesPainter(this.t);
  final double t;

  static const _pts = [
    Offset(0.2, 0.35),
    Offset(0.55, 0.28),
    Offset(0.78, 0.42),
    Offset(0.35, 0.55),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final core = Paint();
    for (var i = 0; i < _pts.length; i++) {
      final phase = i * 1.4;
      final a = t * 2 * math.pi;
      final pulse = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(a * 2 + phase));
      final c = Offset(
        _pts[i].dx * size.width + math.sin(a + phase) * 8,
        _pts[i].dy * size.height + math.cos(a + phase) * 5,
      );
      glow.color = const Color(0xFFE8C57F).withValues(alpha: 0.35 * pulse);
      core.color = const Color(0xFFF6E3B4).withValues(alpha: 0.85 * pulse);
      canvas.drawCircle(c, 3.2, glow);
      canvas.drawCircle(c, 1.1, core);
    }
  }

  @override
  bool shouldRepaint(covariant SoftFirefliesPainter old) => old.t != t;
}
