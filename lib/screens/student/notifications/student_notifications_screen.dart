import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/decor/paper_decor.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/domain_labels.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/notifications/notification_providers.dart';

class StudentNotificationsScreen extends ConsumerStatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  ConsumerState<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends ConsumerState<StudentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markAllRead());
  }

  Future<void> _markAllRead() async {
    if (!mounted) return;
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    await markAllNotificationsRead(profile.id);
    ref.invalidate(notificationsProvider);
  }

  void _open(AppNotification n) {
    final path = n.actionPath?.trim();
    if (path == null || path.isEmpty) return;
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: notifications.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              title: l10n.notificationsEmpty,
              subtitle: l10n.notificationsEmptySubtitle,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              shellContentBottomPadding(context, extra: 16),
            ),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final n = list[index];
              final when = n.createdAt;
              final timeLabel = when == null
                  ? null
                  : DateFormat.MMMd().add_jm().format(when.toLocal());
              final canOpen =
                  n.actionPath != null && n.actionPath!.trim().isNotEmpty;

              return PremiumCard(
                onTap: canOpen ? () => _open(n) : null,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: PaperGlyph(
                    icon: n.kindIcon,
                    size: 26,
                    opacity: n.isRead ? 0.45 : 1,
                    color: n.isRead
                        ? AppColors.inkAlpha(context, 0.35)
                        : AppColors.accent(context),
                  ),
                  title: Text(
                    n.kindLabel(l10n),
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (n.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(n.body),
                      ],
                      if (timeLabel != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.inkAlpha(context, 0.45),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: canOpen
                      ? Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.inkAlpha(context, 0.3),
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}
