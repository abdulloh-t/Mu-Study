import 'dart:math';

import 'package:mu_study/core/admin/credential_slip.dart';
import 'package:mu_study/models/enums.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _passwordStorePrefix = 'login_slip_pw_';

Future<void> saveLoginPassword({
  required String userId,
  required String password,
}) async {
  if (userId.isEmpty || password.isEmpty) return;
  await _writeStoredPassword(userId, password);
  try {
    await supabase.rpc(
      'admin_save_login_password',
      params: {'p_user_id': userId, 'p_password': password},
    );
  } catch (_) {
    // Optional RPC; local store + auth reset are enough to print.
  }
}

Future<void> saveLoginPasswordsByUsername(
  Iterable<Map<String, dynamic>> rows,
) async {
  for (final row in rows) {
    final username = (row['username'] as String?)?.trim() ?? '';
    final password = (row['password'] as String?) ?? '';
    if (username.isEmpty || password.isEmpty) continue;
    try {
      final profile = await supabase
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      final id = profile?['id'] as String?;
      if (id == null) continue;
      await saveLoginPassword(userId: id, password: password);
    } catch (_) {}
  }
}

Future<List<CredentialSlip>> fetchCredentialSlips({
  required UserRole role,
  String? groupId,
}) async {
  var slips = await _fetchFromRpc(role: role, groupId: groupId);
  slips ??= await fetchCredentialSlipPreviews(role: role, groupId: groupId);
  return uniqueCredentialSlips(await _ensurePrintablePasswords(slips));
}

Future<List<CredentialSlip>?> _fetchFromRpc({
  required UserRole role,
  String? groupId,
}) async {
  try {
    final rows = await supabase.rpc(
      'admin_list_login_slips',
      params: {
        'p_role': role.name,
        'p_group_id': groupId,
      },
    );
    if (rows is! List) return null;
    return uniqueCredentialSlips(
      rows.map((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        return CredentialSlip(
          profileId: row['profile_id'] as String?,
          username: (row['username'] as String? ?? '').trim(),
          fullName: (row['full_name'] as String? ?? '').trim(),
          password: (row['password'] as String? ?? '').trim(),
        );
      }),
    );
  } on PostgrestException {
    return null;
  }
}

Future<List<CredentialSlip>> fetchCredentialSlipPreviews({
  required UserRole role,
  String? groupId,
}) async {
  final slips = <CredentialSlip>[];

  if (role == UserRole.student && groupId != null) {
    final rows = await supabase
        .from('group_students')
        .select(
          'students(profile_id, profiles(id, username, full_name, role, is_disabled))',
        )
        .eq('group_id', groupId);
    for (final raw in rows) {
      final student = raw['students'] as Map?;
      final profile = student?['profiles'] as Map?;
      final slip = _slipFromProfile(profile);
      if (slip != null) slips.add(slip);
    }
    return uniqueCredentialSlips(slips);
  }

  final rows = await supabase
      .from('profiles')
      .select('id, username, full_name, role, is_disabled')
      .eq('role', role.name)
      .eq('is_disabled', false)
      .order('full_name');
  for (final raw in rows) {
    final slip = _slipFromProfile(raw);
    if (slip != null) slips.add(slip);
  }
  return uniqueCredentialSlips(slips);
}

CredentialSlip? _slipFromProfile(Map<dynamic, dynamic>? json) {
  if (json == null) return null;
  if (json['is_disabled'] == true) return null;
  final username = (json['username'] as String? ?? '').trim();
  if (username.isEmpty) return null;
  return CredentialSlip(
    profileId: json['id'] as String?,
    username: username,
    fullName: (json['full_name'] as String? ?? '').trim(),
    password: '',
  );
}

Future<List<CredentialSlip>> _ensurePrintablePasswords(
  List<CredentialSlip> slips,
) async {
  final used = <String>{
    for (final slip in slips)
      if (slip.password.isNotEmpty) slip.password,
  };
  final out = <CredentialSlip>[];

  for (final slip in slips) {
    if (slip.password.isNotEmpty) {
      final id = slip.profileId;
      if (id != null) await _writeStoredPassword(id, slip.password);
      out.add(slip);
      continue;
    }

    final id = slip.profileId;
    if (id == null || id.isEmpty) continue;

    final stored = await _readStoredPassword(id);
    if (stored != null && stored.isNotEmpty) {
      used.add(stored);
      out.add(slip.copyWith(password: stored));
      continue;
    }

    var password = _newPassword();
    while (used.contains(password)) {
      password = _newPassword();
    }
    used.add(password);

    await supabase.rpc(
      'admin_reset_password',
      params: {'p_user_id': id, 'p_password': password},
    );
    await saveLoginPassword(userId: id, password: password);
    out.add(slip.copyWith(password: password));
  }

  return out;
}

Future<String?> _readStoredPassword(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('$_passwordStorePrefix$userId');
}

Future<void> _writeStoredPassword(String userId, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('$_passwordStorePrefix$userId', password);
}

String _newPassword() {
  const alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rng = Random.secure();
  return List.generate(12, (_) => alphabet[rng.nextInt(alphabet.length)]).join();
}
