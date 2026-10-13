import 'package:mu_study/models/models.dart';
import 'package:mu_study/supabase/supabase_client.dart';

class TemplateTaskDraft {
  const TemplateTaskDraft({
    required this.title,
    this.description = '',
    this.attachmentUrl,
    this.linkUrl,
    this.sortOrder = 0,
  });

  final String title;
  final String description;
  final String? attachmentUrl;
  final String? linkUrl;
  final int sortOrder;

  factory TemplateTaskDraft.fromJson(Map<String, dynamic> json) {
    return TemplateTaskDraft(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      linkUrl: json['link_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  factory TemplateTaskDraft.fromTask(TaskItem task) {
    return TemplateTaskDraft(
      title: task.title,
      description: task.description,
      attachmentUrl: task.attachmentUrl,
      linkUrl: task.linkUrl,
      sortOrder: task.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'attachment_url': attachmentUrl,
    'link_url': linkUrl,
    'sort_order': sortOrder,
  };
}

class AssignmentTemplate {
  const AssignmentTemplate({
    required this.id,
    required this.teacherId,
    required this.type,
    required this.title,
    this.description = '',
    this.tasks = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String teacherId;
  final AssignmentType type;
  final String title;
  final String description;
  final List<TemplateTaskDraft> tasks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AssignmentTemplate.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'];
    final tasks = <TemplateTaskDraft>[];
    if (rawTasks is List) {
      for (final item in rawTasks) {
        if (item is Map) {
          tasks.add(
            TemplateTaskDraft.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return AssignmentTemplate(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      type: assignmentTypeFromString(json['type'] as String? ?? 'static'),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tasks: tasks,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}

Future<List<AssignmentTemplate>> fetchAssignmentTemplates(
  String teacherId,
) async {
  final rows = await supabase
      .from('assignment_templates')
      .select()
      .eq('teacher_id', teacherId)
      .order('updated_at', ascending: false);
  return rows
      .map((e) => AssignmentTemplate.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<AssignmentTemplate> saveAssignmentAsTemplate({
  required String teacherId,
  required Assignment assignment,
}) async {
  final taskRows = await supabase
      .from('tasks')
      .select()
      .eq('assignment_id', assignment.id)
      .order('sort_order', ascending: true);
  var drafts = taskRows
      .map(
        (e) => TemplateTaskDraft.fromTask(
          TaskItem.fromJson(Map<String, dynamic>.from(e)),
        ),
      )
      .toList();
  if (assignment.type == AssignmentType.staticAssignment) {
    if (drafts.isEmpty) {
      drafts = [
        TemplateTaskDraft(
          title: assignment.title,
          description: assignment.description,
        ),
      ];
    } else {
      final first = drafts.first;
      drafts = [
        TemplateTaskDraft(
          title: first.title,
          description: first.description,
          attachmentUrl: first.attachmentUrl,
          linkUrl: first.linkUrl,
        ),
      ];
    }
  }

  final row = await supabase
      .from('assignment_templates')
      .insert({
        'teacher_id': teacherId,
        'type': assignmentTypeToDb(assignment.type),
        'title': assignment.title,
        'description': assignment.description,
        'tasks': drafts.map((d) => d.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      })
      .select()
      .single();

  return AssignmentTemplate.fromJson(Map<String, dynamic>.from(row));
}

Future<void> deleteAssignmentTemplate(String templateId) async {
  await supabase.from('assignment_templates').delete().eq('id', templateId);
}

Future<Assignment> createAssignmentFromTemplate({
  required AssignmentTemplate template,
  required String teacherId,
  required String groupId,
  DateTime? dueDate,
  String? titleOverride,
  String? descriptionOverride,
}) async {
  final inserted = await supabase
      .from('assignments')
      .insert({
        'teacher_id': teacherId,
        'group_id': groupId,
        'type': assignmentTypeToDb(template.type),
        'title': titleOverride?.trim().isNotEmpty == true
            ? titleOverride!.trim()
            : template.title,
        'description': descriptionOverride ?? template.description,
        'due_date': dueDate?.toIso8601String(),
      })
      .select()
      .single();

  final assignment = Assignment.fromJson(Map<String, dynamic>.from(inserted));

  final title = assignment.title;
  final description = assignment.description;
  List<TemplateTaskDraft> tasksToInsert;
  if (template.type == AssignmentType.staticAssignment) {
    final first = template.tasks.isNotEmpty ? template.tasks.first : null;
    tasksToInsert = [
      TemplateTaskDraft(
        title: first?.title.isNotEmpty == true ? first!.title : title,
        description: first?.description ?? description,
        attachmentUrl: first?.attachmentUrl,
        linkUrl: first?.linkUrl,
      ),
    ];
  } else {
    tasksToInsert = template.tasks;
  }

  if (tasksToInsert.isNotEmpty) {
    await supabase.from('tasks').insert([
      for (var i = 0; i < tasksToInsert.length; i++)
        {
          'assignment_id': assignment.id,
          'title': tasksToInsert[i].title,
          'description': tasksToInsert[i].description,
          'attachment_url': tasksToInsert[i].attachmentUrl,
          'link_url': tasksToInsert[i].linkUrl,
          'sort_order': i,
        },
    ]);
  }

  return assignment;
}

Future<Assignment> duplicateAssignment({
  required Assignment source,
  required String teacherId,
  required String groupId,
  DateTime? dueDate,
  String? titleOverride,
}) async {
  final taskRows = await supabase
      .from('tasks')
      .select()
      .eq('assignment_id', source.id)
      .order('sort_order', ascending: true);

  final title = titleOverride?.trim().isNotEmpty == true
      ? titleOverride!.trim()
      : '${source.title} (copy)';

  final inserted = await supabase
      .from('assignments')
      .insert({
        'teacher_id': teacherId,
        'group_id': groupId,
        'type': assignmentTypeToDb(source.type),
        'title': title,
        'description': source.description,
        'due_date': dueDate?.toIso8601String(),
      })
      .select()
      .single();

  final assignment = Assignment.fromJson(Map<String, dynamic>.from(inserted));

  if (source.type == AssignmentType.staticAssignment) {
    if (taskRows.isEmpty) {
      await supabase.from('tasks').insert({
        'assignment_id': assignment.id,
        'title': title,
        'description': source.description,
        'sort_order': 0,
      });
    } else {
      final t = TaskItem.fromJson(Map<String, dynamic>.from(taskRows.first));
      await supabase.from('tasks').insert({
        'assignment_id': assignment.id,
        'title': t.title,
        'description': t.description,
        'attachment_url': t.attachmentUrl,
        'link_url': t.linkUrl,
        'sort_order': 0,
      });
    }
  } else if (taskRows.isNotEmpty) {
    final tasks = [
      for (final row in taskRows)
        TaskItem.fromJson(Map<String, dynamic>.from(row)),
    ];
    await supabase.from('tasks').insert([
      for (var i = 0; i < tasks.length; i++)
        {
          'assignment_id': assignment.id,
          'title': tasks[i].title,
          'description': tasks[i].description,
          'attachment_url': tasks[i].attachmentUrl,
          'link_url': tasks[i].linkUrl,
          'sort_order': i,
        },
    ]);
  }

  return assignment;
}
