import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/homework/due_date_label.dart';
import 'package:mu_study/components/inputs/group_selector.dart';
import 'package:mu_study/components/inputs/load_more_button.dart';
import 'package:mu_study/components/layouts/premium_section_header.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/components/layouts/empty_state.dart';
import 'package:mu_study/core/homework/assignment_due.dart';
import 'package:mu_study/core/homework/assignment_templates.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/core/theme/neumorphic.dart';
import 'package:mu_study/l10n/l10n_x.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:mu_study/providers/groups/group_providers.dart';
import 'package:mu_study/providers/homework/assignment_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class TeacherAssignmentsScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentsScreen({super.key});

  @override
  ConsumerState<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState
    extends ConsumerState<TeacherAssignmentsScreen> {
  void _openPack(BuildContext context, Assignment a) {
    context.push('/teacher/assignments/${a.id}');
  }

  Future<void> _createAssignment({AssignmentTemplate? fromTemplate}) async {
    final teacher = await ref.read(teacherProfileProvider.future);
    final groups = await ref.read(myGroupsProvider.future);
    if (teacher == null || groups.isEmpty) return;

    var targetGroupId = ref.read(activeGroupIdProvider) ?? groups.first.id;
    final titleController = TextEditingController(
      text: fromTemplate?.title ?? '',
    );
    final descController = TextEditingController(
      text: fromTemplate?.description ?? '',
    );
    var type = fromTemplate?.type ?? AssignmentType.staticAssignment;
    DateTime? dueDate;

    if (!mounted) return;
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => AlertDialog(
          title: Text(
            fromTemplate == null
                ? l10n.assignmentNew
                : l10n.teacherCreateFromTemplate,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (fromTemplate != null && fromTemplate.tasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.teacherTasksCopied(fromTemplate.tasks.length),
                      style: TextStyle(
                        color: AppColors.inkAlpha(context, 0.55),
                        fontSize: 13,
                      ),
                    ),
                  ),
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.commonTitle),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.commonDescription,
                  ),
                ),
                const SizedBox(height: 16),
                if (fromTemplate == null) ...[
                  DropdownButtonFormField<AssignmentType>(
                    initialValue: type,
                    decoration: InputDecoration(labelText: l10n.commonType),
                    items: [
                      DropdownMenuItem(
                        value: AssignmentType.staticAssignment,
                        child: Text(l10n.staticAssignment),
                      ),
                      DropdownMenuItem(
                        value: AssignmentType.homeworkPack,
                        child: Text(l10n.homeworkPack),
                      ),
                    ],
                    onChanged: (v) => setStateLocal(
                      () => type = v ?? AssignmentType.staticAssignment,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type == AssignmentType.homeworkPack
                        ? l10n.assignmentTypeHintPack
                        : l10n.assignmentTypeHintStatic,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.inkAlpha(context, 0.55),
                    ),
                  ),
                ] else
                  InputDecorator(
                    decoration: InputDecoration(labelText: l10n.commonType),
                    child: Text(
                      type == AssignmentType.homeworkPack
                          ? l10n.homeworkPack
                          : l10n.staticAssignment,
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: targetGroupId,
                  decoration: InputDecoration(labelText: l10n.commonGroup),
                  items: groups
                      .map(
                        (g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.title)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setStateLocal(() => targetGroupId = v ?? targetGroupId),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    dueDate == null
                        ? l10n.commonNoDueDate
                        : l10n.commonDueDate(
                            DateFormat.yMMMd().format(dueDate!),
                          ),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setStateLocal(() => dueDate = picked);
                  },
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
                if (titleController.text.trim().isEmpty) return;
                Assignment? created;
                if (fromTemplate != null) {
                  created = await createAssignmentFromTemplate(
                    template: fromTemplate,
                    teacherId: teacher.id,
                    groupId: targetGroupId,
                    dueDate: dueDate,
                    titleOverride: titleController.text.trim(),
                    descriptionOverride: descController.text.trim(),
                  );
                } else {
                  final title = titleController.text.trim();
                  final description = descController.text.trim();
                  final row = await supabase
                      .from('assignments')
                      .insert({
                        'teacher_id': teacher.id,
                        'group_id': targetGroupId,
                        'type': assignmentTypeToDb(type),
                        'title': title,
                        'description': description,
                        'due_date': dueDate?.toIso8601String(),
                      })
                      .select()
                      .single();
                  created = Assignment.fromJson(Map<String, dynamic>.from(row));
                  if (type == AssignmentType.staticAssignment) {
                    await supabase.from('tasks').insert({
                      'assignment_id': created.id,
                      'title': title,
                      'description': description,
                      'sort_order': 0,
                    });
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(assignmentsProvider(targetGroupId));
                if (mounted && created.type == AssignmentType.homeworkPack) {
                  _openPack(context, created);
                }
              },
              child: Text(l10n.commonCreate),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editAssignment(Assignment a) async {
    final l10n = context.l10n;
    final titleController = TextEditingController(text: a.title);
    final descController = TextEditingController(text: a.description);
    DateTime? dueDate = a.dueDate;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => AlertDialog(
          title: Text(l10n.assignmentEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.commonTitle),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.commonDescription,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    dueDate == null
                        ? l10n.commonNoDueDate
                        : l10n.commonDueDate(
                            DateFormat.yMMMd().format(dueDate!),
                          ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dueDate != null)
                        IconButton(
                          tooltip: l10n.commonNoDueDate,
                          onPressed: () => setStateLocal(() => dueDate = null),
                          icon: const Icon(Icons.clear, size: 18),
                        ),
                      const Icon(Icons.calendar_today_outlined, size: 18),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setStateLocal(() => dueDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );

    if (saved != true || titleController.text.trim().isEmpty) return;
    final title = titleController.text.trim();
    final description = descController.text.trim();
    try {
      await supabase
          .from('assignments')
          .update({
            'title': title,
            'description': description,
            'due_date': dueDate?.toIso8601String(),
          })
          .eq('id', a.id);
      if (a.type == AssignmentType.staticAssignment) {
        final tasks = await supabase
            .from('tasks')
            .select('id')
            .eq('assignment_id', a.id)
            .order('sort_order')
            .limit(1);
        if (tasks.isEmpty) {
          await supabase.from('tasks').insert({
            'assignment_id': a.id,
            'title': title,
            'description': description,
            'sort_order': 0,
          });
        } else {
          await supabase
              .from('tasks')
              .update({'title': title, 'description': description})
              .eq('id', tasks.first['id'] as String);
        }
      }
      ref.invalidate(assignmentsProvider(a.groupId));
      ref.invalidate(assignmentDetailProvider(a.id));
      ref.invalidate(tasksProvider(a.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonCouldNotSave('$e'))));
    }
  }

  Future<void> _deleteAssignment(Assignment a) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.assignmentDeleteTitle),
        content: Text(l10n.assignmentDeleteBody),
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
    try {
      await supabase.from('assignments').delete().eq('id', a.id);
      ref.invalidate(assignmentsProvider(a.groupId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.assignmentDeleted)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonCouldNotSave('$e'))));
    }
  }

  Future<void> _duplicateAssignment(Assignment source) async {
    final teacher = await ref.read(teacherProfileProvider.future);
    final groups = await ref.read(myGroupsProvider.future);
    if (teacher == null || groups.isEmpty || !mounted) return;

    var targetGroupId = ref.read(activeGroupIdProvider) ?? source.groupId;
    final titleController = TextEditingController(
      text: '${source.title} (copy)',
    );
    DateTime? dueDate = source.dueDate;
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => AlertDialog(
          title: Text(l10n.teacherDuplicateTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.commonTitle),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: targetGroupId,
                  decoration: InputDecoration(labelText: l10n.commonGroup),
                  items: groups
                      .map(
                        (g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.title)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setStateLocal(() => targetGroupId = v ?? targetGroupId),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    dueDate == null
                        ? l10n.commonNoDueDate
                        : l10n.commonDueDate(
                            DateFormat.yMMMd().format(dueDate!),
                          ),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setStateLocal(() => dueDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.teacherDuplicateAssignment),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final created = await duplicateAssignment(
        source: source,
        teacherId: teacher.id,
        groupId: targetGroupId,
        dueDate: dueDate,
        titleOverride: titleController.text.trim(),
      );
      ref.invalidate(assignmentsProvider(targetGroupId));
      if (source.groupId != targetGroupId) {
        ref.invalidate(assignmentsProvider(source.groupId));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.teacherDuplicated)));
      if (created.type == AssignmentType.homeworkPack) {
        _openPack(context, created);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonCouldNotSave('$e'))));
    }
  }

  Future<void> _saveAsTemplate(Assignment assignment) async {
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

  Future<void> _openTemplates() async {
    final teacher = await ref.read(teacherProfileProvider.future);
    if (teacher == null || !mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _TemplatesSheet(
          teacherId: teacher.id,
          onUse: (template) {
            Navigator.pop(ctx);
            _createAssignment(fromTemplate: template);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(activeGroupIdProvider);
    final assignments = ref.watch(assignmentsProvider(groupId));
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.assignmentsTitle),
        actions: [
          IconButton(
            tooltip: l10n.teacherTemplates,
            onPressed: _openTemplates,
            icon: const Icon(Icons.dashboard_customize_outlined),
          ),
        ],
      ),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createAssignment(),
        child: const Icon(Icons.add),
      ),
      body: assignments.when(
        data: (page) {
          final list = sortAssignmentsByDue(page.items);
          final isNeu = Neumorphic.isActive(context);
          return ListView.builder(
            clipBehavior: isNeu ? Clip.none : Clip.hardEdge,
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              shellContentBottomPadding(context, hasFab: true),
            ),
            itemCount: list.length + 1 + (page.hasMore ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == 0) {
                return Column(
                  children: [
                    const GroupSelector(padding: EdgeInsets.only(bottom: 8)),
                    if (list.isEmpty)
                      EmptyState(
                        title: l10n.assignmentsEmpty,
                        subtitle: l10n.assignmentsEmptyTeacher,
                      ),
                  ],
                );
              }
              if (index == list.length + 1) {
                return LoadMoreButton(
                  hasMore: page.hasMore,
                  loading: page.loadingMore,
                  onPressed: () => ref
                      .read(assignmentsProvider(groupId).notifier)
                      .loadMore(),
                );
              }
              final a = list[index - 1];
              final isPack = a.type == AssignmentType.homeworkPack;
              final overdue = assignmentIsOverdue(a);
              final tone = AppColors.resolveAccent(
                context,
                overdue
                    ? AppColors.danger(context)
                    : isPack
                    ? AppColors.goldAccent(context)
                    : AppColors.accent(context),
              );
              final iconData = overdue
                  ? Icons.warning_amber_rounded
                  : isPack
                  ? Icons.inventory_2_outlined
                  : Icons.description_outlined;

              return PremiumCard(
                onTap: () =>
                    isPack ? _openPack(context, a) : _editAssignment(a),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    NeuIconWell(
                      icon: iconData,
                      color: tone,
                      size: 20,
                      padding: 10,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DueDateLabel(assignment: a, compact: true),
                          Text(
                            isPack ? l10n.homeworkPack : l10n.staticTask,
                            style: TextStyle(
                              color: AppColors.inkAlpha(context, 0.45),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editAssignment(a);
                          case 'delete':
                            _deleteAssignment(a);
                          case 'duplicate':
                            _duplicateAssignment(a);
                          case 'template':
                            _saveAsTemplate(a);
                          case 'open':
                            _openPack(context, a);
                        }
                      },
                      itemBuilder: (_) => [
                        if (isPack)
                          PopupMenuItem(
                            value: 'open',
                            child: Text(l10n.teacherManagePack),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.commonEdit),
                        ),
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Text(l10n.teacherDuplicateAssignment),
                        ),
                        PopupMenuItem(
                          value: 'template',
                          child: Text(l10n.teacherSaveAsTemplate),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.commonDelete),
                        ),
                      ],
                    ),
                  ],
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

class _TemplatesSheet extends StatefulWidget {
  const _TemplatesSheet({required this.teacherId, required this.onUse});

  final String teacherId;
  final ValueChanged<AssignmentTemplate> onUse;

  @override
  State<_TemplatesSheet> createState() => _TemplatesSheetState();
}

class _TemplatesSheetState extends State<_TemplatesSheet> {
  late Future<List<AssignmentTemplate>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchAssignmentTemplates(widget.teacherId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = fetchAssignmentTemplates(widget.teacherId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColors.sheetSurface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softSurface(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: PremiumSectionHeader(
                title: l10n.teacherTemplates,
                subtitle: l10n.teacherTemplatesEmptySubtitle,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<AssignmentTemplate>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return ErrorState(message: '${snap.error}');
                  }
                  final items = snap.data ?? const [];
                  if (items.isEmpty) {
                    return EmptyState(
                      title: l10n.teacherTemplatesEmpty,
                      subtitle: l10n.teacherTemplatesEmptySubtitle,
                      icon: Icons.dashboard_customize_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = items[i];
                      final isPack = t.type == AssignmentType.homeworkPack;
                      return PremiumCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${isPack ? l10n.homeworkPack : l10n.staticTask}'
                                    '${t.tasks.isEmpty ? '' : ' · ${l10n.teacherTasksCopied(t.tasks.length)}'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkAlpha(context, 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onUse(t),
                              child: Text(l10n.teacherUseTemplate),
                            ),
                            IconButton(
                              tooltip: l10n.commonDelete,
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: Text(l10n.teacherDeleteTemplate),
                                    content: Text(
                                      l10n.teacherDeleteTemplateBody(t.title),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: Text(l10n.commonCancel),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: Text(
                                          l10n.commonDelete,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await deleteAssignmentTemplate(t.id);
                                  await _reload();
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
