import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/homework/assignment_templates.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/homework/assignment_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class TeacherHomeworkPackScreen extends ConsumerStatefulWidget {
  const TeacherHomeworkPackScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<TeacherHomeworkPackScreen> createState() =>
      _TeacherHomeworkPackScreenState();
}

class _TeacherHomeworkPackScreenState
    extends ConsumerState<TeacherHomeworkPackScreen> {
  Future<void> _saveAsTemplate(Assignment? assignment) async {
    if (assignment == null) return;
    final teacher = await ref.read(teacherProfileProvider.future);
    if (teacher == null || !mounted) return;
    final l10n = context.l10n;
    try {
      await saveAssignmentAsTemplate(
        teacherId: teacher.id,
        assignment: assignment,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.teacherTemplateSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonCouldNotSave('$e'))));
    }
  }

  Future<void> _showTaskDialog({TaskItem? task, int currentCount = 0}) async {
    final assignment = ref
        .read(assignmentDetailProvider(widget.assignmentId))
        .valueOrNull;
    if (assignment?.type == AssignmentType.staticAssignment) return;

    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    final linkController = TextEditingController(text: task?.linkUrl ?? '');
    final attachmentController = TextEditingController(
      text: task?.attachmentUrl ?? '',
    );

    if (!mounted) return;
    final l10n = context.l10n;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? l10n.teacherEditTask : l10n.teacherAddTask),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.commonTitle,
                  hintText: l10n.teacherTaskTitleHint,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: l10n.commonDescription),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: l10n.teacherReferenceLinkOptional,
                  hintText: l10n.teacherLinkHint,
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: attachmentController,
                decoration: InputDecoration(
                  labelText: l10n.teacherAttachmentUrlOptional,
                  hintText: l10n.teacherAttachmentHint,
                  prefixIcon: const Icon(Icons.attachment),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (c) => AlertDialog(
                    title: Text(l10n.teacherDeleteTask),
                    content: Text(l10n.commonCannotUndo),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: Text(l10n.commonCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: Text(
                          l10n.commonDelete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await supabase.from('tasks').delete().eq('id', task.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(tasksProvider(widget.assignmentId));
                }
              },
              child: Text(
                l10n.commonDelete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              final Map<String, dynamic> data = {
                'assignment_id': widget.assignmentId,
                'title': titleController.text.trim(),
                'description': descController.text.trim(),
                'link_url': linkController.text.trim().isEmpty
                    ? null
                    : linkController.text.trim(),
                'attachment_url': attachmentController.text.trim().isEmpty
                    ? null
                    : attachmentController.text.trim(),
              };

              if (isEditing) {
                await supabase.from('tasks').update(data).eq('id', task.id);
              } else {
                data['sort_order'] = currentCount;
                await supabase.from('tasks').insert(data);
              }

              if (ctx.mounted) Navigator.pop(ctx);
              ref.invalidate(tasksProvider(widget.assignmentId));
            },
            child: Text(isEditing ? l10n.commonSave : l10n.teacherAddTask),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignment = ref.watch(assignmentDetailProvider(widget.assignmentId));
    final tasks = ref.watch(tasksProvider(widget.assignmentId));
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teacherHomeworkPackTasks),
        actions: [
          IconButton(
            tooltip: l10n.teacherSaveAsTemplate,
            onPressed: () => _saveAsTemplate(assignment.valueOrNull),
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: assignment.maybeWhen(
        data: (a) {
          if (a == null || a.type != AssignmentType.homeworkPack) {
            return null;
          }
          return tasks.maybeWhen(
            data: (items) => FloatingActionButton.extended(
              onPressed: () => _showTaskDialog(currentCount: items.length),
              icon: const Icon(Icons.add),
              label: Text(l10n.teacherAddTask),
            ),
            orElse: () => null,
          );
        },
        orElse: () => null,
      ),
      body: assignment.when(
        data: (a) {
          if (a == null) {
            return EmptyState(title: l10n.assignmentNotFound);
          }
          if (a.type != AssignmentType.homeworkPack) {
            return EmptyState(
              title: l10n.staticAssignment,
              subtitle: l10n.assignmentTypeHintStatic,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(assignmentDetailProvider(widget.assignmentId));
              ref.invalidate(tasksProvider(widget.assignmentId));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                shellContentBottomPadding(context, hasFab: true, extra: 24),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.mutedGold,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mutedGold.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeworkPack.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.ink(context),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (a.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          a.description,
                          style: TextStyle(
                            color: AppColors.inkAlpha(context, 0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                PremiumSectionHeader(
                  title: l10n.teacherTasksContent,
                  subtitle: l10n.teacherManagePack,
                ),
                tasks.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          l10n.teacherNoTasksYet,
                          style: TextStyle(
                            color: AppColors.inkAlpha(context, 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final t = items[index];
                        final hasLink =
                            t.linkUrl != null && t.linkUrl!.isNotEmpty;
                        final hasAttachment =
                            t.attachmentUrl != null &&
                            t.attachmentUrl!.isNotEmpty;

                        return PremiumCard(
                          onTap: () => _showTaskDialog(task: t),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.softWash(
                                    context,
                                    lightAlpha: 0.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (t.description.isNotEmpty)
                                      Text(
                                        t.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.inkAlpha(
                                            context,
                                            0.6,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (hasLink || hasAttachment)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            if (hasLink)
                                              const Icon(
                                                Icons.link,
                                                size: 14,
                                                color: AppColors.successGreen,
                                              ),
                                            if (hasLink && hasAttachment)
                                              const SizedBox(width: 8),
                                            if (hasAttachment)
                                              const Icon(
                                                Icons.attachment,
                                                size: 14,
                                                color: AppColors.successGreen,
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.inkAlpha(context, 0.3),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => ErrorState(message: e.toString()),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}
