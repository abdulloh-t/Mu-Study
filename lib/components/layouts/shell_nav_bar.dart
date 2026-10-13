import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/theme/nature_paper_colors.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/l10n/nav_labels.dart';

/// Height of the floating navigation pill, excluding the safe area beneath it.
const double kShellNavBarHeight = 64;

/// Inset of the pill from the left and right edges of the screen.
const double kShellNavBarSideMargin = 16;

/// Gap between the pill and the bottom of the screen on devices without a home
/// indicator or gesture bar. Devices that have one use that inset instead, so
/// the pill never sits inside the system gesture area.
const double kShellNavBarMinBottomGap = 16;

/// Gap between a floating action button and the top of the pill.
const double kShellFabGap = 16;

/// Height of a standard [FloatingActionButton]; extended ones are shorter.
const double kShellFabHeight = 56;

/// Duration of the nav bar's selection animations.
const Duration kShellNavBarAnimationDuration = Duration(milliseconds: 240);

enum ShellBadgeKind { none, notifications, chat }

class ShellDestination {
  const ShellDestination({
    required this.labelKey,
    required this.icon,
    required this.path,
    this.badge = ShellBadgeKind.none,
  });

  /// Key into [AppLocalizations] nav_* getters (e.g. `navDashboard`).
  final String labelKey;
  final IconData icon;
  final String path;
  final ShellBadgeKind badge;
}

/// Space the shell's navigation bar occupies at the bottom of the screen,
/// including the safe area beneath it.
///
/// Screens inside the shell have their own `Scaffold`, which knows nothing
/// about the shell's floating pill and would otherwise place floating action
/// buttons and trailing content underneath it.
///
/// The shell renders the pill with `Scaffold.extendBody`, which folds its
/// height into the bottom padding of the body and zeroes the body's bottom
/// `viewPadding` — so the padding alone is the whole story. Outside the shell,
/// on tablet, on desktop and on routes pushed above it, this is the plain
/// system safe area, which is what those layouts need anyway.
double shellBottomInset(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom;

/// Bottom padding for scrollable content inside the shell so the last item
/// clears the navigation bar and, when [hasFab] is set, the floating action
/// button above it.
double shellContentBottomPadding(
  BuildContext context, {
  bool hasFab = false,
  double extra = 20,
}) {
  final double base = shellBottomInset(context) + extra;
  return hasFab ? base + kShellFabHeight + kShellFabGap : base;
}

/// Positions a [Scaffold.floatingActionButton] above the shell's navigation
/// bar, the safe area and the keyboard.
FloatingActionButtonLocation shellFabLocation(BuildContext context) =>
    ShellFabLocation(bottomInset: shellBottomInset(context));

/// End-aligned floating action button location that floats a fixed distance
/// above the shell's navigation bar rather than above the scaffold's own
/// bottom edge.
class ShellFabLocation extends StandardFabLocation with FabEndOffsetX {
  const ShellFabLocation({required this.bottomInset});

  /// Result of [shellBottomInset] for the screen this button belongs to.
  final double bottomInset;

  @override
  double getOffsetY(ScaffoldPrelayoutGeometry geometry, double adjustment) {
    final double fabHeight = geometry.floatingActionButtonSize.height;
    final double keyboard = geometry.minInsets.bottom;

    // The keyboard covers the nav bar rather than moving it, so the reserved
    // space shrinks by however much of it the keyboard hides. The button holds
    // still until the keyboard reaches it, then rides up with it.
    final double margin = math.max(
      kFloatingActionButtonMargin,
      bottomInset + kShellFabGap - keyboard,
    );

    double y = geometry.contentBottom - fabHeight - margin;
    final double snackBarHeight = geometry.snackBarSize.height;
    if (snackBarHeight > 0) {
      y = math.min(
        y,
        geometry.contentBottom -
            snackBarHeight -
            fabHeight -
            kFloatingActionButtonMargin,
      );
    }
    return y + adjustment;
  }

  @override
  bool operator ==(Object other) =>
      other is ShellFabLocation && other.bottomInset == bottomInset;

  @override
  int get hashCode => bottomInset.hashCode;

  @override
  String toString() => 'ShellFabLocation(bottomInset: $bottomInset)';
}

/// Frosted navigation pill used as the shell's `bottomNavigationBar` on mobile.
///
/// The pill is [kShellNavBarHeight] tall and sits on top of the larger of the
/// bottom safe area and [kShellNavBarMinBottomGap], so it clears home
/// indicators and gesture bars on any device. That total is what screens read
/// back through [shellBottomInset].
class ShellNavBar extends StatelessWidget {
  const ShellNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.iconBuilder,
  });

  /// Identifies the pill itself, so tests can measure its bounds.
  static const Key pillKey = Key('shellNavBarPill');

  final List<ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget Function(ShellDestination destination, bool isSelected)
  iconBuilder;

  @override
  Widget build(BuildContext context) {
    // viewPadding rather than padding: the bar sits below the keyboard, so it
    // must not resize while the keyboard is up.
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);

    return Padding(
      padding: EdgeInsets.only(
        left: kShellNavBarSideMargin + viewPadding.left,
        right: kShellNavBarSideMargin + viewPadding.right,
        bottom: math.max(viewPadding.bottom, kShellNavBarMinBottomGap),
      ),
      child: _buildPill(context),
    );
  }

  Widget _buildPill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AppStyleTokens.maybeOf(context);
    final isNature = tokens?.isNaturePaper ?? false;
    final isNeu = tokens?.isSoftNeumorphism ?? false;
    final isMono = tokens?.isMonochromeWorkspace ?? false;

    // Monochrome: compact rectangular dock. Others keep the stadium pill.
    final BorderRadius radius = BorderRadius.all(
      Radius.circular(isMono ? 12 : kShellNavBarHeight / 2),
    );

    final Color fill =
        tokens?.navSurface ??
        (isDark
            ? AppColors.darkSurfaceHighest.withValues(alpha: 0.96)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.88));
    final Color borderColor;
    if (isNeu) {
      borderColor = Colors.transparent;
    } else if (isMono) {
      borderColor = isDark
          ? AppColors.inkAlpha(context, 0.18)
          : AppColors.inkAlpha(context, 0.10);
    } else if (isNature) {
      borderColor = isDark
          ? NaturePaperColors.moonGlow.withValues(alpha: 0.22)
          : NaturePaperColors.warmBrown.withValues(alpha: 0.18);
    } else {
      borderColor = isDark ? AppColors.darkBorder : Colors.transparent;
    }

    final List<BoxShadow> shadows;
    if (isNeu) {
      // Floating extruded dock — dual soft shadows, no glass blur.
      shadows = Neumorphic.shadows(context, elevation: NeuElevation.floating);
    } else if (isMono) {
      // Editorial: no soft shadow — border alone defines the dock.
      shadows = const [];
    } else {
      shadows = [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.55)
              : (isNature
                    ? NaturePaperColors.warmBrown.withValues(alpha: 0.28)
                    : AppColors.inkAlpha(context, 0.12)),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        if (isNature && isDark)
          BoxShadow(
            color: NaturePaperColors.moonGlow.withValues(alpha: 0.08),
            blurRadius: 28,
          ),
      ];
    }

    final navRow = Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var i = 0; i < destinations.length; i++)
            Expanded(
              child: _ShellNavItem(
                destination: destinations[i],
                isSelected: i == selectedIndex,
                icon: iconBuilder(destinations[i], i == selectedIndex),
                onTap: () => onDestinationSelected(i),
                pressedActive: isNeu,
                editorialActive: isMono,
              ),
            ),
        ],
      ),
    );

    return Container(
      key: pillKey,
      height: kShellNavBarHeight,
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: radius,
        // Soft Neu + Monochrome avoid glassmorphism; Modern/Nature frost.
        child: (isNeu || isMono)
            ? navRow
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: navRow,
              ),
      ),
    );
  }
}

