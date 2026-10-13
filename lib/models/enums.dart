enum UserRole { student, teacher, admin }

enum Sphere { math, english }

enum AssignmentType { staticAssignment, homeworkPack }

enum AttendanceStatus { present, absent, late, excused }

enum SubmissionStatus { pending, submitted, reviewed }

enum ChatMessageType { text, voice, image, video, file }

ChatMessageType chatMessageTypeFromString(String? value) {
  return ChatMessageType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ChatMessageType.text,
  );
}

String chatMessageTypeToDb(ChatMessageType type) => type.name;

ChatMessageType chatMessageTypeForFileName(String fileName) {
  final lower = fileName.toLowerCase();
  const videos = ['.mp4', '.mov', '.webm', '.m4v', '.avi', '.mkv'];
  const images = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.heic',
    '.heif',
    '.bmp',
    '.tif',
    '.tiff',
  ];
  if (videos.any(lower.endsWith)) return ChatMessageType.video;
  if (images.any(lower.endsWith)) return ChatMessageType.image;
  return ChatMessageType.file;
}

enum MarkCategory {
  homework,
  classwork,
  quiz,
  test,
  exam,
  project,
  oral,
  other,
}

extension MarkCategoryLabel on MarkCategory {
  String get label => switch (this) {
    MarkCategory.homework => 'Homework',
    MarkCategory.classwork => 'Classwork',
    MarkCategory.quiz => 'Quiz',
    MarkCategory.test => 'Test',
    MarkCategory.exam => 'Exam',
    MarkCategory.project => 'Project',
    MarkCategory.oral => 'Oral',
    MarkCategory.other => 'Other',
  };
}

MarkCategory markCategoryFromString(String? value) {
  return MarkCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MarkCategory.other,
  );
}

UserRole userRoleFromString(String value) {
  return UserRole.values.firstWhere(
    (e) => e.name == value,
    orElse: () => UserRole.student,
  );
}

Sphere? sphereFromString(String? value) {
  if (value == null) return null;
  return Sphere.values.cast<Sphere?>().firstWhere(
    (e) => e?.name == value,
    orElse: () => null,
  );
}

AssignmentType assignmentTypeFromString(String value) {
  if (value == 'homework_pack') return AssignmentType.homeworkPack;
  return AssignmentType.staticAssignment;
}

String assignmentTypeToDb(AssignmentType type) {
  return type == AssignmentType.homeworkPack ? 'homework_pack' : 'static';
}

AttendanceStatus attendanceFromString(String value) {
  return AttendanceStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => AttendanceStatus.present,
  );
}
