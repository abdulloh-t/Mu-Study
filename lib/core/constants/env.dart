import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static const _defaultUrl = 'https://nmmdvdprczukaskxxdrs.supabase.co';
  static const _placeholderKey = 'your_anon_key_here';

  static String supabaseUrl = _defaultUrl;
  static String supabaseAnonKey = '';

  static bool get isConfigured => supabaseAnonKey.isNotEmpty;

  static void _sanitizeKey() {
    final key = supabaseAnonKey.trim();
    if (key.isEmpty ||
        key == _placeholderKey ||
        key.startsWith('your_') ||
        key.contains('paste_your') ||
        key.startsWith('sb_secret_')) {
      supabaseAnonKey = '';
      return;
    }
    if (!key.startsWith('eyJ') && !key.startsWith('sb_publishable_')) {
      supabaseAnonKey = '';
    }
  }

  static Future<void> load() async {
    const defineUrl = String.fromEnvironment('SUPABASE_URL');
    const defineKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (defineKey.isNotEmpty) {
      supabaseAnonKey = defineKey;
      if (defineUrl.isNotEmpty) supabaseUrl = defineUrl;
      _sanitizeKey();
      return;
    }

    try {
      await dotenv.load(fileName: '.env');
      supabaseAnonKey =
          (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
                  dotenv.env['SUPABASE_ANON_KEY'])
              ?.trim() ??
          '';
      final url = dotenv.env['SUPABASE_URL']?.trim();
      if (url != null && url.isNotEmpty) supabaseUrl = url;
    } catch (_) {}

    _sanitizeKey();
  }
}
