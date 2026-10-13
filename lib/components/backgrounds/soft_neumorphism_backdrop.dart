import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/soft_neumorphism_colors.dart';

class SoftNeumorphismBackdrop extends StatelessWidget {
  const SoftNeumorphismBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isNeu = AppStyleTokens.maybeOf(context)?.isSoftNeumorphism ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: ExcludeSemantics(
              child: isNeu
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 550),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: _fadeWithoutChildKey,
                      child: isDark
                          ? const _NightAmbient(key: ValueKey('neu-night'))
                          : const _MorningAmbient(key: ValueKey('neu-day')),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

Widget _fadeWithoutChildKey(Widget child, Animation<double> animation) {
  return FadeTransition(opacity: animation, child: child);
}

class _MorningAmbient extends StatelessWidget {
  const _MorningAmbient({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SoftNeumorphismColors.morningBg,
            SoftNeumorphismColors.morningBgCool,
            Color(0xFFECE8E0),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SoftNeumorphismColors.sage.withValues(alpha: 0.10),
                      SoftNeumorphismColors.sage.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SoftNeumorphismColors.amber.withValues(alpha: 0.08),
                      SoftNeumorphismColors.amber.withValues(alpha: 0.0),
                    ],
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

class _NightAmbient extends StatelessWidget {
  const _NightAmbient({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SoftNeumorphismColors.nightBgCool,
            SoftNeumorphismColors.nightBg,
            Color(0xFF1C2220),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SoftNeumorphismColors.emerald.withValues(alpha: 0.09),
                      SoftNeumorphismColors.emerald.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SoftNeumorphismColors.amber.withValues(alpha: 0.06),
                      SoftNeumorphismColors.amber.withValues(alpha: 0.0),
                    ],
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
