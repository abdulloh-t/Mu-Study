class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    this.body = '',
    this.isRead = false,
    this.kind = 'system',
    this.actionPath,
    this.refId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final bool isRead;

  final String kind;
  final String? actionPath;
  final String? refId;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      kind: json['kind'] as String? ?? 'system',
      actionPath: json['action_path'] as String?,
      refId: json['ref_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

class Announcement {
  const Announcement({
    required this.id,
    this.teacherId,
    required this.groupId,
    required this.title,
    this.description = '',
    this.imageUrls = const [],
    this.fileUrls = const [],
    this.createdAt,
  });

  final String id;

  final String? teacherId;
  final String groupId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> fileUrls;
  final DateTime? createdAt;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    List<String> urls(dynamic v) =>
        (v as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    return Announcement(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String?,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrls: urls(json['image_urls']),
      fileUrls: urls(json['file_urls']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
