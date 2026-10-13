import 'package:flutter/material.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/models/models.dart';

extension MarkCategoryL10n on MarkCategory {
  String l10nLabel(AppLocalizations l10n) => switch (this) {
    MarkCategory.homework => l10n.categoryHomework,
    MarkCategory.classwork => l10n.categoryClasswork,
    MarkCategory.quiz => l10n.categoryQuiz,
    MarkCategory.test => l10n.categoryTest,
    MarkCategory.exam => l10n.categoryExam,
    MarkCategory.project => l10n.categoryProject,
    MarkCategory.oral => l10n.categoryOral,
    MarkCategory.other => l10n.categoryOther,
  };
}

extension AttendanceStatusL10n on AttendanceStatus {
  String l10nLabel(AppLocalizations l10n) => switch (this) {
    AttendanceStatus.present => l10n.attendancePresentWord,
    AttendanceStatus.absent => l10n.attendanceAbsentWord,
    AttendanceStatus.late => l10n.attendanceLateWord,
    AttendanceStatus.excused => l10n.attendanceExcusedWord,
  };
}

extension SphereL10n on Sphere {
  String l10nLabel(AppLocalizations l10n) => switch (this) {
    Sphere.math => l10n.sphereMath,
    Sphere.english => l10n.sphereEnglish,
  };
}

extension AppNotificationL10n on AppNotification {
  String kindLabel(AppLocalizations l10n) => switch (kind) {
    'assignment' => l10n.notifKindAssignment,
    'announcement' => l10n.notifKindAnnouncement,
    'graded' => l10n.notifKindGraded,
    'submission' => l10n.notifKindSubmission,
    'chat' => l10n.notifKindChat,
    _ => title.isNotEmpty ? title : l10n.notifKindSystem,
  };

  IconData get kindIcon => switch (kind) {
    'assignment' => Icons.assignment_outlined,
    'announcement' => Icons.campaign_outlined,
    'graded' => Icons.grade_outlined,
    'submission' => Icons.upload_file_outlined,
    'chat' => Icons.chat_bubble_outline_rounded,
    _ => Icons.notifications_outlined,
  };
}
