import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';

class _CloudSpec {
  const _CloudSpec({
    required this.asset,
    required this.y,
    required this.height,
    required this.speed,
    required this.phase,
    required this.opacity,
  });

  final String asset;
  final double y;
  final double height;
  final double speed;
  final double phase;
  final double opacity;
}

class SidebarSkyClouds extends StatefulWidget {
  const SidebarSkyClouds({super.key});

  @override
  State<SidebarSkyClouds> createState() => _SidebarSkyCloudsState();
}

class _SidebarSkyCloudsState extends State<SidebarSkyClouds>
    with SingleTickerProviderStateMixin {
  static const _clouds = [
    _CloudSpec(
      asset: PaperAssets.whiteCloud,
      y: 0.12,
      height: 28,
      speed: 0.55,
      phase: 0.05,
      opacity: 0.55,
    ),
    _CloudSpec(
      asset: PaperAssets.flatCloud,
      y: 0.38,
      height: 22,
      speed: 0.35,
      phase: 0.4,
      opacity: 0.4,
    ),
    _CloudSpec(
      asset: PaperAssets.grayCloud,
      y: 0.62,
      height: 18,
      speed: 0.7,
      phase: 0.72,
      opacity: 0.28,
    ),
    _CloudSpec(
      asset: PaperAssets.whiteCloud,
      y: 0.82,
      height: 16,
      speed: 0.45,
      phase: 0.2,
      opacity: 0.35,
    ),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isNaturePaper(context)) return const SizedBox.expand();
    if (Theme.of(context).brightness == Brightness.dark) {
      return const SizedBox.expand();
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              if (h < 24) return const SizedBox.expand();
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      for (final c in _clouds)
                        Positioned(
                          left:
                              w - (((t * c.speed + c.phase) % 1.0) * (w + 100)),
                          top: c.y * h,
                          child: Image.asset(
                            c.asset,
                            height: c.height,
                            opacity: AlwaysStoppedAnimation(c.opacity),
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class SidebarGrove extends StatefulWidget {
  const SidebarGrove({super.key});

  @override
  State<SidebarGrove> createState() => _SidebarGroveState();
}

class _SidebarGroveState extends State<SidebarGrove>
    with SingleTickerProviderStateMixin {
  static const _clouds = [
    _CloudSpec(
      asset: PaperAssets.whiteCloud,
      y: 4,
      height: 24,
      speed: 3.0,
      phase: 0.0,
      opacity: 0.7,
    ),
    _CloudSpec(
      asset: PaperAssets.flatCloud,
      y: 22,
      height: 18,
      speed: 1.8,
      phase: 0.45,
      opacity: 0.45,
    ),
    _CloudSpec(
      asset: PaperAssets.grayCloud,
      y: 10,
      height: 14,
      speed: 2.4,
      phase: 0.78,
      opacity: 0.32,
    ),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _swaying({
    required double t,
    required double phase,
    required Widget child,
  }) {
    final angle = math.sin(t * 2 * math.pi + phase) * 0.022;
    return Transform.rotate(
      angle: angle,
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isNaturePaper(context)) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: ClipRect(
        child: SizedBox(
          height: 148,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final travel = width + 90;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      if (!isDark)
                        for (final c in _clouds)
                          Positioned(
                            left:
                                width -
                                (((t * c.speed + c.phase) % 1.0) * travel),
                            top: c.y,
                            child: Image.asset(
                              c.asset,
                              height: c.height,
                              opacity: AlwaysStoppedAnimation(c.opacity),
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Image.asset(
                          PaperAssets.landscapeHills,
                          fit: BoxFit.fitWidth,
                          opacity: AlwaysStoppedAnimation(isDark ? 0.5 : 0.85),
                        ),
                      ),
                      Positioned(
                        left: 22,
                        bottom: 26,
                        child: _swaying(
                          t: t,
                          phase: 1.9,
                          child: Image.asset(
                            PaperAssets.singleTree,
                            height: 46,
                            opacity: AlwaysStoppedAnimation(isDark ? 0.85 : 1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 22,
                        bottom: 12,
                        child: _swaying(
                          t: t,
                          phase: 0,
                          child: Image.asset(
                            PaperAssets.twoTrees,
                            height: 78,
                            opacity: AlwaysStoppedAnimation(isDark ? 0.9 : 1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 78,
                        bottom: 16,
                        child: Image.asset(
                          PaperAssets.whiteDaisy,
                          height: 15,
                          opacity: AlwaysStoppedAnimation(isDark ? 0.55 : 0.9),
                        ),
                      ),
                      Positioned(
                        right: 96,
                        bottom: 8,
                        child: Image.asset(
                          PaperAssets.salmonFlower,
                          height: 17,
                          opacity: AlwaysStoppedAnimation(isDark ? 0.55 : 0.9),
                        ),
                      ),
                      Positioned(
                        left: 46,
                        bottom: 6,
                        child: Image.asset(
                          PaperAssets.tanSeed,
                          height: 10,
                          opacity: AlwaysStoppedAnimation(isDark ? 0.45 : 0.7),
                        ),
                      ),
                      if (!isDark)
                        Positioned(
                          left: 96,
                          bottom: 64,
                          child: _swaying(
                            t: t,
                            phase: 3.4,
                            child: Image.asset(
                              PaperAssets.tealBird,
                              height: 18,
                              opacity: const AlwaysStoppedAnimation(0.9),
                            ),
                          ),
                        ),
                      if (isDark)
                        Positioned.fill(
                          child: CustomPaint(painter: _FirefliesPainter(t)),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FirefliesPainter extends CustomPainter {
  _FirefliesPainter(this.t);

  final double t;

  static const _anchors = [
    Offset(0.16, 0.42),
    Offset(0.34, 0.62),
    Offset(0.52, 0.30),
    Offset(0.68, 0.55),
    Offset(0.82, 0.28),
    Offset(0.90, 0.60),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final core = Paint();

    for (var i = 0; i < _anchors.length; i++) {
      final phase = i * 1.7;
      final angle = t * 2 * math.pi;
      final dx = math.sin(angle + phase) * 7;
      final dy = math.sin((angle + phase) * 2) * 4;
      final center = Offset(
        _anchors[i].dx * size.width + dx,
        _anchors[i].dy * size.height + dy,
      );
      final pulse = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(angle * 3 + phase * 2));
      glow.color = const Color(0xFFE8C57F).withValues(alpha: 0.45 * pulse);
      core.color = const Color(0xFFF6E3B4).withValues(alpha: 0.9 * pulse);
      canvas.drawCircle(center, 3.4, glow);
      canvas.drawCircle(center, 1.1, core);
    }
  }

  @override
  bool shouldRepaint(_FirefliesPainter oldDelegate) => oldDelegate.t != t;
}
