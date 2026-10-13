import 'package:flutter/material.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';
import 'package:mu_study/core/theme/soft_neumorphism_colors.dart';

enum NeuElevation { flat, raised, floating, pressed }

class Neumorphic {
  const Neumorphic._();

  static bool isActive(BuildContext context) =>
      AppStyleTokens.maybeOf(context)?.isSoftNeumorphism ?? false;

  static Color surface(
    BuildContext context, {
    NeuElevation elevation = NeuElevation.raised,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (elevation) {
      NeuElevation.pressed =>
        isDark
            ? SoftNeumorphismColors.nightInset
            : SoftNeumorphismColors.morningInset,
      NeuElevation.floating =>
        isDark
            ? SoftNeumorphismColors.nightSurfaceHigh
            : SoftNeumorphismColors.morningSurfaceHigh,
      NeuElevation.flat || NeuElevation.raised =>
        isDark
            ? SoftNeumorphismColors.nightSurface
            : SoftNeumorphismColors.morningSurface,
    };
  }

  static Color shadowColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? SoftNeumorphismColors.nightShadow
        : SoftNeumorphismColors.morningShadow;
  }

  static Color highlightColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? SoftNeumorphismColors.nightHighlight
        : SoftNeumorphismColors.morningHighlight;
  }

  static List<BoxShadow> shadows(
    BuildContext context, {
    NeuElevation elevation = NeuElevation.raised,
    double intensity = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dark = shadowColor(context);
    final light = highlightColor(context);

    switch (elevation) {
      case NeuElevation.flat:
        return const [];
      case NeuElevation.pressed:
        return [
          BoxShadow(
            color: dark.withValues(alpha: (isDark ? 0.85 : 0.45) * intensity),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: light.withValues(alpha: (isDark ? 0.55 : 0.90) * intensity),
            offset: const Offset(-3, -3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ];
      case NeuElevation.raised:
        return [
          BoxShadow(
            color: dark.withValues(alpha: (isDark ? 0.75 : 0.38) * intensity),
            offset: const Offset(6, 6),
            blurRadius: 14,
          ),
          BoxShadow(
            color: light.withValues(alpha: (isDark ? 0.50 : 0.95) * intensity),
            offset: const Offset(-5, -5),
            blurRadius: 12,
          ),
        ];
      case NeuElevation.floating:
        return [
          BoxShadow(
            color: dark.withValues(alpha: (isDark ? 0.82 : 0.42) * intensity),
            offset: const Offset(10, 12),
            blurRadius: 24,
          ),
          BoxShadow(
            color: light.withValues(alpha: (isDark ? 0.55 : 1.0) * intensity),
            offset: const Offset(-6, -6),
            blurRadius: 16,
          ),
        ];
    }
  }

  static BoxDecoration decoration(
    BuildContext context, {
    NeuElevation elevation = NeuElevation.raised,
    BorderRadius? borderRadius,
    Color? color,
    Gradient? gradient,
    double intensity = 1,
  }) {
    final radius =
        borderRadius ??
        BorderRadius.circular(
          AppStyleTokens.maybeOf(context)?.cardRadius ?? 18,
        );
    return BoxDecoration(
      color: gradient == null
          ? (color ?? surface(context, elevation: elevation))
          : null,
      gradient: gradient,
      borderRadius: radius,
      boxShadow: shadows(context, elevation: elevation, intensity: intensity),
    );
  }
}

class NeuIconWell extends StatelessWidget {
  const NeuIconWell({
    super.key,
    required this.icon,
    this.color,
    this.size = 22,
    this.padding = 12,
    this.elevation = NeuElevation.pressed,
    this.child,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final double padding;

  final NeuElevation elevation;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppStyleTokens.maybeOf(context);
    final tone = color ?? AppColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconWidget = child ?? PaperGlyph(icon: icon, size: size, color: tone);

    if (tokens?.isNaturePaper ?? false) {
      final side = size + padding * 2;
      return Container(
        width: side,
        height: side,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? NaturePaperColors.nightCardHighest
              : NaturePaperColors.paperBeige.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? NaturePaperColors.moonGlow.withValues(alpha: 0.28)
                : NaturePaperColors.warmBrown.withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : NaturePaperColors.warmBrown)
                  .withValues(alpha: isDark ? 0.35 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            if (!isDark)
              const BoxShadow(
                color: NaturePaperColors.dayCardEdge,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: iconWidget,
      );
    }

    if (tokens?.isSoftNeumorphism ?? false) {
      final side = size + padding * 2;
      return Container(
        width: side,
        height: side,
        alignment: Alignment.center,
        decoration: Neumorphic.decoration(
          context,
          elevation: elevation,
          borderRadius: BorderRadius.circular(14),
          intensity: 1.05,
        ),
        child: child ?? Icon(icon, size: size, color: tone),
      );
    }

    if (tokens?.isMonochromeWorkspace ?? false) {
      return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: tone.withValues(alpha: 0.18)),
          color: tone.withValues(alpha: 0.08),
        ),
        child: child ?? Icon(icon, size: size, color: tone),
      );
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child ?? Icon(icon, size: size, color: tone),
    );
  }
}

class NeuAvatar extends StatelessWidget {
  const NeuAvatar({
    super.key,
    required this.child,
    this.radius = 26,
    this.elevation = NeuElevation.raised,
  });

  final Widget child;
  final double radius;
  final NeuElevation elevation;

  @override
  Widget build(BuildContext context) {
    if (!Neumorphic.isActive(context)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.accent(context).withValues(alpha: 0.18),
        child: child,
      );
    }
    final side = radius * 2;
    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: Neumorphic.decoration(
        context,
        elevation: elevation,
        borderRadius: BorderRadius.circular(radius),
        intensity: 1.1,
      ),
      child: child,
    );
  }
}

