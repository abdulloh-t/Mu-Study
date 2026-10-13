import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/locale/app_locale.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'preferred_language';

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  final controller = LocaleController(ref);
  ref.listen(currentProfileProvider, (prev, next) {
    next.whenData((profile) {
      final code = profile?.preferredLanguage;
      if (code != null) controller.applyFromProfile(code);
    });
  });
  return controller;
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._ref) : super(AppLanguage.english.locale) {
    _loadLocal();
  }

  final Ref _ref;

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    final lang = AppLanguage.tryParse(code);
    if (lang != null) state = lang.locale;
  }

  void applyFromProfile(String code) {
    final lang = AppLanguage.tryParse(code);
    if (lang == null) return;
    if (state.languageCode == lang.code) return;
    state = lang.locale;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_prefsKey, lang.code),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    // `!semantics.parentDataDirty` assert storms in debug.
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;

    final localeChanged = state.languageCode != language.code;
    if (localeChanged) state = language.locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);

    final profile = _ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    if (profile.preferredLanguage == language.code) return;

    await _ref.read(profileRepositoryProvider).updateProfile(profile.id, {
      'preferred_language': language.code,
    });
    _ref.invalidate(currentProfileProvider);
  }
}
