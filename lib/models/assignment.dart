import 'package:mu_study/models/enums.dart';

class Assignment {
  const Assignment({
    required this.id,
    required this.teacherId,
    required this.groupId,
    required this.type,
    required this.title,
    this.description = '',
    this.dueDate,
    this.createdAt,
  });

  final String id;
  final String teacherId;
  final String groupId;
  final AssignmentType type;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? createdAt;

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      groupId: json['group_id'] as String,
      type: assignmentTypeFromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsert({
    required String teacherId,
    required String groupId,
  }) => {
    'teacher_id': teacherId,
    'group_id': groupId,
    'type': assignmentTypeToDb(type),
    'title': title,
    'description': description,
    'due_date': dueDate?.toIso8601String(),
  };
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.assignmentId,
    required this.title,
    this.description = '',
    this.attachmentUrl,
    this.linkUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String assignmentId;
  final String title;
  final String description;
  final String? attachmentUrl;
  final String? linkUrl;
  final int sortOrder;

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      assignmentId: json['assignment_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      linkUrl: json['link_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class Submission {
  const Submission({
    required this.id,
    required this.taskId,
    required this.studentId,
    this.textAnswer,
    this.fileUrl,
    this.voiceUrl,
    this.status = SubmissionStatus.pending,
    this.score,
    this.feedback,
    this.isCompleted = false,
    this.submittedAt,
  });

  final String id;
  final String taskId;
  final String studentId;
  final String? textAnswer;
  final String? fileUrl;
  final String? voiceUrl;
  final SubmissionStatus status;
  final double? score;
  final String? feedback;
  final bool isCompleted;
  final DateTime? submittedAt;

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      studentId: json['student_id'] as String,
      textAnswer: json['text_answer'] as String?,
      fileUrl: json['file_url'] as String?,
      voiceUrl: json['voice_url'] as String?,
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => SubmissionStatus.pending,
      ),
      score: json['score'] != null
          ? double.tryParse(json['score'].toString())
          : null,
      feedback: json['feedback'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
    );
  }
}
