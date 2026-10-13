import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/models/models.dart';

String localizedRole(AppLocalizations l10n, UserRole role) => switch (role) {
  UserRole.student => l10n.commonStudent,
  UserRole.teacher => l10n.commonTeacher,
  UserRole.admin => l10n.commonAdmin,
};

String localizedSphere(AppLocalizations l10n, Object? raw) {
  final name = raw?.toString();
  if (name == Sphere.math.name) return l10n.sphereMath;
  if (name == Sphere.english.name) return l10n.sphereEnglish;
  return name ?? '—';
}
