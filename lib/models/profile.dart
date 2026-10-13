import 'package:mu_study/models/enums.dart';

class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.isDisabled = false,
    this.preferredLanguage,
    this.preferredTheme,
    this.preferredStyle,
  });

  final String id;
  final String username;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final bool isDisabled;

  final String? preferredLanguage;

  final String? preferredTheme;

  final String? preferredStyle;

  bool get hasChosenLanguage =>
      preferredLanguage != null && preferredLanguage!.isNotEmpty;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String? ?? '',
      role: userRoleFromString(json['role'] as String),
      avatarUrl: json['avatar_url'] as String?,
      isDisabled: json['is_disabled'] as bool? ?? false,
      preferredLanguage: json['preferred_language'] as String?,
      preferredTheme: json['preferred_theme'] as String?,
      preferredStyle: json['preferred_style'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'preferred_language': preferredLanguage,
    'preferred_theme': preferredTheme,
    'preferred_style': preferredStyle,
  };
}

class TeacherProfile {
  const TeacherProfile({
    required this.id,
    required this.profileId,
    required this.sphere,
  });

  final String id;
  final String profileId;
  final Sphere sphere;

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      sphere: sphereFromString(json['sphere'] as String) ?? Sphere.math,
    );
  }
}

class StudentProfile {
  const StudentProfile({required this.id, required this.profileId});

  final String id;
  final String profileId;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
    );
  }
}

class StudyGroup {
  const StudyGroup({
    required this.id,
    required this.teacherId,
    required this.title,
    this.createdAt,
  });

  final String id;
  final String teacherId;
  final String title;
  final DateTime? createdAt;

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      title: json['title'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
