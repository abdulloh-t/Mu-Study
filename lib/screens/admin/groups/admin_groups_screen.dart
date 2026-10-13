import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/admin/admin_providers.dart';
import 'package:mu_study/screens/admin/helpers/admin_labels.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class AdminGroupsScreen extends ConsumerStatefulWidget {
  const AdminGroupsScreen({super.key});

  @override
  ConsumerState<AdminGroupsScreen> createState() => _AdminGroupsScreenState();
}

class _AdminGroupsScreenState extends ConsumerState<AdminGroupsScreen> {
  Future<void> _createGroup() async {
    final title = TextEditingController();
    String? selectedTeacherId;
    var submitting = false;

    final teachersRes = await supabase
        .from('teachers')
        .select('id, profiles(full_name, username)');
    final teachers = teachersRes as List<dynamic>;

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final l10n = ctx.l10n;
          return AlertDialog(
            title: Text(l10n.adminCreateGroup),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText: l10n.commonGroup,
                    hintText: l10n.adminGroupTitleHint,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedTeacherId,
                  decoration: InputDecoration(
                    labelText: l10n.adminAssignTeacher,
                  ),
                  items: teachers.map((t) {
                    final p = t['profiles'] as Map;
                    final name =
                        p['full_name'] as String? ?? p['username'] as String;
                    return DropdownMenuItem(
                      value: t['id'] as String,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: submitting
                      ? null
                      : (v) => setLocal(() => selectedTeacherId = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: submitting ? null : () => Navigator.pop(ctx),
                child: Text(l10n.commonCancel),
              ),
              ElevatedButton(
                onPressed: submitting
                    ? null
                    : () async {
                        final groupTitle = title.text.trim();
                        if (groupTitle.isEmpty || selectedTeacherId == null) {
                          return;
                        }
                        setLocal(() => submitting = true);
                        try {
                          await supabase.from('groups').insert({
                            'title': groupTitle,
                            'teacher_id': selectedTeacherId,
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                          ref.invalidate(adminGroupsProvider);
                        } catch (e) {
                          if (ctx.mounted) {
                            setLocal(() => submitting = false);
                            final message = '$e'.contains(
                                  'groups_teacher_title_uidx',
                                )
                                ? l10n.adminGroupTitleExists
                                : l10n.commonErrorWithDetails('$e');
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        }
                      },
                child: Text(l10n.adminCreateGroupButton),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _assignStudent(String groupId) async {
    final students = await supabase
        .from('students')
        .select('id, profiles(full_name, username)');
    if (!mounted) return;
    String? studentId;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.adminAssignStudent),
          content: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: l10n.adminSelectStudent),
            items: students.map((s) {
              final p = s['profiles'] as Map;
              return DropdownMenuItem(
                value: s['id'] as String,
                child: Text(
                  p['full_name'] as String? ?? p['username'] as String,
                ),
              );
            }).toList(),
            onChanged: (v) => studentId = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (studentId == null) return;
                await supabase.from('group_students').upsert({
                  'group_id': groupId,
                  'student_id': studentId,
                }, onConflict: 'group_id,student_id');
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(adminGroupsProvider);
                ref.invalidate(groupMembersProvider(groupId));
              },
              child: Text(l10n.commonAssign),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(adminGroupsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminGroups)),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: const Icon(Icons.group_add_outlined),
      ),
      body: groups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (rows) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminGroupsProvider),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              shellContentBottomPadding(context, hasFab: true),
            ),
            itemCount: rows.length,
            itemBuilder: (_, i) {
              final g = rows[i];
              final teacher = g['teachers'] as Map?;
              final profile = teacher?['profiles'] as Map?;
              return PremiumCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${l10n.adminTeacherLine(profile?['full_name'] as String? ?? '—')} '
                            '(${localizedSphere(l10n, teacher?['sphere'])})',
                            style: TextStyle(
                              color: AppColors.inkAlpha(context, 0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person_add_alt,
                        color: AppColors.accent(context),
                      ),
                      onPressed: () => _assignStudent(g['id'] as String),
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
