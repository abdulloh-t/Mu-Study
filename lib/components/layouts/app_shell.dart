import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/brand/app_logo.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/decor/sidebar_grove.dart';
import 'package:mu_study/components/layouts/shell_nav_bar.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/app_style_tokens.dart';
import 'package:mu_study/core/utils/responsive.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/l10n/nav_labels.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/chat/chat_providers.dart';
import 'package:mu_study/providers/notifications/notification_providers.dart';
import 'package:mu_study/providers/focus/focus_session_provider.dart';

export 'package:mu_study/components/layouts/shell_nav_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.role,
    required this.child,
    required this.destinations,
  });

  final UserRole role;
  final Widget child;
  final List<ShellDestination> destinations;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isSidebarExpanded = true;

  int _indexFromLocation(String location) {
    for (var i = 0; i < widget.destinations.length; i++) {
      if (location.startsWith(widget.destinations[i].path)) return i;
    }
    return 0;
  }

  void _go(int index) {
    context.go(widget.destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final unreadChat = ref.watch(focusChatMutedProvider)
        ? 0
        : ref.watch(unreadChatCountProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;
    final isTablet = context.isTablet;
    final l10n = context.l10n;
    String labelOf(ShellDestination d) => navLabel(l10n, d.labelKey);

    int badgeCount(ShellDestination d) => switch (d.badge) {
      ShellBadgeKind.notifications => unreadNotifications,
      ShellBadgeKind.chat => unreadChat,
      ShellBadgeKind.none => 0,
    };

    Widget icon(
      ShellDestination d, {
      bool isSelected = false,
      bool usePaperAssets = true,
    }) {
      final isMono =
          AppStyleTokens.maybeOf(context)?.isMonochromeWorkspace ?? false;
      final tone = isSelected
          ? AppColors.accent(context)
          : AppColors.inkAlpha(context, 0.5);
      final Widget base = usePaperAssets
          ? PaperGlyph(
              icon: d.icon,
              size: 24,
              color: tone,
              opacity: isSelected || !isNaturePaper(context) ? 1 : 0.72,
            )
          : Icon(d.icon, size: 24, color: tone);
      final count = badgeCount(d);
      if (count > 0) {
        return Badge(
          label: Text(
            count > 99 ? '99+' : '$count',
            style: TextStyle(
              fontSize: 10,
              color: isMono
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white)
                  : null,
            ),
          ),
          backgroundColor: isMono
              ? AppColors.ink(context)
              : AppColors.warmAmber,
          child: base,
        );
      }
      return base;
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSidebarExpanded ? 260 : 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  right: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: ClipRect(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: _isSidebarExpanded
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          if (_isSidebarExpanded)
                            Expanded(
                              child: ClipRect(
                                child: Row(
                                  children: [
                                    const AppLogoImage(size: 28),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.shellMuStudy,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      softWrap: false,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: () => setState(
                              () => _isSidebarExpanded = !_isSidebarExpanded,
                            ),
                            icon: Icon(
                              _isSidebarExpanded ? Icons.menu_open : Icons.menu,
                              color: AppColors.inkAlpha(context, 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isSidebarExpanded)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: PaperDecor(
                            PaperAssets.hangingGarland,
                            height: 52,
                            fit: BoxFit.fitWidth,
                            opacity: 0.95,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < widget.destinations.length; i++)
                            Builder(
                              builder: (context) {
                                final d = widget.destinations[i];
                                final isSelected = index == i;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: InkWell(
                                    onTap: () => _go(i),
                                    borderRadius: BorderRadius.circular(8),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.accent(
                                                context,
                                              ).withValues(alpha: 0.12)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          isNaturePaper(context) ? 16 : 8,
                                        ),
                                      ),
                                      child: ClipRect(
                                        child: Row(
                                          mainAxisAlignment: _isSidebarExpanded
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.center,
                                          children: [
                                            icon(d, isSelected: isSelected),
                                            if (_isSidebarExpanded) ...[
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  labelOf(d),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.clip,
                                                  softWrap: false,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight: isSelected
                                                            ? FontWeight.w700
                                                            : FontWeight.w500,
                                                        color: isSelected
                                                            ? AppColors.accent(
                                                                context,
                                                              )
                                                            : AppColors.inkAlpha(
                                                                context,
                                                                0.7,
                                                              ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    if (_isSidebarExpanded)
                      const Expanded(child: SidebarSkyClouds())
                    else
                      const Spacer(),
                    if (_isSidebarExpanded) const SidebarGrove(),
                    if (_isSidebarExpanded)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: paperControlDecoration(
                            context,
                            color: AppColors.softWash(context, lightAlpha: 0.2),
                            radius: isNaturePaper(context) ? 16 : 12,
                          ),
                          child: Row(
                            children: [
                              if (isNaturePaper(context))
                                const PaperGlyph(
                                  icon: Icons.person_outline,
                                  size: 28,
                                )
                              else
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.accent(context),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      switch (widget.role) {
                                        UserRole.student => l10n.commonStudent,
                                        UserRole.teacher => l10n.commonTeacher,
                                        UserRole.admin => l10n.commonAdmin,
                                      }.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.accent(context),
                                      ),
                                    ),
                                    Text(
                                      l10n.commonWorkspace,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.contentMaxWidth,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: index,
                onDestinationSelected: _go,
                labelType: NavigationRailLabelType.none,
                backgroundColor: Theme.of(context).colorScheme.surface,
                indicatorColor: AppColors.accent(
                  context,
                ).withValues(alpha: 0.15),
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: AppLogoImage(size: 28),
                ),
                destinations: widget.destinations
                    .map(
                      (d) => NavigationRailDestination(
                        icon: icon(d),
                        selectedIcon: icon(d, isSelected: true),
                        label: Text(labelOf(d)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.contentMaxWidth,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: ShellNavBar(
        destinations: widget.destinations,
        selectedIndex: index,
        onDestinationSelected: _go,
        iconBuilder: (d, isSelected) =>
            icon(d, isSelected: isSelected, usePaperAssets: false),
      ),
    );
  }
}
