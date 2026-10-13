import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/notifications/notification_providers.dart';
import 'package:mu_study/providers/admin/admin_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  ConsumerState<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState
    extends ConsumerState<AdminAnnouncementsScreen> {
  void _refresh() {
    ref.invalidate(adminAnnouncementsProvider);
    ref.invalidate(announcementsProvider);
  }

  Future<void> _compose({Map<String, dynamic>? existing}) async {
    final groups = await ref.read(adminGroupsProvider.future);
    if (groups.isEmpty || !mounted) return;
    final l10n = context.l10n;
    final title = TextEditingController(
      text: existing?['title'] as String? ?? '',
    );
    final body = TextEditingController(
      text: existing?['description'] as String? ?? '',
    );
    var groupId =
        existing?['group_id'] as String? ?? groups.first['id'] as String;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => AlertDialog(
          title: Text(
            existing == null ? l10n.announcementsNew : l10n.announcementsEdit,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(labelText: l10n.commonTitle),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: body,
                  decoration: InputDecoration(labelText: l10n.commonMessage),
                  maxLines: 4,
                ),
                if (existing == null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: groupId,
                    decoration: InputDecoration(
                      labelText: l10n.teacherTargetGroup,
                    ),
                    items: groups
                        .map(
                          (g) => DropdownMenuItem(
                            value: g['id'] as String,
                            child: Text(g['title'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setStateLocal(() => groupId = v ?? groupId),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                if (existing == null) {
                  await supabase.from('announcements').insert({
                    'group_id': groupId,
                    'title': title.text.trim(),
                    'description': body.text.trim(),
                  });
                } else {
                  await supabase
                      .from('announcements')
                      .update({
                        'title': title.text.trim(),
                        'description': body.text.trim(),
                      })
                      .eq('id', existing['id'] as String);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _refresh();
              },
              child: Text(
                existing == null ? l10n.announcementsPost : l10n.commonSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.announcementsDeleteTitle),
        content: Text(l10n.announcementsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger(context),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await supabase.from('announcements').delete().eq('id', row['id'] as String);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(adminAnnouncementsProvider);
    final groupTitles = {
      for (final g in ref.watch(adminGroupsProvider).valueOrNull ?? [])
        g['id'] as String: g['title'] as String,
    };
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.announcementsAll)),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _compose(),
        child: const Icon(Icons.campaign_outlined),
      ),
      body: announcements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (rows) => rows.isEmpty
            ? EmptyState(
                title: l10n.announcementsEmpty,
                subtitle: l10n.announcementsEmptyAdmin,
              )
            : RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    shellContentBottomPadding(context, hasFab: true),
                  ),
                  itemCount: rows.length,
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    final createdAt = DateTime.tryParse(
                      row['created_at'] as String? ?? '',
                    );
                    final groupTitle = groupTitles[row['group_id'] as String?];
                    final byAdmin = row['teacher_id'] == null;
                    return PremiumCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  row['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  size: 20,
                                  color: AppColors.inkAlpha(context, 0.5),
                                ),
                                onSelected: (v) => v == 'edit'
                                    ? _compose(existing: row)
                                    : _delete(row),
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(l10n.commonEdit),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(l10n.commonDelete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            row['description'] as String? ?? '',
                            style: TextStyle(
                              color: AppColors.inkAlpha(context, 0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (createdAt != null)
                                Text(
                                  DateFormat.yMMMd().format(createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.inkAlpha(context, 0.4),
                                  ),
                                ),
                              if (groupTitle != null)
                                Text(
                                  '• $groupTitle',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.inkAlpha(context, 0.55),
                                  ),
                                ),
                              if (byAdmin)
                                Text(
                                  '• ${l10n.announcementsByAdmin}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent(context),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
