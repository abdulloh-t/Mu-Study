import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';

const _kAssetDir = 'assets/images/nature-paper';

class NaturePaperBackdrop extends StatefulWidget {
  const NaturePaperBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<NaturePaperBackdrop> createState() => _NaturePaperBackdropState();
}

class _NaturePaperBackdropState extends State<NaturePaperBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition;
  bool? _wasNightScene;

  @override
  void initState() {
    super.initState();
    _transition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
  }

  @override
  void dispose() {
    _transition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppStyleTokens.maybeOf(context);
    final isNature = tokens?.isNaturePaper ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool? nightScene = isNature ? isDark : null;
    if (nightScene != null &&
        _wasNightScene != null &&
        nightScene != _wasNightScene) {
      _transition.forward(from: 0);
    }
    _wasNightScene = nightScene;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: ExcludeSemantics(
              child: isNature
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 650),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: _fadeWithoutChildKey,
                      child: isDark
                          ? const _NightScene(key: ValueKey('nature-night'))
                          : const _DayScene(key: ValueKey('nature-day')),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: _TransitionLeaves(animation: _transition),
          ),
        ),
      ],
    );
  }
}

Widget _fadeWithoutChildKey(Widget child, Animation<double> animation) {
  return FadeTransition(opacity: animation, child: child);
}

class _DayScene extends StatefulWidget {
  const _DayScene({super.key});

  @override
  State<_DayScene> createState() => _DaySceneState();
}

