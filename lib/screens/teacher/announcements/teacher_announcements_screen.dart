import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/inputs/group_selector.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/notifications/notification_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class TeacherAnnouncementsScreen extends ConsumerStatefulWidget {
  const TeacherAnnouncementsScreen({super.key});

  @override
  ConsumerState<TeacherAnnouncementsScreen> createState() =>
      _TeacherAnnouncementsScreenState();
}

class _TeacherAnnouncementsScreenState
    extends ConsumerState<TeacherAnnouncementsScreen> {
  Future<void> _create() async {
    final teacher = await ref.read(teacherProfileProvider.future);
    final groups = await ref.read(myGroupsProvider.future);
    if (teacher == null || groups.isEmpty) return;
    final title = TextEditingController();
    final body = TextEditingController();
    var groupId = ref.read(activeGroupIdProvider) ?? groups.first.id;

    if (!mounted) return;
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => AlertDialog(
          title: Text(l10n.announcementsNew),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: groupId,
                  decoration: InputDecoration(
                    labelText: l10n.teacherTargetGroup,
                  ),
                  items: groups
                      .map(
                        (g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.title)),
                      )
                      .toList(),
                  onChanged: (v) => setStateLocal(() => groupId = v ?? groupId),
                ),
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
                await supabase.from('announcements').insert({
                  'teacher_id': teacher.id,
                  'group_id': groupId,
                  'title': title.text.trim(),
                  'description': body.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(announcementsProvider);
              },
              child: Text(l10n.announcementsPost),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(Announcement a) async {
    final l10n = context.l10n;
    final title = TextEditingController(text: a.title);
    final body = TextEditingController(text: a.description);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.announcementsEdit),
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
              await supabase
                  .from('announcements')
                  .update({
                    'title': title.text.trim(),
                    'description': body.text.trim(),
                  })
                  .eq('id', a.id);
              if (ctx.mounted) Navigator.pop(ctx);
              ref.invalidate(announcementsProvider);
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Announcement a) async {
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
    await supabase.from('announcements').delete().eq('id', a.id);
    ref.invalidate(announcementsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(activeGroupIdProvider);
    final items = ref.watch(announcementsProvider(groupId));
    final myTeacherId = ref.watch(teacherProfileProvider).valueOrNull?.id;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.announcementsTitle)),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.campaign_outlined),
      ),
      body: items.when(
        data: (list) => ListView.builder(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            shellContentBottomPadding(context, hasFab: true),
          ),
          itemCount: list.length + 1,
          itemBuilder: (_, index) {
            if (index == 0) {
              return Column(
                children: [
                  const GroupSelector(padding: EdgeInsets.only(bottom: 8)),
                  if (list.isEmpty)
                    EmptyState(
                      title: l10n.announcementsEmpty,
                      subtitle: l10n.announcementsEmptyTeacher,
                    ),
                ],
              );
            }
            final i = index - 1;
            final announcement = list[i];
            final mine =
                myTeacherId != null && announcement.teacherId == myTeacherId;
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
                          announcement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (mine)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: AppColors.inkAlpha(context, 0.5),
                          ),
                          onSelected: (v) => v == 'edit'
                              ? _edit(announcement)
                              : _delete(announcement),
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
                    announcement.description,
                    style: TextStyle(
                      color: AppColors.inkAlpha(context, 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        DateFormat.yMMMd().format(
                          announcement.createdAt ?? DateTime.now(),
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.inkAlpha(context, 0.4),
                        ),
                      ),
                      if (announcement.teacherId == null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${l10n.announcementsByAdmin}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}
