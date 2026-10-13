import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/theme/app_style.dart';
import 'package:mu_study/providers/auth/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'preferred_theme';
const _stylePrefsKey = 'preferred_style';

enum AppThemePreference {
  light,
  dark,
  system;

  String get code => name;

  ThemeMode get themeMode => switch (this) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
    AppThemePreference.system => ThemeMode.system,
  };

  static AppThemePreference? tryParse(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final v in AppThemePreference.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}

Future<ThemeMode> loadSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final pref = AppThemePreference.tryParse(prefs.getString(_prefsKey));
  return pref?.themeMode ?? ThemeMode.system;
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    final controller = ThemeModeController(ref);
    ref.listen(currentProfileProvider, (prev, next) {
      next.whenData((profile) {
        final code = profile?.preferredTheme;
        if (code != null) controller.applyFromProfile(code);
      });
    });
    return controller;
  },
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._ref, {ThemeMode? initial})
    : super(initial ?? ThemeMode.system) {
    if (initial == null) {
      _loadLocal();
    }
  }

  final Ref _ref;

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final pref = AppThemePreference.tryParse(prefs.getString(_prefsKey));
    if (pref != null && mounted) state = pref.themeMode;
  }

  void applyFromProfile(String code) {
    final pref = AppThemePreference.tryParse(code);
    if (pref == null) return;
    if (state == pref.themeMode) return;
    state = pref.themeMode;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_prefsKey, pref.code),
    );
  }

  Future<void> setPreference(AppThemePreference preference) async {
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;

    if (state != preference.themeMode) {
      state = preference.themeMode;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, preference.code);

    final profile = _ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    if (profile.preferredTheme == preference.code) return;

    await _ref.read(profileRepositoryProvider).updateProfile(profile.id, {
      'preferred_theme': preference.code,
    });
    _ref.invalidate(currentProfileProvider);
  }
}

Future<AppStyle> loadSavedAppStyle() async {
  final prefs = await SharedPreferences.getInstance();
  return AppStyle.tryParse(prefs.getString(_stylePrefsKey)) ?? AppStyle.modern;
}

final appStyleProvider = StateNotifierProvider<AppStyleController, AppStyle>((
  ref,
) {
  final controller = AppStyleController(ref);
  ref.listen(currentProfileProvider, (prev, next) {
    next.whenData((profile) {
      final code = profile?.preferredStyle;
      if (code != null) controller.applyFromProfile(code);
    });
  });
  return controller;
});

class AppStyleController extends StateNotifier<AppStyle> {
  AppStyleController(this._ref, {AppStyle? initial})
    : super(initial ?? AppStyle.modern) {
    if (initial == null) {
      _loadLocal();
    }
  }

  final Ref _ref;

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final style = AppStyle.tryParse(prefs.getString(_stylePrefsKey));
    if (style != null && mounted) state = style;
  }

  void applyFromProfile(String code) {
    final style = AppStyle.tryParse(code);
    if (style == null) return;
    if (state == style) return;
    state = style;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_stylePrefsKey, style.code),
    );
  }

  Future<void> setStyle(AppStyle style) async {
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;

    if (state != style) state = style;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stylePrefsKey, style.code);

    final profile = _ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    if (profile.preferredStyle == style.code) return;

    await _ref.read(profileRepositoryProvider).updateProfile(profile.id, {
      'preferred_style': style.code,
    });
    _ref.invalidate(currentProfileProvider);
  }
}
