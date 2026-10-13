import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/core/services/app_cache.dart';
import 'package:mu_study/core/services/cache_service.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

class AuthRepository {
  AuthRepository(this._cache);

  final CacheService? _cache;

  Future<String?> resolveAuthEmail(String username) async {
    final normalized = username.trim();
    final result = await supabase.rpc(
      'get_auth_email_by_username',
      params: {'p_username': normalized},
    );
    return result as String?;
  }

  Future<void> signIn(String username, String password) async {
    final email = await resolveAuthEmail(username);
    if (email == null) {
      throw const AuthException('Incorrect username or password');
    }
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    await signIn(username, currentPassword);
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await clearAllAppCaches(_cache);
  }

  User? get currentUser => supabase.auth.currentUser;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(cacheServiceProvider).valueOrNull);
});

class ProfileRepository {
  ProfileRepository(this._cache);

  final CacheService? _cache;

  Future<Profile?> fetchCurrentProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (data == null) return null;
      final profile = Profile.fromJson(Map<String, dynamic>.from(data));
      await _cache?.cacheProfile(data);
      return profile;
    } catch (_) {
      final cached = _cache?.cachedProfile;
      if (cached != null) return Profile.fromJson(cached);
      rethrow;
    }
  }

  Future<void> updateProfile(String id, Map<String, dynamic> updates) async {
    await supabase.from('profiles').update(updates).eq('id', id);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final cacheAsync = ref.watch(cacheServiceProvider);
  return ProfileRepository(cacheAsync.valueOrNull);
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateProvider);
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchCurrentProfile();
});

final teacherProfileProvider = FutureProvider<TeacherProfile?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || profile.role != UserRole.teacher) return null;
  final data = await supabase
      .from('teachers')
      .select()
      .eq('profile_id', profile.id)
      .maybeSingle();
  if (data == null) return null;
  return TeacherProfile.fromJson(Map<String, dynamic>.from(data));
});

final studentProfileProvider = FutureProvider<StudentProfile?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || profile.role != UserRole.student) return null;
  final data = await supabase
      .from('students')
      .select()
      .eq('profile_id', profile.id)
      .maybeSingle();
  if (data == null) return null;
  return StudentProfile.fromJson(Map<String, dynamic>.from(data));
});
