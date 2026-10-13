import 'package:mu_study/l10n/app_localizations.dart';

String timeOfDayGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l10n.greetingMorning;
  if (hour < 18) return l10n.greetingAfternoon;
  return l10n.greetingEvening;
}
