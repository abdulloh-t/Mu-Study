enum AppStyle {
  modern,
  naturePaper,
  softNeumorphism,
  monochromeWorkspace;

  String get code => name;

  static AppStyle? tryParse(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final v in AppStyle.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}
