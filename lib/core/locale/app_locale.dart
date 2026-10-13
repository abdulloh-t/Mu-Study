import 'package:flutter/material.dart';

enum AppLanguage {
  english('en'),
  russian('ru'),
  uzbek('uz');

  const AppLanguage(this.code);
  final String code;

  Locale get locale => Locale(code);

  static AppLanguage? tryParse(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final lang in AppLanguage.values) {
      if (lang.code == code) return lang;
    }
    return null;
  }

  static AppLanguage fromLocale(Locale locale) {
    return tryParse(locale.languageCode) ?? AppLanguage.english;
  }
}