class _DaySceneState extends State<_DayScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  static const _clouds = [
    _CloudSpec('white-cloud.png', y: 0.07, size: 0.30, speed: 1.7, phase: 0.1),
    _CloudSpec('flat-cloud.png', y: 0.16, size: 0.22, speed: 1.15, phase: 0.55),
    _CloudSpec('gray-cloud.png', y: 0.26, size: 0.17, speed: 1.4, phase: 0.85),
  ];

  static const _leaves = [
    _LeafSpec('beige-leaf.png', x: 0.12, size: 26, speed: 0.9, phase: 0.0),
    _LeafSpec('tan-seed.png', x: 0.32, size: 18, speed: 1.3, phase: 0.35),
    _LeafSpec('white-daisy.png', x: 0.55, size: 22, speed: 0.7, phase: 0.6),
    _LeafSpec('beige-leaf.png', x: 0.74, size: 20, speed: 1.1, phase: 0.2),
    _LeafSpec('salmon-flower.png', x: 0.88, size: 24, speed: 0.8, phase: 0.8),
  ];

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
    )..repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.52, 1.0],
                  colors: [
                    NaturePaperColors.cream,
                    Color(0xFFEFE4CD),
                    NaturePaperColors.paleBlue,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -h * 0.12,
              left: -w * 0.15,
              child: Container(
                width: w * 0.9,
                height: w * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NaturePaperColors.sunGlow.withValues(alpha: 0.30),
                      NaturePaperColors.sunGlow.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            const CustomPaint(painter: _PaperGrainPainter(isDark: false)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                '$_kAssetDir/landscape-hills-footer.png',
                width: w,
                fit: BoxFit.fitWidth,
                opacity: const AlwaysStoppedAnimation(0.4),
                filterQuality: FilterQuality.medium,
              ),
            ),
            AnimatedBuilder(
              animation: _drift,
              builder: (context, _) {
                final t = _drift.value;
                return Stack(
                  children: [
                    for (final c in _clouds)
                      Positioned(
                        left: (((t * c.speed + c.phase) % 1.2) - 0.15) * w,
                        top: c.y * h,
                        child: Image.asset(
                          '$_kAssetDir/${c.asset}',
                          width: (w * c.size).clamp(70.0, 220.0),
                          opacity: const AlwaysStoppedAnimation(0.55),
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    for (final leaf in _leaves)
                      Positioned(
                        left:
                            leaf.x * w +
                            math.sin(t * math.pi * 8 + leaf.phase * 7) * 18,
                        top:
                            (((t * leaf.speed * 2 + leaf.phase) % 1.1) - 0.05) *
                            h,
                        child: Transform.rotate(
                          angle:
                              math.sin(t * math.pi * 6 + leaf.phase * 9) * 0.5,
                          child: Image.asset(
                            '$_kAssetDir/${leaf.asset}',
                            width: leaf.size,
                            opacity: const AlwaysStoppedAnimation(0.45),
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _NightScene extends StatefulWidget {
  const _NightScene({super.key});

  @override
  State<_NightScene> createState() => _NightSceneState();
}

class _NightSceneState extends State<_NightScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    NaturePaperColors.midnight,
                    NaturePaperColors.forestNight,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -h * 0.10,
              right: -w * 0.20,
              child: Container(
                width: w * 0.85,
                height: w * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NaturePaperColors.moonGlow.withValues(alpha: 0.16),
                      NaturePaperColors.moonGlow.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            const CustomPaint(painter: _PaperGrainPainter(isDark: true)),
            AnimatedBuilder(
              animation: _drift,
              builder: (context, _) =>
                  CustomPaint(painter: _NightSkyPainter(t: _drift.value)),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: h * 0.03,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFF1C2822),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  '$_kAssetDir/landscape-hills-footer.png',
                  width: w,
                  fit: BoxFit.fitWidth,
                  opacity: const AlwaysStoppedAnimation(0.9),
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFF121B16),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  '$_kAssetDir/landscape-hills-footer.png',
                  width: w,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  const _NightSkyPainter({required this.t});

  final double t;

  static const _starCount = 70;
  static const _fireflyCount = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final starPaint = Paint();
    for (var i = 0; i < _starCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.55;
      final r = 0.5 + rng.nextDouble() * 0.9;
      final baseAlpha = 0.10 + rng.nextDouble() * 0.25;
      final twinkle = i % 3 == 0
          ? 0.5 + 0.5 * math.sin(t * math.pi * 10 + i * 1.7)
          : 1.0;
      starPaint.color = NaturePaperColors.moonBeige.withValues(
        alpha: baseAlpha * twinkle,
      );
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final corePaint = Paint();
    final fly = math.Random(23);
    for (var i = 0; i < _fireflyCount; i++) {
      final baseX = fly.nextDouble();
      final baseY = 0.35 + fly.nextDouble() * 0.55;
      final phase = fly.nextDouble() * math.pi * 2;
      final x =
          (baseX +
              0.05 * math.sin(t * math.pi * 4 + phase) +
              0.02 * math.sin(t * math.pi * 14 + phase * 3)) *
          size.width;
      final y =
          (baseY + 0.03 * math.cos(t * math.pi * 6 + phase * 2)) * size.height;
      final pulse = (0.5 + 0.5 * math.sin(t * math.pi * 8 + phase * 5)).clamp(
        0.0,
        1.0,
      );
      if (pulse < 0.15) continue;
      glowPaint.color = NaturePaperColors.amber.withValues(alpha: 0.35 * pulse);
      corePaint.color = const Color(0xFFF4D9A0).withValues(alpha: 0.85 * pulse);
      canvas.drawCircle(Offset(x, y), 5, glowPaint);
      canvas.drawCircle(Offset(x, y), 1.6, corePaint);
    }
  }

  @override
  bool shouldRepaint(_NightSkyPainter oldDelegate) => oldDelegate.t != t;
}

class _PaperGrainPainter extends CustomPainter {
  const _PaperGrainPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()
      ..color = isDark
          ? NaturePaperColors.moonBeige.withValues(alpha: 0.025)
          : NaturePaperColors.warmBrown.withValues(alpha: 0.035);
    final count = (size.width * size.height / 3200).round().clamp(120, 700);
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.6 + rng.nextDouble() * 0.7,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PaperGrainPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _TransitionLeaves extends StatelessWidget {
  const _TransitionLeaves({required this.animation});

  final Animation<double> animation;

  static const _sprites = [
    _LeafSpec('beige-leaf.png', x: 0.08, size: 30, speed: 1.0, phase: 0.0),
    _LeafSpec('white-daisy.png', x: 0.25, size: 24, speed: 1.3, phase: 0.3),
    _LeafSpec('tan-seed.png', x: 0.42, size: 20, speed: 0.9, phase: 0.6),
    _LeafSpec('beige-leaf.png', x: 0.58, size: 26, speed: 1.2, phase: 0.15),
    _LeafSpec('salmon-flower.png', x: 0.72, size: 24, speed: 1.0, phase: 0.45),
    _LeafSpec('beige-leaf.png', x: 0.88, size: 22, speed: 1.4, phase: 0.75),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        if (t == 0 || animation.isCompleted) return const SizedBox.shrink();
        final size = MediaQuery.sizeOf(context);
        final opacity = math.sin(t * math.pi).clamp(0.0, 1.0) * 0.85;
        return Stack(
          children: [
            for (final leaf in _sprites)
              Positioned(
                left:
                    leaf.x * size.width +
                    math.sin(t * math.pi * 3 + leaf.phase * 8) * 26,
                top:
                    (t * leaf.speed * 1.1 - 0.08 + leaf.phase * 0.1) *
                    size.height,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: t * math.pi * 2 * leaf.speed + leaf.phase * 5,
                    child: Image.asset(
                      '$_kAssetDir/${leaf.asset}',
                      width: leaf.size,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CloudSpec {
  const _CloudSpec(
    this.asset, {
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });

  final String asset;
  final double y;
  final double size;
  final double speed;
  final double phase;
}

class _LeafSpec {
  const _LeafSpec(
    this.asset, {
    required this.x,
    required this.size,
    required this.speed,
    required this.phase,
  });

  final String asset;
  final double x;
  final double size;
  final double speed;
  final double phase;
}