class NeuSearchField extends StatelessWidget {
  const NeuSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isNeu = Neumorphic.isActive(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.inkAlpha(context, 0.45),
        ),
        filled: !isNeu,
        fillColor: isNeu
            ? Colors.transparent
            : (isDark
                  ? scheme.surfaceContainerHighest
                  : AppColors.controlSurface(context)),
        border: isNeu ? InputBorder.none : null,
        enabledBorder: isNeu ? InputBorder.none : null,
        focusedBorder: isNeu ? InputBorder.none : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );

    if (!isNeu) return field;

    return Container(
      decoration: Neumorphic.decoration(
        context,
        elevation: NeuElevation.pressed,
        borderRadius: BorderRadius.circular(16),
        intensity: 1.05,
      ),
      child: field,
    );
  }
}

class NeuPressable extends StatefulWidget {
  const NeuPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.color,
    this.elevation = NeuElevation.raised,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final NeuElevation elevation;
  final bool enabled;

  @override
  State<NeuPressable> createState() => _NeuPressableState();
}

class _NeuPressableState extends State<NeuPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final neu = Neumorphic.isActive(context);
    final radius =
        widget.borderRadius ??
        BorderRadius.circular(
          AppStyleTokens.maybeOf(context)?.cardRadius ?? 18,
        );
    final elevation = (!widget.enabled || widget.onTap == null)
        ? NeuElevation.flat
        : (_pressed ? NeuElevation.pressed : widget.elevation);

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      padding: widget.padding,
      transform: Matrix4.diagonal3Values(
        _pressed && neu ? 0.98 : 1,
        _pressed && neu ? 0.98 : 1,
        1,
      ),
      transformAlignment: Alignment.center,
      decoration: neu
          ? Neumorphic.decoration(
              context,
              elevation: elevation,
              borderRadius: radius,
              color: widget.color,
            )
          : BoxDecoration(
              color:
                  widget.color ?? AppStyleTokens.maybeOf(context)?.cardSurface,
              borderRadius: radius,
            ),
      child: widget.child,
    );

    if (widget.onTap == null || !widget.enabled) return body;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: body,
    );
  }
}
