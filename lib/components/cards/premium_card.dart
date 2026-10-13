import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';
import 'package:mu_study/core/theme/neumorphic.dart';

class PremiumCard extends StatefulWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor,
    this.borderRadius,
    this.elevation,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  final double? borderRadius;

  final NeuElevation? elevation;

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _elevationAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AppStyleTokens.maybeOf(context);
    final isNature = tokens?.isNaturePaper ?? false;
    final isNeu = tokens?.isSoftNeumorphism ?? false;
    final isMono = tokens?.isMonochromeWorkspace ?? false;
    final radius = widget.borderRadius ?? tokens?.cardRadius ?? 16.0;

    return AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            final hover = _hoverController.value;
            final cardColor =
                widget.color ??
                tokens?.cardSurface ??
                (isDark ? AppColors.darkSurfaceElevated : scheme.surface);
            final borderColor =
                widget.borderColor ??
                tokens?.cardBorder ??
                (isDark
                    ? AppColors.darkBorder
                    : AppColors.inkAlpha(context, 0.06));
            final shadowColor = isDark
                ? Colors.black.withValues(alpha: 0.55 + hover * 0.25)
                : scheme.onSurface.withValues(alpha: 0.02 + hover * 0.03);

            final List<BoxShadow> shadows;
            final bool showBorder;
            Color fillColor = cardColor;

            if (isNeu) {
              final baseElev = widget.elevation ?? NeuElevation.raised;
              final elev = _pressed
                  ? NeuElevation.pressed
                  : (hover > 0.5 ? NeuElevation.floating : baseElev);
              fillColor =
                  widget.color ?? Neumorphic.surface(context, elevation: elev);
              shadows = Neumorphic.shadows(
                context,
                elevation: elev,
                intensity: 1.15 + hover * 0.2,
              );
              showBorder = false;
            } else if (isMono) {
              shadows = const [];
              showBorder = true;
            } else if (isNature && !isDark) {
              fillColor = widget.color ?? NaturePaperColors.dayCard;
              shadows = [
                BoxShadow(
                  color: NaturePaperColors.warmBrown.withValues(
                    alpha: 0.12 + hover * 0.06,
                  ),
                  blurRadius: 16 + hover * 8,
                  offset: Offset(0, 6 + hover * 2),
                ),
                const BoxShadow(
                  color: NaturePaperColors.dayCardEdge,
                  offset: Offset(0, 2),
                ),
              ];
              showBorder = true;
            } else if (isNature && isDark) {
              fillColor = widget.color ?? NaturePaperColors.nightCardHigh;
              shadows = [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45 + hover * 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: NaturePaperColors.moonGlow.withValues(
                    alpha: 0.05 + hover * 0.08,
                  ),
                  blurRadius: 20 + hover * 10,
                ),
              ];
              showBorder = true;
            } else {
              shadows = [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: _elevationAnimation.value + (isDark ? 6 : 0),
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ];
              showBorder = true;
            }

            final Color hoverBorder;
            if (isMono) {
              hoverBorder = hover > 0
                  ? AppColors.inkAlpha(context, isDark ? 0.45 : 0.28)
                  : borderColor;
            } else if (isNature) {
              hoverBorder = isDark
                  ? NaturePaperColors.moonGlow.withValues(
                      alpha: 0.30 + hover * 0.18,
                    )
                  : NaturePaperColors.warmBrown.withValues(
                      alpha: 0.30 + hover * 0.10,
                    );
            } else if (isDark && hover > 0 && !isNeu) {
              hoverBorder = AppColors.mutedGold.withValues(
                alpha: 0.35 + hover * 0.25,
              );
            } else {
              hoverBorder = borderColor;
            }

            final scale = isMono
                ? 1.0
                : (isNeu
                      ? (_pressed ? 0.985 : (1.0 + hover * 0.012))
                      : _scaleAnimation.value);

            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(radius),
                  border: showBorder
                      ? Border.all(
                          color: hoverBorder,
                          width: isNature ? 1.4 : 1.0,
                        )
                      : null,
                  boxShadow: shadows,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onTapDown: widget.onTap == null
                        ? null
                        : (_) => setState(() => _pressed = true),
                    onTapUp: widget.onTap == null
                        ? null
                        : (_) => setState(() => _pressed = false),
                    onTapCancel: widget.onTap == null
                        ? null
                        : () => setState(() => _pressed = false),
                    onHover: (isHovered) {
                      if (widget.onTap != null) {
                        if (isHovered) {
                          _hoverController.forward();
                        } else {
                          _hoverController.reverse();
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(radius),
                    highlightColor: AppColors.accent(
                      context,
                    ).withValues(alpha: isDark ? 0.12 : 0.05),
                    splashColor: AppColors.accent(
                      context,
                    ).withValues(alpha: isDark ? 0.16 : 0.05),
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.02,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