class _ShellNavItem extends StatelessWidget {
  const _ShellNavItem({
    required this.destination,
    required this.isSelected,
    required this.icon,
    required this.onTap,
    this.pressedActive = false,
    this.editorialActive = false,
  });

  final ShellDestination destination;
  final bool isSelected;
  final Widget icon;
  final VoidCallback onTap;

  /// Neumorphism: active tab looks physically pressed into the dock.
  final bool pressedActive;

  /// Monochrome Workspace: filled ink well + thin underline indicator.
  final bool editorialActive;

  @override
  Widget build(BuildContext context) {
    final glow = AppStyleTokens.maybeOf(context)?.navGlow ?? Colors.transparent;
    final ink = AppColors.ink(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: isSelected,
      label: navLabel(context.l10n, destination.labelKey),
      child: InkWell(
        onTap: onTap,
        customBorder: editorialActive
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            : const StadiumBorder(),
        child: SizedBox(
          height: kShellNavBarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft Neu: pressed well for the active destination.
              if (pressedActive)
                AnimatedOpacity(
                  duration: kShellNavBarAnimationDuration,
                  curve: Curves.easeOutCubic,
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    width: 48,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Neumorphic.surface(
                        context,
                        elevation: NeuElevation.pressed,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: Neumorphic.shadows(
                        context,
                        elevation: NeuElevation.pressed,
                      ),
                    ),
                  ),
                ),
              // Monochrome: solid ink fill behind the active icon.
              if (editorialActive)
                AnimatedOpacity(
                  duration: kShellNavBarAnimationDuration,
                  curve: Curves.easeOutCubic,
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    width: 40,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (glow != Colors.transparent)
                AnimatedOpacity(
                  duration: kShellNavBarAnimationDuration,
                  curve: Curves.easeOutCubic,
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          glow.withValues(alpha: pressedActive ? 0.28 : 0.40),
                          glow.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              // The icon is centred on the pill and the indicator floats
              // underneath it, so selecting a tab never shifts the icon.
              AnimatedScale(
                duration: kShellNavBarAnimationDuration,
                curve: Curves.easeOutCubic,
                scale: isSelected
                    ? (pressedActive || editorialActive ? 1.0 : 1.08)
                    : 1,
                child: editorialActive && isSelected
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isDark ? Colors.black : Colors.white,
                          BlendMode.srcIn,
                        ),
                        child: icon,
                      )
                    : icon,
              ),
              if (!pressedActive)
                Positioned(
                  bottom: editorialActive ? 8 : 12,
                  child: AnimatedContainer(
                    duration: kShellNavBarAnimationDuration,
                    curve: Curves.easeOutCubic,
                    height: editorialActive ? 2 : 4,
                    width: isSelected ? (editorialActive ? 12 : 16) : 0,
                    decoration: BoxDecoration(
                      color: editorialActive
                          ? ink.withValues(alpha: 0.35)
                          : AppColors.accent(context),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
