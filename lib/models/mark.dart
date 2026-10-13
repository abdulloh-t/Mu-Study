import 'package:mu_study/models/enums.dart';

class Mark {
  const Mark({
    required this.id,
    required this.groupId,
    required this.studentId,
    required this.teacherId,
    required this.title,
    required this.percentage,
    this.category = MarkCategory.other,
    this.weight = 1,
    this.comment = '',
    this.submissionId,
    required this.markedOn,
    this.studentName,
    this.groupTitle,
  });

  final String id;
  final String groupId;
  final String studentId;
  final String teacherId;
  final String title;
  final double percentage;
  final MarkCategory category;
  final double weight;
  final String comment;
  final String? submissionId;
  final DateTime markedOn;

  final String? studentName;

  final String? groupTitle;

  bool get isFromSubmission => submissionId != null;

  factory Mark.fromJson(Map<String, dynamic> json) {
    final student = json['students'] as Map?;
    final profile = student?['profiles'] as Map?;
    return Mark(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      studentId: json['student_id'] as String,
      teacherId: json['teacher_id'] as String,
      title: json['title'] as String? ?? '',
      percentage: double.tryParse('${json['percentage']}') ?? 0,
      category: markCategoryFromString(json['category'] as String?),
      weight: double.tryParse('${json['weight']}') ?? 1,
      comment: json['comment'] as String? ?? '',
      submissionId: json['submission_id'] as String?,
      markedOn:
          DateTime.tryParse(json['marked_on']?.toString() ?? '') ??
          DateTime.now(),
      studentName:
          profile?['full_name'] as String? ?? profile?['username'] as String?,
      groupTitle: (json['groups'] as Map?)?['title'] as String?,
    );
  }

  Map<String, dynamic> toWrite() => {
    'group_id': groupId,
    'student_id': studentId,
    'teacher_id': teacherId,
    'title': title,
    'category': category.name,
    'percentage': percentage,
    'weight': weight,
    'comment': comment,
    'marked_on': markedOn.toIso8601String().split('T').first,
  };
}

class GroupMember {
  const GroupMember({
    required this.studentId,
    required this.fullName,
    required this.username,
  });

  final String studentId;
  final String fullName;
  final String username;

  factory GroupMember.fromGroupStudentRow(Map<String, dynamic> json) {
    final student = json['students'] as Map;
    final profile = student['profiles'] as Map;
    final username = profile['username'] as String? ?? '';
    return GroupMember(
      studentId: student['id'] as String,
      fullName: (profile['full_name'] as String?)?.isNotEmpty == true
          ? profile['full_name'] as String
          : username,
      username: username,
    );
  }
}
